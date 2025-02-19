// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {IBorrowerOperations} from "src/Interfaces/IBorrowerOperations.sol";
import {Properties} from "../../../Properties.sol";
import {Manager} from "../../../managers/Manager.sol";
import {vm} from "@chimera/Hevm.sol";

abstract contract BORaw is BaseTargetFunctions, Properties, Manager {
    function BO_addColl(uint256 _collAmount) public {
        borrowerOperations.addColl(currentTrove, _collAmount);
    }

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

    function BO_adjustTroveInterestRate(uint256 _newAnnualInterestRate, uint256 _maxUpfrontFee) public {
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

    function BO_applyPendingDebt(uint256 trove, uint256 _lowerHint, uint256 _upperHint) public {
        borrowerOperations.applyPendingDebt(trove, _lowerHint, _upperHint);
    }

    function BO_claimCollateral() public {
        borrowerOperations.claimCollateral();
    }

    function BO_closeTrove() public {
        borrowerOperations.closeTrove(currentTrove);
        t(false, 'QuickCana');
    }

    function BO_lowerBatchManagementFee(uint256 _newAnnualManagementFee) public {
        borrowerOperations.lowerBatchManagementFee(_newAnnualManagementFee);
    }

    function BO_onLiquidateTrove(uint256 _troveId) public {
        borrowerOperations.onLiquidateTrove(_troveId);
    }

    function BO_openTrove(uint256 _collAmount, uint256 _boldAmount, uint256 _annualInterestRate)
        public
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
    ) public returns (uint256 trove) {
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
    ) public randomUser {
        borrowerOperations.registerBatchManager(
            _minInterestRate, _maxInterestRate, _currentInterestRate, _annualManagementFee, _minInterestRateChangePeriod
        );
    }

    function BO_removeFromBatch(
        uint256 _newAnnualInterestRate,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _maxUpfrontFee
    ) public {
        borrowerOperations.removeFromBatch(currentTrove, _newAnnualInterestRate, _upperHint, _lowerHint, _maxUpfrontFee);
    }

    function BO_removeInterestIndividualDelegate() public {
        borrowerOperations.removeInterestIndividualDelegate(currentTrove);
    }

    function BO_repayBold(uint256 _boldAmount) public {
        borrowerOperations.repayBold(currentTrove, _boldAmount);
    }

    function BO_setAddManager(address _manager) public {
        borrowerOperations.setAddManager(currentTrove, _manager);
    }

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

    function BO_setInterestBatchManager(
        address _newBatchManager,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _maxUpfrontFee
    ) public {
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

    function BO_setRemoveManager(uint256 _troveId, address _manager) public {
        borrowerOperations.setRemoveManager(_troveId, _manager);
    }

    function BO_setRemoveManagerWithReceiver(uint256 _troveId, address _manager, address _receiver) public {
        borrowerOperations.setRemoveManagerWithReceiver(_troveId, _manager, _receiver);
    }

    function BO_shutdown() public {
        borrowerOperations.shutdown();
        // revert("Stateless");
    }

    function BO_shutdownFromOracleFailure() public {
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
    ) public {
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

    function BO_withdrawBold(uint256 _troveId, uint256 _boldAmount, uint256 _maxUpfrontFee) public {
        borrowerOperations.withdrawBold(_troveId, _boldAmount, _maxUpfrontFee);
    }

    function BO_withdrawColl(uint256 _troveId, uint256 _collWithdrawal) public {
        borrowerOperations.withdrawColl(_troveId, _collWithdrawal);
    }
}
