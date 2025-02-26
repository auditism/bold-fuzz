// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {IBorrowerOperations} from "src/Interfaces/IBorrowerOperations.sol";
import {Properties} from "../../../Properties.sol";
import {Manager} from "../../../managers/Manager.sol";
import {vm} from "@chimera/Hevm.sol";

abstract contract BORaw is BaseTargetFunctions, Properties, Manager {
    function BO_addColl(uint256 _collAmount) public beforeAfter {
        borrowerOperations.addColl(currentTrove, _collAmount);
    }

    function BO_adjustTrove(
        uint256 _collChange,
        bool _isCollIncrease,
        uint256 _boldChange,
        bool _isDebtIncrease,
        uint256 _maxUpfrontFee
    ) public beforeAfter {
        borrowerOperations.adjustTrove(
            currentTrove, _collChange, _isCollIncrease, _boldChange, _isDebtIncrease, _maxUpfrontFee
        );
    }

    function BO_adjustTroveInterestRate(uint256 _newAnnualInterestRate, uint256 _maxUpfrontFee) public beforeAfter {
        borrowerOperations.adjustTroveInterestRate(currentTrove, _newAnnualInterestRate, 0, 0, _maxUpfrontFee);
    }

    function BO_adjustZombieTrove(
        uint256 zombieTrove,
        uint256 _collChange,
        bool _isCollIncrease,
        uint256 _boldChange,
        bool _isDebtIncrease,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _maxUpfrontFee
    ) public beforeAfter {
        borrowerOperations.adjustZombieTrove(
            zombieTrove,
            _collChange,
            _isCollIncrease,
            _boldChange,
            _isDebtIncrease,
            _upperHint,
            _lowerHint,
            _maxUpfrontFee
        );
    }

    function BO_applyPendingDebt(uint256 trove, uint256 _lowerHint, uint256 _upperHint) public beforeAfter {
        borrowerOperations.applyPendingDebt(trove, _lowerHint, _upperHint);
    }

    function BO_claimCollateral() public beforeAfter {
        borrowerOperations.claimCollateral();
    }

    function BO_closeTrove() public beforeAfter {
        borrowerOperations.closeTrove(currentTrove);
    }

    function BO_lowerBatchManagementFee(uint256 _newAnnualManagementFee) public beforeAfter {
        borrowerOperations.lowerBatchManagementFee(_newAnnualManagementFee);
    }

    function BO_onLiquidateTrove(uint256 _troveId) public beforeAfter {
        borrowerOperations.onLiquidateTrove(_troveId);
    }

    function BO_openTrove(uint256 _collAmount, uint256 _boldAmount, uint256 _annualInterestRate)
        public
        beforeAfter
        returns (uint256 troveId)
    {
        uint256 maxUpfrontFee = hintHelpers.predictOpenTroveUpfrontFee(0, _boldAmount, _annualInterestRate);
        troveId = borrowerOperations.openTrove(
            currentUser,
            0,
            _collAmount,
            _boldAmount,
            0,
            0,
            _annualInterestRate,
            maxUpfrontFee,
            address(0),
            address(0),
            address(0)
        );
    }

    function BO_openTroveAndJoinInterestBatchManager(
        IBorrowerOperations.OpenTroveAndJoinInterestBatchManagerParams memory _params
    ) public beforeAfter returns (uint256 trove) {
        trove = borrowerOperations.openTroveAndJoinInterestBatchManager(_params);
        activeTroves.push(trove);
        batchTroves.push(trove);
        mixedTroves.push(trove);
    }

    function BO_registerBatchManager(
        uint128 _minInterestRate,
        uint128 _maxInterestRate,
        uint128 _currentInterestRate,
        uint128 _annualManagementFee,
        uint128 _minInterestRateChangePeriod
    ) public beforeAfter randomUser {
        borrowerOperations.registerBatchManager(
            _minInterestRate, _maxInterestRate, _currentInterestRate, _annualManagementFee, _minInterestRateChangePeriod
        );
    }

    function BO_removeFromBatch(
        uint256 _newAnnualInterestRate,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _maxUpfrontFee
    ) public beforeAfter {
        borrowerOperations.removeFromBatch(currentTrove, _newAnnualInterestRate, _upperHint, _lowerHint, _maxUpfrontFee);
    }

    function BO_removeInterestIndividualDelegate() public beforeAfter {
        borrowerOperations.removeInterestIndividualDelegate(currentTrove);
    }

    function BO_repayBold(uint256 _boldAmount) public beforeAfter {
        borrowerOperations.repayBold(currentTrove, _boldAmount);
    }

    function BO_setAddManager(address _manager) public beforeAfter {
        borrowerOperations.setAddManager(currentTrove, _manager);
    }

    function BO_setBatchManagerAnnualInterestRate(
        uint128 _newAnnualInterestRate,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _maxUpfrontFee
    ) public beforeAfter {
        borrowerOperations.setBatchManagerAnnualInterestRate(
            _newAnnualInterestRate, _upperHint, _lowerHint, _maxUpfrontFee
        );
    }

    function BO_setInterestBatchManager(
        address _newBatchManager,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _maxUpfrontFee
    ) public beforeAfter {
        borrowerOperations.setInterestBatchManager(
            currentNormalTrove, currentBatchManager, _upperHint, _lowerHint, _maxUpfrontFee
        );
    }

    function BO_setInterestIndividualDelegate(
        address _delegate,
        uint128 _minInterestRate,
        uint128 _maxInterestRate,
        uint256 _newAnnualInterestRate,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _maxUpfrontFee,
        uint256 _minInterestRateChangePeriod
    ) public beforeAfter {
        borrowerOperations.setInterestIndividualDelegate(
            currentTrove,
            _delegate,
            _minInterestRate,
            _maxInterestRate,
            _newAnnualInterestRate,
            _upperHint,
            _lowerHint,
            _maxUpfrontFee,
            _minInterestRateChangePeriod
        );
    }

    function BO_setRemoveManager(uint256 _troveId, address _manager) public beforeAfter {
        borrowerOperations.setRemoveManager(_troveId, _manager);
    }

    function BO_setRemoveManagerWithReceiver(uint256 _troveId, address _manager, address _receiver)
        public
        beforeAfter
    {
        borrowerOperations.setRemoveManagerWithReceiver(_troveId, _manager, _receiver);
    }

    function BO_shutdown() public beforeAfter {
        borrowerOperations.shutdown();
        // revert("Stateless");
    }

    function BO_shutdownFromOracleFailure() public beforeAfter {
        borrowerOperations.shutdownFromOracleFailure();
        // revert("lets reach coverage");
    }

    function BO_switchBatchManager(
        uint256 _removeUpperHint,
        uint256 _removeLowerHint,
        address _newBatchManager,
        uint256 _addUpperHint,
        uint256 _addLowerHint,
        uint256 _maxUpfrontFee
    ) public beforeAfter {
        borrowerOperations.switchBatchManager(
            currentBatchTrove,
            _removeUpperHint,
            _removeLowerHint,
            _newBatchManager,
            _addUpperHint,
            _addLowerHint,
            _maxUpfrontFee
        );
    }

    function BO_withdrawBold(uint256 _troveId, uint256 _boldAmount, uint256 _maxUpfrontFee) public beforeAfter {
        borrowerOperations.withdrawBold(_troveId, _boldAmount, _maxUpfrontFee);
    }

    function BO_withdrawColl(uint256 _troveId, uint256 _collWithdrawal) public beforeAfter {
        borrowerOperations.withdrawColl(_troveId, _collWithdrawal);
    }
}
