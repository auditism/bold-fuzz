// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Asserts} from "@chimera/Asserts.sol";
import {BeforeAfter} from "./BeforeAfter.sol";
import {SortedTroves} from "src/SortedTroves.sol";

import {LatestBatchData} from "src/Types/LatestBatchData.sol";
import {LatestTroveData} from "src/Types/LatestTroveData.sol";
import {TroveManager} from "src/TroveManager.sol";

abstract contract Properties is BeforeAfter, Asserts {
    // function property_liquidation_profitable() public {
    //     t(_before.userBalance < _after.userBalance, 'liquidation no profit'); //@note breaks instantly

    // }
    //NOTE Global property / state transition ?
    function property_self_liquidation() public {
        if (_before.ICR > addressesRegistry.MCR()) {
            t(_after.ICR > addressesRegistry.MCR(), "User action made ICR go below MCR");
        }
    }
    //NOTE global

    function property_sorted_in_order() public {
        (bool isDescending) = _get_neighbor_rates(currentTrove);
        t(isDescending, "sort bad");
    }
    //NOTE global

    function property_not_in_sorted_debt_lt_min() public {
        uint256 len = troveManager.getTroveIdsCount();
        for (uint256 i; i < len; i++) {
            uint256 trove = troveManager.getTroveFromTroveIdsArray(i);
            LatestTroveData memory data = troveManager.getLatestTroveData(trove);
            uint256 debt = data.entireDebt;
            bool notAllowed = (debt < 2000e18 && sortedTroves.contains(trove)); // when true, illegal
            t(!notAllowed, "trove shouldn't be in sortedTrove");
        }
    }

    //Note what is an inline property ? should it call state changing functions ?

    function property_SP_coll_balance() public {
        bool solvent = stabilityPool.collToken().balanceOf(address(stabilityPool)) >= stabilityPool.getCollBalance();
        t(solvent, "stability pool insolvancy");
    }

    function property_debt_invariant() public {
        uint256 debt = activePool.aggRecordedDebt() + activePool.calcPendingAggInterest()
            + activePool.aggBatchManagementFees() + activePool.calcPendingAggBatchManagementFee()
            + defaultPool.getBoldDebt();
        uint256 sumTroveDebt = _get_sum_trove_debt();
        eq(debt, sumTroveDebt, "debt mismastch"); //NOTE probably fails
    }


    function property_same_interest_batch() public {
        uint256 len = troveManager.getTroveIdsCount();

        for (uint256 i; i < len; i++) {
            uint256 trove = troveManager.getTroveFromTroveIdsArray(i);
            (,,,,,,, uint256 troveInterest, address batchManager,) = troveManager.Troves(trove);

            if (batchManager == address(0)) continue;

            LatestBatchData memory batchData = troveManager.getLatestBatchData(batchManager);
            uint256 batchInterest = batchData.annualInterestRate;
            eq(troveInterest, batchInterest, "trove/batch annual interest rate mismatch");
        }
    }

    //Batch debt shares is hard to test

    function _get_sum_trove_debt() internal returns (uint256 sumTroveDebt) {
        uint256 len = troveManager.getTroveIdsCount();

        for (uint256 i; i < len; i++) {
            uint256 trove = troveManager.getTroveFromTroveIdsArray(i);
            LatestTroveData memory data = troveManager.getLatestTroveData(trove);
            sumTroveDebt += data.entireDebt;
        }
        return sumTroveDebt;
    }

    function _get_neighbor_rates(uint256 _troveId) internal view returns (bool isDescending) {
        require(sortedTroves.contains(_troveId), "Trove not in list");

        (uint256 nextId, uint256 prevId,,) = sortedTroves.nodes(_troveId);
        uint256 prevRate;
        uint256 nextRate;

        uint256 currRate = troveManager.getTroveAnnualInterestRate(_troveId);

        // Get previous Trove's rate (if not head)
        if (prevId != 0) {
            uint256 prevRate = troveManager.getTroveAnnualInterestRate(prevId);
        } else {
            prevRate = type(uint256).max;
        }

        // Get next Trove's rate (if not head)
        if (nextId != 0) {
            nextRate = troveManager.getTroveAnnualInterestRate(nextId);
        } else {
            nextRate = 0;
        }
        isDescending = (prevRate >= currRate) && (currRate >= nextRate);
    }
}


