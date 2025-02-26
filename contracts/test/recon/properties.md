## property_liquidation_profitable

property verifying that liquidator balance after liquidation is bigger than the balance before liquidation 

need to rethink it how, because sp provider receive the coll as well


## property_self_liquidation

property assuring user actions cannot lead to a liquidatable state.

## property_sorted_in_order

property verifying the order of troves in the sortedTroves contract

## property_not_in_sorted_debt_lt_min

property assuring the exclusion of troves with debt lower than minDebt

## property_SP_coll_balance

property verifying the collateral recorded balance <= collateral.balanceOf(stabilityPool)

## property_debt_invariant

invariant about debt such that : 
```
ActivePool.aggRecordedDebt + ActivePool.calcPendingAggInterest()
+ ActivePool.aggBatchManagementFees() + ActivePool.calcPendingAggBatchManagementFee()
+ DefaultPool.BoldDebt
= SUM_i=1_n(TroveManager.getEntireTroveDebt())
```
holds 

## property_same_interest_batch

property assuring each trove in the same batch have the same interest rate

## 