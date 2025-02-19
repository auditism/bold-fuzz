// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {ITroveManager} from "src/Interfaces/ITroveManager.sol";
import {Properties} from "../../../Properties.sol";
import {TroveChange} from "src/Types/TroveChange.sol";
import {vm} from "@chimera/Hevm.sol";

abstract contract TM_Raw is BaseTargetFunctions, Properties {
    function TM_batchLiquidateTroves(uint256[] memory _troveArray) public {
        troveManager.batchLiquidateTroves(_troveArray);
    }

    function TM_urgentRedemption(uint256 _boldAmount, uint256[] memory _troveIds, uint256 _minCollateral) public {
        troveManager.urgentRedemption(_boldAmount, _troveIds, _minCollateral);
    }

    function TM_getUnbackedPortionPriceAndRedeemability() public {
        (,, bool redeemable) = troveManager.getUnbackedPortionPriceAndRedeemability();
    }

}
