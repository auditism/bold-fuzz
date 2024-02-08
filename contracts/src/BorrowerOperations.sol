// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

import "./Interfaces/IBorrowerOperations.sol";
import "./Interfaces/ITroveManager.sol";
import "./Interfaces/IBoldToken.sol";
import "./Interfaces/ICollSurplusPool.sol";
import "./Interfaces/ISortedTroves.sol";
import "./Dependencies/LiquityBase.sol";
import "./Dependencies/Ownable.sol";
import "./Dependencies/CheckContract.sol";

// import "forge-std/console.sol";


contract BorrowerOperations is LiquityBase, Ownable, CheckContract, IBorrowerOperations {
    using SafeERC20 for IERC20;

    string constant public NAME = "BorrowerOperations";

    // --- Connected contract declarations ---

    IERC20 public immutable ETH;
    ITroveManager public troveManager;
    address stabilityPoolAddress;
    address gasPoolAddress;
    ICollSurplusPool collSurplusPool;
    IBoldToken public boldToken;
    // A doubly linked list of Troves, sorted by their collateral ratios
    ISortedTroves public sortedTroves;

    /* --- Variable container structs  ---

    Used to hold, return and assign variables inside a function, in order to avoid the error:
    "CompilerError: Stack too deep". */

     struct LocalVariables_adjustTrove {
        uint price;
        uint netDebtChange;
        uint debt;
        uint coll;
        uint oldICR;
        uint newICR;
        uint newTCR;
        uint BoldFee;
        uint newDebt;
        uint newColl;
        uint stake;
    }

    struct LocalVariables_openTrove {
        uint price;
        uint BoldFee;
        uint netDebt;
        uint compositeDebt;
        uint ICR;
        uint stake;
        uint arrayIndex;
    }

    struct ContractsCache {
        ITroveManager troveManager;
        IActivePool activePool;
        IBoldToken boldToken;
    }

    enum BorrowerOperation {
        openTrove,
        closeTrove,
        adjustTrove
    }

    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event ActivePoolAddressChanged(address _activePoolAddress);
    event DefaultPoolAddressChanged(address _defaultPoolAddress);
    event StabilityPoolAddressChanged(address _stabilityPoolAddress);
    event GasPoolAddressChanged(address _gasPoolAddress);
    event CollSurplusPoolAddressChanged(address _collSurplusPoolAddress);
    event PriceFeedAddressChanged(address  _newPriceFeedAddress);
    event SortedTrovesAddressChanged(address _sortedTrovesAddress);
    event BoldTokenAddressChanged(address _boldTokenAddress);

    event TroveCreated(address indexed _owner, uint256 _troveId, uint256 _arrayIndex);
    event TroveUpdated(uint256 indexed _troveId, uint _debt, uint _coll, uint stake, BorrowerOperation operation);
    event BoldBorrowingFeePaid(uint256 indexed _troveId, uint _boldFee);

    constructor(address _ETHAddress) {
        checkContract(_ETHAddress);
        ETH = IERC20(_ETHAddress);
    }

    // --- Dependency setters ---

    function setAddresses(
        address _troveManagerAddress,
        address _activePoolAddress,
        address _defaultPoolAddress,
        address _stabilityPoolAddress,
        address _gasPoolAddress,
        address _collSurplusPoolAddress,
        address _priceFeedAddress,
        address _sortedTrovesAddress,
        address _boldTokenAddress
    )
        external
        override
        onlyOwner
    {
        // This makes impossible to open a trove with zero withdrawn Bold
        assert(MIN_NET_DEBT > 0);

        checkContract(_troveManagerAddress);
        checkContract(_activePoolAddress);
        checkContract(_defaultPoolAddress);
        checkContract(_stabilityPoolAddress);
        checkContract(_gasPoolAddress);
        checkContract(_collSurplusPoolAddress);
        checkContract(_priceFeedAddress);
        checkContract(_sortedTrovesAddress);
        checkContract(_boldTokenAddress);

        troveManager = ITroveManager(_troveManagerAddress);
        activePool = IActivePool(_activePoolAddress);
        defaultPool = IDefaultPool(_defaultPoolAddress);
        stabilityPoolAddress = _stabilityPoolAddress;
        gasPoolAddress = _gasPoolAddress;
        collSurplusPool = ICollSurplusPool(_collSurplusPoolAddress);
        priceFeed = IPriceFeed(_priceFeedAddress);
        sortedTroves = ISortedTroves(_sortedTrovesAddress);
        boldToken = IBoldToken(_boldTokenAddress);

        emit TroveManagerAddressChanged(_troveManagerAddress);
        emit ActivePoolAddressChanged(_activePoolAddress);
        emit DefaultPoolAddressChanged(_defaultPoolAddress);
        emit StabilityPoolAddressChanged(_stabilityPoolAddress);
        emit GasPoolAddressChanged(_gasPoolAddress);
        emit CollSurplusPoolAddressChanged(_collSurplusPoolAddress);
        emit PriceFeedAddressChanged(_priceFeedAddress);
        emit SortedTrovesAddressChanged(_sortedTrovesAddress);
        emit BoldTokenAddressChanged(_boldTokenAddress);

        // Allow funds movements between Liquity contracts
        ETH.approve(_activePoolAddress, type(uint256).max);

        _renounceOwnership();
    }

    // --- Borrower Trove Operations ---

    function openTrove(
        address _owner,
        uint256 _ownerIndex,
        uint _maxFeePercentage,
        uint256 _ETHAmount,
        uint _boldAmount,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _annualInterestRate
    )
        external
        override
        returns (uint256)
    {
        ContractsCache memory contractsCache = ContractsCache(troveManager, activePool, boldToken);
        LocalVariables_openTrove memory vars;

        vars.price = priceFeed.fetchPrice();
        bool isRecoveryMode = _checkRecoveryMode(vars.price);

        _requireValidAnnualInterestRate(_annualInterestRate);
        _requireValidMaxFeePercentage(_maxFeePercentage, isRecoveryMode);

        uint256 troveId = uint256(keccak256(abi.encode(_owner, _ownerIndex)));
        _requireTroveisNotActive(contractsCache.troveManager, troveId);

        vars.BoldFee;
        vars.netDebt = _boldAmount;

        if (!isRecoveryMode) {
            // TODO: implement interest rate charges
        }
        _requireAtLeastMinNetDebt(vars.netDebt);

        // ICR is based on the composite debt, i.e. the requested Bold amount + Bold borrowing fee + Bold gas comp.
        vars.compositeDebt = _getCompositeDebt(vars.netDebt);
        assert(vars.compositeDebt > 0);

        troveManager.mintAggInterest(int256(vars.compositeDebt));

        vars.ICR = LiquityMath._computeCR(_ETHAmount, vars.compositeDebt, vars.price);

        if (isRecoveryMode) {
            _requireICRisAboveCCR(vars.ICR);
        } else {
            _requireICRisAboveMCR(vars.ICR);
            uint newTCR = _getNewTCRFromTroveChange(_ETHAmount, true, vars.compositeDebt, true, vars.price);  // bools: coll increase, debt increase
            _requireNewTCRisAboveCCR(newTCR);
        }

        // Set the stored Trove properties and mint the NFT
        vars.stake = contractsCache.troveManager.setTrovePropertiesOnOpen(
            _owner,
            troveId,
            _ETHAmount,
            vars.compositeDebt,
            _annualInterestRate
        );

        sortedTroves.insert(troveId, _annualInterestRate, _upperHint, _lowerHint);
        vars.arrayIndex = contractsCache.troveManager.addTroveIdToArray(troveId);
        emit TroveCreated(_owner, troveId, vars.arrayIndex);

        // Pull ETH tokens from sender and move them to the Active Pool
        _pullETHAndSendToActivePool(contractsCache.activePool, _ETHAmount);
        // Mint Bold to borrower
        _withdrawBold(contractsCache.activePool, contractsCache.boldToken, msg.sender, _boldAmount, vars.netDebt);
        // Move the Bold gas compensation to the Gas Pool
        _withdrawBold(contractsCache.activePool, contractsCache.boldToken, gasPoolAddress, BOLD_GAS_COMPENSATION, BOLD_GAS_COMPENSATION);

        emit TroveUpdated(troveId, vars.compositeDebt, _ETHAmount, vars.stake, BorrowerOperation.openTrove);
        emit BoldBorrowingFeePaid(troveId, vars.BoldFee);

        return troveId;
    }

    // Send ETH as collateral to a trove
    function addColl(uint256 _troveId, uint256 _ETHAmount) external override {
        _adjustTrove(msg.sender, _troveId, _ETHAmount, true, 0, false, 0);
    }

    // Send ETH as collateral to a trove. Called by only the Stability Pool.
    function moveETHGainToTrove(address _sender, uint256 _troveId, uint256 _ETHAmount) external override {
        _requireCallerIsStabilityPool();
        // TODO: check owner?
        _adjustTrove(_sender, _troveId, _ETHAmount, true, 0, false, 0);
    }

    // Withdraw ETH collateral from a trove
    function withdrawColl(uint256 _troveId, uint _collWithdrawal) external override {
        _adjustTrove(msg.sender, _troveId, _collWithdrawal, false, 0, false, 0);
    }

    // Withdraw Bold tokens from a trove: mint new Bold tokens to the owner, and increase the trove's debt accordingly
    function withdrawBold(uint256 _troveId, uint _maxFeePercentage, uint _boldAmount ) external override {
        _adjustTrove(msg.sender, _troveId, 0, false, _boldAmount, true, _maxFeePercentage);
    }

    // Repay Bold tokens to a Trove: Burn the repaid Bold tokens, and reduce the trove's debt accordingly
    function repayBold(uint256 _troveId, uint _boldAmount) external override {
        _adjustTrove(msg.sender, _troveId, 0, false, _boldAmount, false, 0);
    }

    function adjustTrove(
        uint256 _troveId,
        uint _maxFeePercentage,
        uint _collChange,
        bool _isCollIncrease,
        uint _boldChange,
        bool _isDebtIncrease
    )
        external
        override
    {
        _adjustTrove(msg.sender, _troveId, _collChange, _isCollIncrease, _boldChange, _isDebtIncrease, _maxFeePercentage);
    }

    function adjustTroveInterestRate(uint256 _troveId, uint _newAnnualInterestRate, uint256 _upperHint, uint256 _lowerHint) external {
        // TODO: Delegation functionality
        _requireValidAnnualInterestRate(_newAnnualInterestRate);
        ITroveManager troveManagerCached = troveManager;
        _requireTroveisActive(troveManagerCached, _troveId);

        // TODO: apply individual and aggregate pending interest, and take snapshots of current timestamp.
        // TODO: determine how applying pending interest should interact / be sequenced with applying pending rewards from redistributions.

        troveManagerCached.getAndApplyRedistributionGains(msg.sender);

        sortedTroves.reInsert(_troveId, _newAnnualInterestRate, _upperHint, _lowerHint);

        troveManagerCached.changeAnnualInterestRate(_troveId, _newAnnualInterestRate);
    }

    /*
    * _adjustTrove(): Alongside a debt change, this function can perform either a collateral top-up or a collateral withdrawal.
    */
    function _adjustTrove(
        address _sender,
        uint256 _troveId,
        uint _collChange,
        bool _isCollIncrease,
        uint _boldChange,
        bool _isDebtIncrease,
        uint _maxFeePercentage
    )
        internal
    {
        ContractsCache memory contractsCache = ContractsCache(troveManager, activePool, boldToken);
        LocalVariables_adjustTrove memory vars;

        vars.price = priceFeed.fetchPrice();
        bool isRecoveryMode = _checkRecoveryMode(vars.price);

        if (_isCollIncrease) {
            _requireNonZeroCollChange(_collChange);
        }
        if (_isDebtIncrease) {
            _requireValidMaxFeePercentage(_maxFeePercentage, isRecoveryMode);
            _requireNonZeroDebtChange(_boldChange);
        }
        _requireNonZeroAdjustment(_collChange, _boldChange);
        _requireTroveisActive(contractsCache.troveManager, _troveId);

        // Confirm the operation is an ETH transfer if coming from the Stability Pool to a trove
        assert((msg.sender != stabilityPoolAddress || (_isCollIncrease && _boldChange == 0)));

        // TODO: apply individual and aggregate pending interest, and take snapshots of current timestamp.

        contractsCache.troveManager.getAndApplyRedistributionGains(_borrower);

        // Get the collChange based on whether or not ETH was sent in the transaction
        (vars.collChange, vars.isCollIncrease) = _getCollChange(msg.value, _collWithdrawal);

        vars.netDebtChange = _boldChange;

        // If the adjustment incorporates a debt increase and system is in Normal Mode, then trigger a borrowing fee
        if (_isDebtIncrease && !isRecoveryMode) {
            // TODO: implement interest rate charges
        }

        (vars.debt, vars.coll, , , ) = contractsCache.troveManager.getEntireDebtAndColl(_troveId);

        // Get the trove's old ICR before the adjustment, and what its new ICR will be after the adjustment
        vars.oldICR = LiquityMath._computeCR(vars.coll, vars.debt, vars.price);
        vars.newICR = _getNewICRFromTroveChange(
            vars.coll,
            vars.debt,
            _collChange,
            _isCollIncrease,
            vars.netDebtChange,
            _isDebtIncrease,
            vars.price
        );
        assert(_isCollIncrease || _collChange <= vars.coll); // TODO: do we still need this?

        // Check the adjustment satisfies all conditions for the current system mode
        _requireValidAdjustmentInCurrentMode(isRecoveryMode, _collChange, _isCollIncrease, _isDebtIncrease, vars);

        // When the adjustment is a debt repayment, check it's a valid amount and that the caller has enough Bold
        if (!_isDebtIncrease && _boldChange > 0) {
            _requireAtLeastMinNetDebt(_getNetDebt(vars.debt) - vars.netDebtChange);
            _requireValidBoldRepayment(vars.debt, vars.netDebtChange);
            _requireSufficientBoldBalance(contractsCache.boldToken, msg.sender, vars.netDebtChange);
        }

        // Finally actually update the Trove's recorded debt and coll
        // TODO: use the composite update function
        (vars.newColl, vars.newDebt) = _updateTroveFromAdjustment(
            contractsCache.troveManager,
            _sender,
            _troveId,
            vars.coll,
            _collChange,
            _isCollIncrease,
            vars.debt,
            vars.netDebtChange,
            _isDebtIncrease
        );
        vars.stake = contractsCache.troveManager.updateStakeAndTotalStakes(_troveId);

        emit TroveUpdated(_troveId, vars.newDebt, vars.newColl, vars.stake, BorrowerOperation.adjustTrove);
        emit BoldBorrowingFeePaid(_troveId,  vars.BoldFee);

        // Use the unmodified _boldChange here, as we don't send the fee to the user
        //TODO: any macro changes due to interest rates here?
        _moveTokensAndETHfromAdjustment(
            contractsCache.activePool,
            contractsCache.boldToken,
            contractsCache.troveManager,
            _troveId,
            _collChange,
            _isCollIncrease,
            _boldChange,
            _isDebtIncrease,
            vars.netDebtChange
        );
    }

    function closeTrove(uint256 _troveId) external override {
        ITroveManager troveManagerCached = troveManager;
        IActivePool activePoolCached = activePool;
        IBoldToken boldTokenCached = boldToken;

        _requireCallerIsBorrower(troveManagerCached, _troveId);
        _requireTroveisActive(troveManagerCached, _troveId);
        uint price = priceFeed.fetchPrice();
        _requireNotInRecoveryMode(price);

        // TODO: apply individual and aggregate pending interest, and take snapshots of current timestamp.

        troveManagerCached.getAndApplyRedistributionGains(msg.sender);

        uint coll = troveManagerCached.getTroveColl(_troveId);
        uint debt = troveManagerCached.getTroveDebt(_troveId);

        _requireSufficientBoldBalance(boldTokenCached, msg.sender, debt - BOLD_GAS_COMPENSATION);

        uint newTCR = _getNewTCRFromTroveChange(coll, false, debt, false, price);
        _requireNewTCRisAboveCCR(newTCR);

        troveManagerCached.removeStake(_troveId);
        troveManagerCached.closeTrove(_troveId);

        emit TroveUpdated(_troveId, 0, 0, 0, BorrowerOperation.closeTrove);

        // Burn the repaid Bold from the user's balance and the gas compensation from the Gas Pool
        _repayBold(activePoolCached, boldTokenCached, msg.sender, debt - BOLD_GAS_COMPENSATION);
        _repayBold(activePoolCached, boldTokenCached, gasPoolAddress, BOLD_GAS_COMPENSATION);

        // Send the collateral back to the user
        activePoolCached.sendETH(msg.sender, coll);
    }

    function setAddManager(uint256 _troveId, address _manager) external {
        troveManager.setAddManager(msg.sender, _troveId, _manager);
    }

    function setRemoveManager(uint256 _troveId, address _manager) external {
        troveManager.setRemoveManager(msg.sender, _troveId, _manager);
    }

    /**
     * Claim remaining collateral from a redemption or from a liquidation with ICR > MCR in Recovery Mode
     */
    function claimCollateral(uint256 _troveId) external override {
        address owner = troveManager.ownerOf(_troveId);
        require(owner == msg.sender, "BO: Only owner can claim trove collateral");

        // send ETH from CollSurplus Pool to owner
        collSurplusPool.claimColl(msg.sender, _troveId);
    }

    // --- Helper functions ---

    function _getUSDValue(uint _coll, uint _price) internal pure returns (uint) {
        uint usdValue = _price * _coll / DECIMAL_PRECISION;

        return usdValue;
    }

    // Update trove's coll and debt based on whether they increase or decrease
    function _updateTroveFromAdjustment
    (
        ITroveManager _troveManager,
        address _sender,
        uint256 _troveId,
        uint256 _coll,
        uint _collChange,
        bool _isCollIncrease,
        uint256 _debt,
        uint _debtChange,
        bool _isDebtIncrease
    )
        internal
        returns (uint, uint)
    {
        uint256 newColl;
        uint256 newDebt;

        if (_collChange > 0) {
            newColl = (_isCollIncrease) ?
                _troveManager.increaseTroveColl(_sender, _troveId, _collChange) :
                _troveManager.decreaseTroveColl(_sender, _troveId, _collChange);
        } else {
            newColl = _coll;
        }
        if (_debtChange > 0) {
            newDebt = (_isDebtIncrease) ?
                _troveManager.increaseTroveDebt(_sender, _troveId, _debtChange) :
                _troveManager.decreaseTroveDebt(_sender, _troveId, _debtChange);
        } else {
            newDebt = _debt;
        }

        return (newColl, newDebt);
    }

    function _moveTokensAndETHfromAdjustment
    (
        IActivePool _activePool,
        IBoldToken _boldToken,
        ITroveManager _troveManager,
        uint256 _troveId,
        uint _collChange,
        bool _isCollIncrease,
        uint _boldChange,
        bool _isDebtIncrease,
        uint _netDebtChange
    )
        internal
    {
        if (_isDebtIncrease) {
            address borrower = _troveManager.ownerOf(_troveId);
            _withdrawBold(_activePool, _boldToken, borrower, _boldChange, _netDebtChange);
        } else {
            _repayBold(_activePool, _boldToken, msg.sender, _boldChange);
        }

        if (_isCollIncrease) {
            // Pull ETH tokens from sender and move them to the Active Pool
            _pullETHAndSendToActivePool(_activePool, _collChange);
        } else {
            address borrower = _troveManager.ownerOf(_troveId);
            // Pull ETH from Active Pool and decrease its recorded ETH balance
            _activePool.sendETH(borrower, _collChange);
        }
    }

    function _pullETHAndSendToActivePool(IActivePool _activePool, uint256 _amount) internal {
        // Pull ETH tokens from sender (we may save gas by pulling directly from Active Pool, but then the approval UX for user would be weird)
        ETH.safeTransferFrom(msg.sender, address(this), _amount);
        // Move the ether to the Active Pool
        _activePool.receiveETH(_amount);
    }

    // Issue the specified amount of Bold to _account and increases the total active debt (_netDebtIncrease potentially includes a BoldFee)
    function _withdrawBold(IActivePool _activePool, IBoldToken _boldToken, address _account, uint _boldAmount, uint _netDebtIncrease) internal {
        _activePool.increaseBoldDebt(_netDebtIncrease);
        _boldToken.mint(_account, _boldAmount);
    }

    // Burn the specified amount of Bold from _account and decreases the total active debt
    function _repayBold(IActivePool _activePool, IBoldToken _boldToken, address _account, uint _bold) internal {
        _activePool.decreaseBoldDebt(_bold);
        _boldToken.burn(_account, _bold);
    }

    // --- 'Require' wrapper functions ---

    function _requireCallerIsBorrower(ITroveManager _troveManager , uint256 _troveId) internal view {
        require(msg.sender == _troveManager.ownerOf(_troveId), "BorrowerOps: Caller must be the borrower for a withdrawal");
    }

    function _requireNonZeroAdjustment(uint _collChange, uint _boldChange) internal pure {
        require(_collChange != 0 || _boldChange != 0, "BorrowerOps: There must be either a collateral change or a debt change");
    }

    function _requireTroveisActive(ITroveManager _troveManager, uint256 _troveId) internal view {
        uint status = _troveManager.getTroveStatus(_troveId);
        require(status == 1, "BorrowerOps: Trove does not exist or is closed");
    }

    function _requireTroveisNotActive(ITroveManager _troveManager, uint256 _troveId) internal view {
        uint status = _troveManager.getTroveStatus(_troveId);
        require(status != 1, "BorrowerOps: Trove is active");
    }

    function _requireNonZeroCollChange(uint _collChange) internal pure {
        require(_collChange > 0, "BorrowerOps: Coll increase requires non-zero collChange");
    }

    function _requireNonZeroDebtChange(uint _boldChange) internal pure {
        require(_boldChange > 0, "BorrowerOps: Debt increase requires non-zero debtChange");
    }

    function _requireNotInRecoveryMode(uint _price) internal view {
        require(!_checkRecoveryMode(_price), "BorrowerOps: Operation not permitted during Recovery Mode");
    }

    function _requireNoCollWithdrawal(uint _collWithdrawal, bool _isCollIncrease) internal pure {
        require(_collWithdrawal == 0 || _isCollIncrease, "BorrowerOps: Collateral withdrawal not permitted Recovery Mode");
    }

    function _requireValidAdjustmentInCurrentMode
    (
        bool _isRecoveryMode,
        uint _collChange,
        bool _isCollIncrease,
        bool _isDebtIncrease,
        LocalVariables_adjustTrove memory _vars
    )
        internal
        view
    {
        /*
        *In Recovery Mode, only allow:
        *
        * - Pure collateral top-up
        * - Pure debt repayment
        * - Collateral top-up with debt repayment
        * - A debt increase combined with a collateral top-up which makes the ICR >= 150% and improves the ICR (and by extension improves the TCR).
        *
        * In Normal Mode, ensure:
        *
        * - The new ICR is above MCR
        * - The adjustment won't pull the TCR below CCR
        */
        if (_isRecoveryMode) {
            _requireNoCollWithdrawal(_collChange, _isCollIncrease);
            if (_isDebtIncrease) {
                _requireICRisAboveCCR(_vars.newICR);
                _requireNewICRisAboveOldICR(_vars.newICR, _vars.oldICR);
            }
        } else { // if Normal Mode
            _requireICRisAboveMCR(_vars.newICR);
            _vars.newTCR = _getNewTCRFromTroveChange(_collChange, _isCollIncrease, _vars.netDebtChange, _isDebtIncrease, _vars.price);
            _requireNewTCRisAboveCCR(_vars.newTCR);
        }
    }

    function _requireICRisAboveMCR(uint _newICR) internal pure {
        require(_newICR >= MCR, "BorrowerOps: An operation that would result in ICR < MCR is not permitted");
    }

    function _requireICRisAboveCCR(uint _newICR) internal pure {
        require(_newICR >= CCR, "BorrowerOps: Operation must leave trove with ICR >= CCR");
    }

    function _requireNewICRisAboveOldICR(uint _newICR, uint _oldICR) internal pure {
        require(_newICR >= _oldICR, "BorrowerOps: Cannot decrease your Trove's ICR in Recovery Mode");
    }

    function _requireNewTCRisAboveCCR(uint _newTCR) internal pure {
        require(_newTCR >= CCR, "BorrowerOps: An operation that would result in TCR < CCR is not permitted");
    }

    function _requireAtLeastMinNetDebt(uint _netDebt) internal pure {
        require (_netDebt >= MIN_NET_DEBT, "BorrowerOps: Trove's net debt must be greater than minimum");
    }

    function _requireValidBoldRepayment(uint _currentDebt, uint _debtRepayment) internal pure {
        require(_debtRepayment <= _currentDebt - BOLD_GAS_COMPENSATION, "BorrowerOps: Amount repaid must not be larger than the Trove's debt");
    }

    function _requireCallerIsStabilityPool() internal view {
        require(msg.sender == stabilityPoolAddress, "BorrowerOps: Caller is not Stability Pool");
    }

     function _requireSufficientBoldBalance(IBoldToken _boldToken, address _borrower, uint _debtRepayment) internal view {
        require(_boldToken.balanceOf(_borrower) >= _debtRepayment, "BorrowerOps: Caller doesnt have enough Bold to make repayment");
    }

    function _requireValidMaxFeePercentage(uint _maxFeePercentage, bool _isRecoveryMode) internal pure {
        if (_isRecoveryMode) {
            require(_maxFeePercentage <= DECIMAL_PRECISION,
                "Max fee percentage must less than or equal to 100%");
        } else {
            require(_maxFeePercentage >= BORROWING_FEE_FLOOR && _maxFeePercentage <= DECIMAL_PRECISION,
                "Max fee percentage must be between 0.5% and 100%");
        }
    }

    function _requireValidAnnualInterestRate(uint256 _annualInterestRate) internal pure {
        require(_annualInterestRate <= MAX_ANNUAL_INTEREST_RATE, "Interest rate must not be greater than max");
    }

    // --- ICR and TCR getters ---

    // Compute the new collateral ratio, considering the change in coll and debt. Assumes 0 pending rewards.
    function _getNewICRFromTroveChange
    (
        uint _coll,
        uint _debt,
        uint _collChange,
        bool _isCollIncrease,
        uint _debtChange,
        bool _isDebtIncrease,
        uint _price
    )
        pure
        internal
        returns (uint)
    {
        (uint newColl, uint newDebt) = _getNewTroveAmounts(_coll, _debt, _collChange, _isCollIncrease, _debtChange, _isDebtIncrease);

        uint newICR = LiquityMath._computeCR(newColl, newDebt, _price);
        return newICR;
    }

    function _getNewTroveAmounts(
        uint _coll,
        uint _debt,
        uint _collChange,
        bool _isCollIncrease,
        uint _debtChange,
        bool _isDebtIncrease
    )
        internal
        pure
        returns (uint, uint)
    {
        uint newColl = _coll;
        uint newDebt = _debt;

        newColl = _isCollIncrease ? _coll + _collChange :  _coll - _collChange;
        newDebt = _isDebtIncrease ? _debt + _debtChange : _debt - _debtChange;

        return (newColl, newDebt);
    }

    function _getNewTCRFromTroveChange
    (
        uint _collChange,
        bool _isCollIncrease,
        uint _debtChange,
        bool _isDebtIncrease,
        uint _price
    )
        internal
        view
        returns (uint)
    {
        uint totalColl = getEntireSystemColl();
        uint totalDebt = getEntireSystemDebt();

        totalColl = _isCollIncrease ? totalColl + _collChange : totalColl - _collChange;
        totalDebt = _isDebtIncrease ? totalDebt + _debtChange : totalDebt - _debtChange;

        uint newTCR = LiquityMath._computeCR(totalColl, totalDebt, _price);
        return newTCR;
    }

    function getCompositeDebt(uint _debt) external pure override returns (uint) {
        return _getCompositeDebt(_debt);
    }
}
