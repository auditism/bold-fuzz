// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {Properties} from "../Properties.sol";
import {vm} from "@chimera/Hevm.sol";

abstract contract SPTarget is BaseTargetFunctions, Properties {
    function stabilityPool_provideToSP(uint256 _topUp, bool _doClaim) public beforeAfter {
        stabilityPool.provideToSP(_topUp, _doClaim);
    }

    function stabilityPool_withdrawFromSP(uint256 _amount, bool _doClaim) public beforeAfter {
        stabilityPool.withdrawFromSP(_amount, _doClaim);
    }

    function stabilityPool_claimAllCollGains() public beforeAfter {
        stabilityPool.claimAllCollGains();
    }
}
