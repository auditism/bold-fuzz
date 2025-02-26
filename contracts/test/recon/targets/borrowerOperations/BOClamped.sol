// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BORaw} from "./borrowerOperationsRaw/BORaw.sol";
import {BOHelpers} from "./BOHelpers.sol";
import {IBorrowerOperations} from "src/Interfaces/IBorrowerOperations.sol";
import {LatestTroveData} from "src/Types/LatestTroveData.sol";
import {vm} from "@chimera/Hevm.sol";

abstract contract BOClamped is BORaw, BOHelpers {
    /**
     * Here we clamp the _annualInterestRate
     */
    function clamped_open_trove(uint256 _collAmount, uint256 _boldAmount, uint128 _annualInterestRate)
        public
        returns (uint256)
    {
        _annualInterestRate = _fix_interest_rate(_annualInterestRate);
        _collAmount %= collateral.balanceOf(currentUser) + 1;
        uint256 trove = BO_openTrove(_collAmount, _boldAmount, uint256(_annualInterestRate));
        activeTroves.push(trove);
        normalTroves.push(trove);
        mixedTroves.push(trove);
        return trove;
    }

    function clamped_openTroveAndJoinInterestBatchManager(uint256 collAmount, uint256 boldAmount) public {
        IBorrowerOperations.OpenTroveAndJoinInterestBatchManagerParams memory _params =
            _return_batch_open_trove_params(collAmount, boldAmount);
        BO_openTroveAndJoinInterestBatchManager(_params);
    }

    // NOTE caller is owner, but should create option where caller is interestManager
    function clamped_adjustTroveInterestRate(uint128 _newAnnualInterestRate) public {
        _newAnnualInterestRate = _fix_interest_rate(_newAnnualInterestRate);
        uint256 _maxUpfrontFee =
            hintHelpers.predictAdjustInterestRateUpfrontFee(0, currentTrove, _newAnnualInterestRate);
        BO_adjustTroveInterestRate(uint256(_newAnnualInterestRate), _maxUpfrontFee);
    }

    //NOTE //msg.sender is batch manager
    function clamped_registerBatchManager(
        uint128 _minInterestRate,
        uint128 _maxInterestRate,
        uint128 _currentInterestRate,
        uint128 _annualManagementFee,
        uint128 _minInterestRateChangePeriod
    ) public {
        _minInterestRate = _fix_interest_rate(_minInterestRate);
        _maxInterestRate = _fix_interest_rate(_maxInterestRate);
        (_minInterestRate, _maxInterestRate, _minInterestRateChangePeriod) = _fix_max_min_interest(
            _minInterestRate, _maxInterestRate, uint128(_currentInterestRate), _minInterestRateChangePeriod
        );

        BO_registerBatchManager(
            _minInterestRate, _maxInterestRate, _currentInterestRate, _annualManagementFee, _minInterestRateChangePeriod
        );
        batchManagers.push(users[randomUnit]);
    }

    function clamped_setInterestIndividualDelegate(
        uint128 _minInterestRate,
        uint128 _maxInterestRate,
        uint128 _newAnnualInterestRate,
        uint256 _maxUpfrontFee,
        uint128 _minInterestRateChangePeriod
    ) public {
        address delegate = _return_random_User();
        _minInterestRate = _fix_interest_rate(_minInterestRate);
        _maxInterestRate = _fix_interest_rate(_maxInterestRate);

        (_minInterestRate, _maxInterestRate, _minInterestRateChangePeriod) = _fix_max_min_interest(
            _minInterestRate, _maxInterestRate, _newAnnualInterestRate, _minInterestRateChangePeriod
        );
        BO_setInterestIndividualDelegate(
            delegate,
            _minInterestRate,
            _maxInterestRate,
            _newAnnualInterestRate,
            0,
            0,
            _maxUpfrontFee,
            _minInterestRateChangePeriod
        );
    }

    function clamped_setBatchManagerAnnualInterestRate(uint128 _newAnnualInterestRate, uint256 _maxUpfrontFee) public {
        _newAnnualInterestRate = _fix_interest_BM_rate(msg.sender, _newAnnualInterestRate); //NOTE fix clamping
        BO_setBatchManagerAnnualInterestRate(_newAnnualInterestRate, 0, 0, _maxUpfrontFee);
    }

    function clamped_adjustZombieTrove(
        uint256 _collChange,
        bool _isCollIncrease,
        uint256 _boldChange,
        bool _isDebtIncrease,
        uint256 _maxUpfrontFee,
        uint256 _maxIterationsPerCollateral,
        uint256 _maxFeePercentage
    ) public {
        macro_createZombie(_maxIterationsPerCollateral, _maxFeePercentage);
        findZombies();
        switch_zombie(0);
        // BO_adjustZombieTrove(
        //     currentZombieTrove, _collChange, _isCollIncrease, _boldChange, _isDebtIncrease, 0, 0, _maxUpfrontFee
        // );
        BO_adjustZombieTrove(
            currentZombieTrove,
            0,
            false,
            2000e18,
            true,
            0,
            0,
            _maxUpfrontFee //mega clamping
        );
        // t(false, 'QnD');
    }

    function clamped_applyPendingDebt() public {
        BO_applyPendingDebt(currentMixedTrove, 0, 0);
    }

    function clamped_zombie_applyPendingDebt() public {
        BO_applyPendingDebt(currentZombieTrove, 0, 0);
    }

    function macro_createZombie(uint256 _maxIterationsPerCollateral, uint256 _maxFeePercentage) public {
        uint256 targetTrove = sortedTroves.getLast();
        uint256 troveDebt = _return_trove_debt(targetTrove);
        uint256 factor = troveDebt / 2000e18;
        uint256 redemptionAmount = (factor * 2000e18);

        collateralRegistry.redeemCollateral(redemptionAmount, _maxIterationsPerCollateral, _maxFeePercentage);
    }

    function _return_trove_debt(uint256 troveId) internal view returns (uint256) {
        LatestTroveData memory trove = troveManager.getLatestTroveData(troveId);
        return trove.entireDebt;
    }
}
