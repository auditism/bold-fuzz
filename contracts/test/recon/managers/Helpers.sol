// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Properties} from "../Properties.sol";
import {IBorrowerOperations} from "src/Interfaces/IBorrowerOperations.sol";

abstract contract Helpers is Properties {
    uint256 constant MIN_LIQUIDATION_PENALTY_SP = 5e16;
    uint256 constant MAX_LIQUIDATION_PENALTY_REDISTRIBUTION = 20e16;

    function _return_random_User() internal returns (address user) {
        user = users[randomUnit % users.length];
    }

    function _return_batch_open_trove_params(uint256 collAmount, uint256 boldAmount)
        internal
        returns (IBorrowerOperations.OpenTroveAndJoinInterestBatchManagerParams memory params)
    {
        // address batchManager = _return_random_User();
        params.maxUpfrontFee = hintHelpers.predictOpenTroveUpfrontFee(0, boldAmount, 2e18);
        params.owner = currentUser;
        // params.ownerIndex = 0;
        params.collAmount = collAmount;
        params.boldAmount = boldAmount;
        params.interestBatchManager = _return_random_User();
        params.maxUpfrontFee;
    }

    function _fix_deploy_args(
        uint256 ccr,
        uint256 mcr,
        uint256 scr,
        uint256 liquidationPenaltySP,
        uint256 liquidationPenaltyRedistribution
    ) internal returns (uint256, uint256, uint256, uint256, uint256) {
        ccr = 1e18 + (ccr % 1e18);
        mcr = 1e18 + (mcr % 1e18);
        scr = 1e18 + (scr % 1e18);
        liquidationPenaltySP = MIN_LIQUIDATION_PENALTY_SP
            + (liquidationPenaltySP % (MAX_LIQUIDATION_PENALTY_REDISTRIBUTION - MIN_LIQUIDATION_PENALTY_SP));
        uint256 minRedistribution = liquidationPenaltySP + 1;
        uint256 availableRange = MAX_LIQUIDATION_PENALTY_REDISTRIBUTION - minRedistribution;
        liquidationPenaltyRedistribution = minRedistribution + (liquidationPenaltyRedistribution % (availableRange + 1));
    }
}
