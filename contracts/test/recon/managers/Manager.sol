// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "../BeforeAfter.sol";
import {Properties} from "../Properties.sol";
import {IERC20} from "../mocks/IERC20.sol";
import {vm} from "@chimera/Hevm.sol";

abstract contract Manager is BaseTargetFunctions, Properties {
    // function mintToken(uint256 amount) public {
    //     collateral.mint(currentActor, amount);
    //     collateral.approve(address(activePool), amount);
    // }

    function mintTokenToAll(uint256 amount) public {
            collateral.mint(currentUser, amount);
            collateral.approve(address(borrowerOperations), amount);
        
    }
    function mintWeth(uint256 amount) public {
            weth.mint(currentUser, amount);
            weth.approve(address(borrowerOperations), amount);  
    }

    function switch_user(uint256 index) public {
        currentUser = users[index %= users.length];
    }

    function switch_trove(uint256 index) public {
        index %= activeTroves.length;
    }

    function switch_randomUnit(uint256 unit) public {
        randomUnit = unit;
    }
}
