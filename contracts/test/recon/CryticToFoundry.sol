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

    function test_adjustZombie() public {
        //applyPending debt zombie
        currentUser = users[0];
        mintColl(100000000e18);
        mintColl(100000e18);
        mintWeth(1000e18);
        switch_randomUnit(1);
        priceFeed_setPrice(2000e18);
        clamped_open_trove(10e18, 2000e18, 25e16);
        priceFeed_setRedemptionPrice(2000e18);
        // macro_createZombie(10, 1e18);
        // findZombies();
        // switch_zombie(0);
        clamped_adjustZombieTrove(0, false, 2000e18, true, 100e18, 10, 1e18);
        BO_applyPendingDebt(currentZombieTrove, 0, 0);
    }

    function test_applyZombieDebt() public {
        //applyPending debt zombie
        currentUser = users[0];
        mintColl(100000000e18);
        // mintColl(100000e18);
        mintWeth(1000e18);
        switch_randomUnit(1);
        priceFeed_setPrice(20000e18);
        clamped_open_trove(10e18, 2000e18, 25e16);
        priceFeed_setRedemptionPrice(2000e18);
        macro_createZombie(10, 1e18);
        findZombies();
        switch_zombie(0);
        clamped_adjustZombieTrove(0, false, 2000e18, true, 100e18, 10, 1e18);
        BO_applyPendingDebt(currentZombieTrove, 0, 0);
    }

    function test_withdrawBold() public {
        switch_user(0);
        mintColl(100000e18);
        mintWeth(1000e18);
        priceFeed_setPrice(2000e18);
        clamped_open_trove(10e18, 2000e18, 25e16);

        switch_trove(0);
        BO_withdrawBold(currentTrove, 10e18, 2e18);
    }

    function test_withdrawColl() public {
        switch_user(0);
        mintColl(100000e18);
        mintWeth(1000e18);
        priceFeed_setPrice(2000e18);
        clamped_open_trove(10e18, 2000e18, 25e16);

        switch_trove(0);
        BO_withdrawColl(currentTrove, 1);
    }

    function test_createZombieBatch() public {
        currentUser = users[0];
        mintColl(100000000e18);
        mintWeth(10000e18);

        switch_randomUnit(1);
        priceFeed_setPrice(2000e18);
        clamped_registerBatchManager(1.5e18, 2e18, 1.7e18, 0, 1 days);
        clamped_openTroveAndJoinInterestBatchManager(11e18, 2000e18);
        switch_batchTrove(1);
        switch_trove(0);
        priceFeed_setRedemptionPrice(20000e18);
        macro_createZombie(10, 1e18);
    }
}
