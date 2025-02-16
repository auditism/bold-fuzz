// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {TargetFunctions} from "./TargetFunctions.sol";
import {FoundryAsserts} from "@chimera/FoundryAsserts.sol";
import "forge-std/console2.sol";
//forge test --match-test test_crytic -vvvv
contract CryticToFoundry is Test, TargetFunctions, FoundryAsserts {
    function setUp() public {
        setup();
    }

    function test_crytic() public {
        currentUser = users[0];
        mintTokenToAll(100000e18);
        mintWeth(1000e18);
        clamped_open_trove(0, //index
            100000e18, //col
            10000e18, // boldA
            0,
            0,
            uint128(0.5e17),
            hintHelpers.predictOpenTroveUpfrontFee(0, 10000e18, uint128(0.5e17)),
            address(666),
            address(activePool),
            address(this));
    }
}
