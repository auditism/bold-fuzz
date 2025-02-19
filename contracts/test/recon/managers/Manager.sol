// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "../BeforeAfter.sol";
import {Helpers} from "./Helpers.sol";
import {ITroveManager} from "src/Interfaces/ITroveManager.sol";
import {Modifiers} from "./Modifiers.sol";
import {Properties} from "../Properties.sol";
import {IERC20} from "../mocks/IERC20.sol";
import {vm} from "@chimera/Hevm.sol";

abstract contract Manager is BaseTargetFunctions, Properties, Modifiers, Helpers {
    function mintColl(uint256 amount) public {
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
        currentTrove = activeTroves[index];
    }

    function switch_batchTrove(uint256 index) public {
        index %= batchTroves.length;
        currentBatchTrove = batchTroves[index];
    }

    function switch_mixedTrove(uint256 index) public {
        index %= mixedTroves.length;
        currentMixedTrove = mixedTroves[index];
    }

    function switch_normalTrove(uint256 index) public {
        index %= normalTroves.length;
        currentNormalTrove = normalTroves[index];
    }

    function switch_zombie(uint256 index) public {
        index %= zombieTroves.length;
        currentZombieTrove = zombieTroves[index];
    }

    function switchBatchManger(uint256 index) public {
        index %= batchManagers.length;
        currentBatchManager =  batchManagers[index];
    }

    function mintBold(uint256 amt) public onlyBO {
        borrowerOperations.boldToken().mint(currentUser, amt);
        borrowerOperations.boldToken().approve(address(collateralRegistry), amt);
    }

    function switch_randomUnit(uint256 unit) public {
        randomUnit = unit;
    }

    function pushTime() public {
        vm.warp(timestamp + 10 days);
    }

    function findZombies() public {
        uint256 len = troveManager.getTroveIdsCount();
        delete zombieTroves;
        for (uint256 i; i < len; i++) {
            uint256 trove = troveManager.getTroveFromTroveIdsArray(i);
            uint256 status = uint8(troveManager.getTroveStatus(trove));
            if (status == uint8(ITroveManager.Status.zombie)) zombieTroves.push(trove);
        }
    }
}
