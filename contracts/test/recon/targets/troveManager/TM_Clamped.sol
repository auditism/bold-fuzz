// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {ITroveManager} from "src/Interfaces/ITroveManager.sol";
import {Properties} from "../../Properties.sol";
import {TM_Raw} from "./TM_Raw/TM_Raw.sol";
import {vm} from "@chimera/Hevm.sol";

abstract contract TM_Clamped is TM_Raw {
    function clamped_batchLiquidateTroves() public {
        uint256[] memory trovesArray = _return_troves_array();
        TM_batchLiquidateTroves(trovesArray);
    }

    function macro_batchLiquidateTroves(uint256 price) public {
        priceFeed.setPrice(price); // necesssary ?
        clamped_batchLiquidateTroves();
    }

    function _return_troves_array() private returns (uint256[] memory trovesArray) {
        uint256 length = randomUnit % activeTroves.length;
        trovesArray = new uint256[](length);
        uint256 seed = randomUnit;

        for (uint256 i = 0; i < length; i++) {
            // Generate a pseudo-random index using the seed
            seed = uint256(keccak256(abi.encodePacked(seed, i)));
            uint256 randomIndex = seed % activeTroves.length;
            trovesArray[i] = activeTroves[randomIndex];
        }
        return trovesArray;
    }
}
