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

    modifier onlyBoldOrTroveM() {
        //not used ?
        uint256 number = _returnNumber(2);
        if (number == 0) vm.prank(address(troveManager));
        else vm.prank(address(boldToken));
        _;
    }

    modifier onlyBO_or_TroveM() {
        uint256 number = _returnNumber(2);
        if (number == 0) vm.prank(address(troveManager));
        else vm.prank(address(borrowerOperations));
        _;
    }

    modifier onlyBO_or_DefaultPool() {
        uint256 number = _returnNumber(2);
        if (number == 0) vm.prank(address(borrowerOperations));
        else vm.prank(address(defaultPool));
        _;
    }

    modifier onlyBO_or_TroveM_or_SP() {
        uint256 number = _returnNumber(3);
        if (number == 0) vm.prank(address(borrowerOperations));
        else if (number == 1) vm.prank(address(troveManager));
        else vm.prank(address(stabilityPool));
        _;
    }

    function _returnNumber(uint256 modulo) internal returns (uint256) {
        uint256 randomUnitImage = randomUnit;
        return randomUnitImage % modulo;
    }

    modifier onlyBOorSP() {
        uint256 number = _returnNumber(2);
        if (number == 0) vm.prank(address(borrowerOperations)); //NOTE double check this !!!!

        else vm.prank(address(stabilityPool));
        _;
    }

    modifier onlyBO_or_CR_or_TM_SP() {
        uint256 number = _returnNumber(4);
        if (number == 0) vm.prank(address(borrowerOperations));
        else if (number == 1) vm.prank(address(collateralRegistry));
        else if (number == 2) vm.prank(address(troveManager));
        else vm.prank(address(stabilityPool));
        _;
    }

    modifier onlyBOorAP() {
        //to change
        uint256 number = _returnNumber(2);
        if (number == 0) vm.prank(address(borrowerOperations));
        else vm.prank(address(activePool));
        _;
    }
    // _requireCallerIsStabilityPool

    modifier onlySP() {
        vm.prank(address(stabilityPool));
        _;
    }

    modifier ownerCalls() {
        //does it work for bold ?
        vm.prank(address(owner));
        _;
    }

    // modifer interestManager() {
    //     vm.prank(address())
    // }
}
