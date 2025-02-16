// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {IBorrowerOperations} from "src/Interfaces/IBorrowerOperations.sol";
import {Properties} from "../../../Properties.sol";
import {Manager} from "../../../managers/Manager.sol";
import {vm} from "@chimera/Hevm.sol";

abstract contract BORaw is BaseTargetFunctions, Properties, Manager {
    // //NOTE Raw borrow operation file, with access control clamping only and actor clamping.

    //Active Trove
    function BO_addColl(uint256 _collAmount) public {
        borrowerOperations.addColl(currentTrove, _collAmount);
    }
    //ActiveTrove

    function BO_adjustTrove(
        uint256 _collChange,
        bool _isCollIncrease,
        uint256 _boldChange,
        bool _isDebtIncrease,
        uint256 _maxUpfrontFee
    ) public {
        borrowerOperations.adjustTrove(
            currentTrove, _collChange, _isCollIncrease, _boldChange, _isDebtIncrease, _maxUpfrontFee
        );
    }

    /**
     * _requireIsNotShutDown();
     *
     *     ITroveManager troveManagerCached = troveManager;
     *
     *     _requireValidAnnualInterestRate(_newAnnualInterestRate); yes
     *     _requireIsNotInBatch(_troveId); no idea
     *     _requireSenderIsOwnerOrInterestManager(_troveId); ok
     *     _requireTroveIsActive(troveManagerCached, _troveId); ok
     *
     *     _requireValidDelegateAdustment(_troveId, trove.lastInterestRateAdjTime, _newAnnualInterestRate); for now can skip it because interestIndividualDelegateOf
     *     _requireAnnualInterestRateIsNew(trove.annualInterestRate, _newAnnualInterestRate); yes
     */
    function BO_adjustTroveInterestRate(
        uint256 _newAnnualInterestRate,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _maxUpfrontFee
    ) public {
        borrowerOperations.adjustTroveInterestRate(
            currentTrove, _newAnnualInterestRate, _upperHint, _lowerHint, _maxUpfrontFee
        );
    }
    //zombie trove

    function BO_adjustZombieTrove(
        uint256 zombieTrove,
        uint256 _collChange,
        bool _isCollIncrease,
        uint256 _boldChange,
        bool _isDebtIncrease,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _maxUpfrontFee
    ) public {
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
    //  not shut, open, zero debt

    function BO_applyPendingDebt(uint256 _lowerHint, uint256 _upperHint) public {
        //NOTE Do I need to clamp it ?
        borrowerOperations.applyPendingDebt(currentTrove, _lowerHint, _upperHint);
    }
    //

    function BO_claimCollateral() public {
        //NOTE no clamp
        borrowerOperations.claimCollateral();
    }
    /**
     * _requireSenderIsOwnerOrRemoveManagerAndGetReceiver
     * _requireTroveIsOpen
     * _requireSufficientBoldBalance NOTE Set oracle
     */

    function BO_closeTrove() public {
        borrowerOperations.closeTrove(currentTrove);
    }
    /**
     * _requireIsNotShutDown();
     *     _requireValidInterestBatchManager(msg.sender);
     */

    function BO_lowerBatchManagementFee(uint256 _newAnnualManagementFee) public {
        borrowerOperations.lowerBatchManagementFee(_newAnnualManagementFee);
    }
    /**
     * _requireCallerIsTroveManager();
     */

    function BO_onLiquidateTrove(uint256 _troveId) public {
        borrowerOperations.onLiquidateTrove(_troveId);
    }
    /**
     * _requireValidAnnualInterestRate(_annualInterestRate);
     */
    //NOTE adds trove to the dictionary ?

    function BO_openTrove(
        uint256 _ownerIndex,
        uint256 _collAmount,
        uint256 _boldAmount,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _annualInterestRate,
        uint256 _maxUpfrontFee,
        address _addManager,
        address _removeManager,
        address _receiver
    ) public returns (uint256 troveId) {
        troveId = borrowerOperations.openTrove(
            currentUser,
            _ownerIndex,
            _collAmount,
            _boldAmount,
            _upperHint,
            _lowerHint,
            _annualInterestRate,
            _maxUpfrontFee,
            _addManager,
            _removeManager,
            _receiver
        );
    }

    /**
     * _requireValidInterestBatchManager
     */
    function BO_openTroveAndJoinInterestBatchManager(
        IBorrowerOperations.OpenTroveAndJoinInterestBatchManagerParams memory _params
    ) public {
        borrowerOperations.openTroveAndJoinInterestBatchManager(_params);
    }
    /**
     * _requireIsNotShutDown();
     *     _requireNonExistentInterestBatchManager(msg.sender);
     *     _requireValidAnnualInterestRate(_minInterestRate);
     *     _requireValidAnnualInterestRate(_maxInterestRate);
     *     // With the check below, it could only be ==
     *     _requireOrderedRange(_minInterestRate, _maxInterestRate);
     *     _requireInterestRateInRange(_currentInterestRate, _minInterestRate, _maxInterestRate);
     *     // Not needed, implicitly checked in the condition above:
     *     //_requireValidAnnualInterestRate(_currentInterestRate);
     *     if (_annualManagementFee > MAX_ANNUAL_BATCH_MANAGEMENT_FEE) revert AnnualManagementFeeTooHigh();
     *     if (_minInterestRateChangePeriod < MIN_INTEREST_RATE_CHANGE_PERIOD) revert MinInterestRateChangePeriodTooLow();
     * ok?
     */

    function BO_registerBatchManager(
        uint128 _minInterestRate,
        uint128 _maxInterestRate,
        uint128 _currentInterestRate,
        uint128 _annualManagementFee,
        uint128 _minInterestRateChangePeriod
    ) public {
        borrowerOperations.registerBatchManager(
            _minInterestRate, _maxInterestRate, _currentInterestRate, _annualManagementFee, _minInterestRateChangePeriod
        );
    }
    /**
     * _requireTroveIsActive(vars.troveManager, _troveId);
     *     _requireCallerIsBorrower(_troveId);
     *     _requireValidAnnualInterestRate(_newAnnualInterestRate);
     *  should go through
     */

    function BO_removeFromBatch(
        uint256 _newAnnualInterestRate,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _maxUpfrontFee
    ) public {
        borrowerOperations.removeFromBatch(currentTrove, _newAnnualInterestRate, _upperHint, _lowerHint, _maxUpfrontFee);
    }
    /**
     * _requireCallerIsBorrower(_troveId);
     *
     *  NOTE  no check active trove ??
     *  using only active troves for now, might be a mistake
     */

    function BO_removeInterestIndividualDelegate() public {
        borrowerOperations.removeInterestIndividualDelegate(currentTrove);
    }
    /**
     * _requireTroveIsActive
     */

    function BO_repayBold(uint256 _boldAmount) public {
        borrowerOperations.repayBold(currentTrove, _boldAmount);
    }
    /**
     * _requireCallerIsBorrower(_troveId);
     * NOTe only gonna go for active troves for now, could clamp manager to userOnly
     * //NOTE Should I clamp managers to specific user addresses ? probably
     */

    function BO_setAddManager(address _manager) public {
        borrowerOperations.setAddManager(currentTrove, _manager);
    }
    /**
     * _requireIsNotShutDown();
     *     _requireValidInterestBatchManager(msg.sender);
     *     _requireInterestRateInBatchManagerRange(msg.sender, _newAnnualInterestRate);
     *     _requireBatchInterestRateChangePeriodPassed(msg.sender, uint256(batch.lastInterestRateAdjTime));
     *     NOTE should let some time pass, but not sure about it, such as how much time 
     */

    function BO_setBatchManagerAnnualInterestRate(
        uint128 _newAnnualInterestRate,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _maxUpfrontFee
    ) public {
        borrowerOperations.setBatchManagerAnnualInterestRate(
            _newAnnualInterestRate, _upperHint, _lowerHint, _maxUpfrontFee
        );
    }
    /**
     * _requireIsNotShutDown();
     *   _requireTroveIsActive(vars.troveManager, _troveId);
     *     _requireCallerIsBorrower(_troveId);
     *     _requireValidInterestBatchManager(_newBatchManager);
     *     _requireIsNotInBatch(_troveId);
     note no clamping for now
     */

    function BO_setInterestBatchManager(
        address _newBatchManager,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _maxUpfrontFee
    ) public {
        borrowerOperations.setInterestBatchManager(
            currentTrove, _newBatchManager, _upperHint, _lowerHint, _maxUpfrontFee
        );
    }
    /**
     * requireIsNotShutDown();
     *     _requireTroveIsActive(troveManager, _troveId);
     *     _requireCallerIsBorrower(_troveId);
     *     _requireValidAnnualInterestRate(_minInterestRate);
     *     _requireValidAnnualInterestRate(_maxInterestRate);
     *     // With the check below, it could only be ==
     *     _requireOrderedRange(_minInterestRate, _maxInterestRate);
     NOTE ok
     */

    function BO_setInterestIndividualDelegate(
        address _delegate,
        uint128 _minInterestRate,
        uint128 _maxInterestRate,
        uint256 _newAnnualInterestRate,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _maxUpfrontFee,
        uint256 _minInterestRateChangePeriod
    ) public {
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
    /**
     * _requireCallerIsBorrower(_troveId);
     *
     *     //NOTE could clamp to users and managers
     */

    function BO_setRemoveManager(uint256 _troveId, address _manager) public {
        borrowerOperations.setRemoveManager(_troveId, _manager);
    }
    /**
     * _requireCallerIsBorrower(_troveId);
     */

    function BO_setRemoveManagerWithReceiver(uint256 _troveId, address _manager, address _receiver) public {
        borrowerOperations.setRemoveManagerWithReceiver(_troveId, _manager, _receiver);
    }
    /**
     * not shutdown
     */

    function BO_shutdown() public {
        borrowerOperations.shutdown();
        revert("lets reach coverage");
    }
    /**
     * _requireCallerIsPriceFeed
     */

    function BO_shutdownFromOracleFailure() public {
        borrowerOperations.shutdownFromOracleFailure();
        revert("lets reach coverage");

    }
    /**
     * address oldBatchManager = _requireIsInBatch(_troveId);
     *     _requireNewInterestBatchManager(oldBatchManager, _newBatchManager);
     note Nothing for now
     */

    function BO_switchBatchManager(
        uint256 _troveId,
        uint256 _removeUpperHint,
        uint256 _removeLowerHint,
        address _newBatchManager,
        uint256 _addUpperHint,
        uint256 _addLowerHint,
        uint256 _maxUpfrontFee
    ) public {
        borrowerOperations.switchBatchManager(
            _troveId, _removeUpperHint, _removeLowerHint, _newBatchManager, _addUpperHint, _addLowerHint, _maxUpfrontFee
        );
    }
    /**
     * _requireTroveIsActive(troveManagerCached, _troveId);
     note no clamping for now
     */

    function BO_withdrawBold(uint256 _troveId, uint256 _boldAmount, uint256 _maxUpfrontFee) public {
        borrowerOperations.withdrawBold(_troveId, _boldAmount, _maxUpfrontFee);
    }
    /**
     * _requireTroveIsActive(troveManagerCached, _troveId);
     note no clamping for now
     */

    function BO_withdrawColl(uint256 _troveId, uint256 _collWithdrawal) public {
        borrowerOperations.withdrawColl(_troveId, _collWithdrawal);
    }
}
