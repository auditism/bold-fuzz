// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BoldTokenTarget} from "./targets/boldToken/BoldTokenTarget.sol";
import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "./BeforeAfter.sol";
import {BOClamped} from "./targets/borrowerOperations/BOClamped.sol";
import {Deployer} from "./Deployer.sol";
// import {MAX_LIQUIDATION_PENALTY_REDISTRIBUTION, MIN_LIQUIDATION_PENALTY_SP} from "src/Dependencies/Constants.sol";

import {ITroveManager} from "src/Interfaces/ITroveManager.sol";

import {LatestTroveData} from "src/Types/LatestTroveData.sol";

import {Manager} from "./managers/Manager.sol";
import {PriceFeedTarget} from "./targets/priceFeed/PriceFeedTarget.sol";
import {Properties} from "./Properties.sol";
import {SPTarget} from "./targets/SPTarget.sol";
import {TM_Clamped} from "./targets/troveManager/TM_Clamped.sol";
import {vm} from "@chimera/Hevm.sol";

abstract contract TargetFunctions is
    BaseTargetFunctions,
    Properties,
    BOClamped,
    BoldTokenTarget,
    PriceFeedTarget,
    SPTarget,
    TM_Clamped
{



    function collateralRegistry_redeemCollateral(
        uint256 amt,
        uint256 _maxIterationsPerCollateral,
        uint256 _maxFeePercentage
    ) public {
        collateralRegistry.redeemCollateral(amt, _maxIterationsPerCollateral, _maxFeePercentage);
    }


    // bool deployed;
    // function deployment(
    //     uint256 ccr,
    //     uint256 mcr,
    //     uint256 scr,
    //     uint256 liquidationPenaltySP,
    //     uint256 liquidationPenaltyRedistribution
    // ) public {
    //     if (!deployed) {
    //         (ccr, mcr, scr, liquidationPenaltySP, liquidationPenaltyRedistribution) =
    //             _fix_deploy_args(ccr, mcr, scr, liquidationPenaltySP, liquidationPenaltyRedistribution);
    //         deploy(owner, ccr, mcr, scr, liquidationPenaltySP, liquidationPenaltyRedistribution);
    //         deployed = true;

    //     }
    // }
    
}
