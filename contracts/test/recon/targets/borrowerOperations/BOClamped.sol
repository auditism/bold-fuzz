// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BORaw} from "./borrowerOperationsRaw/BORaw.sol";
import {BOHelpers} from "./BOHelpers.sol";
import {IBorrowerOperations} from "src/Interfaces/IBorrowerOperations.sol";
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
        uint256 _maxUpfrontFee, //NOTE I CAN REMOVE THIS ?
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
        uint256 _maxUpfrontFee
    ) public {
        BO_adjustZombieTrove(
            currentZombieTrove, _collChange, _isCollIncrease, _boldChange, _isDebtIncrease, 0, 0, _maxUpfrontFee
        );
    }

    function clamped_applyPendingDebt() public {
        BO_applyPendingDebt(currentMixedTrove, 0, 0);
    }

    function clamped_zombie_applyPendingDebt() public {
        BO_applyPendingDebt(currentZombieTrove, 0, 0);
        t(false, "QnD");
    }

    /////////////////////////////////////////////////////////////////////////
    function stateless_withdrawBold() public {
        currentTrove = clamped_open_trove(10e18, 2000e18, 24e16);
        BO_withdrawBold(currentTrove, 10e18, 2e18);
        revert("stateless");
    }

    function stateless_withdrawColl() public {
        currentTrove = clamped_open_trove(10e18, 2000e18, 23e16);
        BO_withdrawColl(currentTrove, 1e18);
        revert("stateless");
    }

    function stateless_createZombie(uint256 price) public {
        clamped_open_trove(10e18, 2000e18, 25e16);
        priceFeed.setRedemptionPrice(price);
        collateralRegistry.redeemCollateral(1000e18, 10, 1e18);
        revert("stateless");
    }

    function stateless_zombie_applyPendingDebt(
        uint256 boldAmt,
        bool increaseDebt,
        uint256 maxFee,
        uint256 redemtpionPrice
    ) public {
        clamped_open_trove(10e18, 2000e18, 25e16);
        priceFeed.setRedemptionPrice(redemtpionPrice);
        collateralRegistry.redeemCollateral(1000e18, 10, 1e18);
        clamped_adjustZombieTrove(0, false, boldAmt, true, maxFee);
        BO_applyPendingDebt(currentZombieTrove, 0, 0);
        t(false, "QnD");
        revert("stateless");
    }

    function stateless_adjustZombie() public {
        clamped_open_trove(10e18, 2000e18, 25e16);
        switch_trove(0);
        priceFeed.setRedemptionPrice(2000e18);
        collateralRegistry.redeemCollateral(1000e18, 10, 1e18);
        findZombies();
        clamped_adjustZombieTrove(0, false, 1100e18, true, 100e18);
        revert("stateless");
    }

    function stateless_zombie_adjust_batch() public {
        clamped_openTroveAndJoinInterestBatchManager(11e18, 2000e18);
        priceFeed.setRedemptionPrice(20000e18);
        collateralRegistry.redeemCollateral(500e18, 10, 1e18);
        findZombies();
        switch_zombie(0);
        clamped_adjustZombieTrove(1e18, true, 10000e18, true, 1000e18);
        revert("stateless");
    }

    function stateless_close_trove(uint256 amt) public {
        clamped_open_trove(10e18, 2000e18, 25e16);
        mintBold(amt);
        BO_closeTrove();
        revert('stateless');
    }
}
