// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "../BeforeAfter.sol";
import {Properties} from "../Properties.sol";
import {vm} from "@chimera/Hevm.sol";

abstract contract Modifiers is BaseTargetFunctions, Properties {
    modifier onlyTroveManager() {
        vm.prank(address(troveManager));
        _;
    }

    modifier randomUser() {
        address randomUser = users[randomUnit % users.length];
        vm.prank(randomUser);
        _;
    }

    function _returnNumber(uint256 modulo) internal returns (uint256) {
        uint256 randomUnitImage = randomUnit;
        return randomUnitImage % modulo;
    }

    modifier onlyBO() {
        vm.prank(address(borrowerOperations));
        _;
    }

    modifier onlySP() {
        vm.prank(address(stabilityPool));
        _;
    }

    modifier ownerCalls() {
        vm.prank(address(owner));
        _;
    }
}
