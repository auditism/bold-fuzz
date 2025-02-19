// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {TargetFunctions} from "./TargetFunctions.sol";
import {FoundryAsserts} from "@chimera/FoundryAsserts.sol";
import {console} from "forge-std/console.sol";
import {LatestTroveData} from "src/Types/LatestTroveData.sol";
//forge test --match-test test_crytically -vvvv

contract CryticToFoundry is Test, TargetFunctions, FoundryAsserts {
    function setUp() public {
        setup();
    }

    function test_crytic() public {
        currentUser = users[0];
        mintColl(100000000e18);
        mintColl(100000e18);
        mintWeth(1000e18);

        switch_randomUnit(1);
        priceFeed_setPrice(2000e18);
        clamped_registerBatchManager(1.5e18, 2e18, 1.7e18, 0, 1 days);
        clamped_openTroveAndJoinInterestBatchManager(11e18, 2000e18);
        switch_batchTrove(1);
        console.log(currentBatchTrove);
        console.log("1");

        switch_trove(0);

        priceFeed_setRedemptionPrice(20000e18);
        collateralRegistry.redeemCollateral(500e18, 10, 1e18);
        findZombies();
        switch_zombie(0);
        console.log(currentZombieTrove);
        clamped_adjustZombieTrove(1e18, true, 10000e18, true, 1000e18);
    }
    function test_crytik() public {
        currentUser = users[0];
        mintColl(100000000e18);
        mintColl(100000e18);
        mintWeth(1000e18);
        switch_randomUnit(1);
                priceFeed_setPrice(2000e18);
        clamped_open_trove(10e18, 2000e18, 25e16);
        priceFeed_setRedemptionPrice(2000e18);
        collateralRegistry.redeemCollateral(1000e18, 10, 1e18);
        findZombies();
        switch_zombie(0);
        clamped_adjustZombieTrove(0, false, 1100e18, true, 100e18);
        BO_applyPendingDebt(currentZombieTrove, 0, 0);
        t(false, "QnD");

    }

    // function test_crytical() public {
    //     uint256 MIN_DEBT = 2000e18;
    //     switch_user(0);
    //     mintTokenToAll(100000e18);
    //     mintWeth(1000e18);
    //     priceFeed_setPrice(2000e18);

    //     // Open trove with 10 ETH collateral and 2000e18 BOLD debt + upfront fee
    //     clamped_open_trove(10e18, 2000e18, 25e16);

    //     switch_trove(0);
    //     priceFeed_setRedemptionPrice(2000e18);
    //     uint256 redeem = getTheTroveEntireDebt(currentTrove);
    //     collateralRegistry.redeemCollateral(1000e18, 10, 1e18);
    //     findZombies();
    //     console.log('HERE');
    //     clamped_adjustZombieTrove(1e18, true, 10000e18, true, 100e18);

    // }
    // function test_crytically() public {
    //     uint256 MIN_DEBT = 2000e18;
    //     switch_user(0);
    //     mintTokenToAll(100000e18);
    //     mintWeth(1000e18);
    //     priceFeed_setPrice(2000e18);

    //     // Open trove with 10 ETH collateral and 2000e18 BOLD debt + upfront fee
    //     clamped_open_trove(10e18, 2000e18, 25e16);

    //     switch_trove(0);
    //     BO_withdrawBold(currentTrove, 10e18, 2e18);

    // }

    function getTheTroveEntireDebt(uint256 _troveId) internal view returns (uint256) {
        LatestTroveData memory trove = troveManager.getLatestTroveData(_troveId);
        return trove.entireDebt;
    }


}
