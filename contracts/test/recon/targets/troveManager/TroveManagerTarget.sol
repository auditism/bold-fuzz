// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {ITroveManager} from "src/Interfaces/ITroveManager.sol";
import {Properties} from "../../Properties.sol";
import {TroveChange} from "src/Types/TroveChange.sol";
import {vm} from "@chimera/Hevm.sol";

abstract contract TargetFunctions is BaseTargetFunctions, Properties {
// function troveManager_batchLiquidateTroves(uint256[] memory _troveArray) public {
//     troveManager.batchLiquidateTroves(_troveArray);
// }

// function troveManager_getUnbackedPortionPriceAndRedeemability() public {
//     troveManager.getUnbackedPortionPriceAndRedeemability();
// }

// function troveManager_onAdjustTrove(uint256 _troveId, uint256 _newColl, uint256 _newDebt, TroveChange memory _troveChange) public {
//     troveManager.onAdjustTrove(_troveId, _newColl, _newDebt, _troveChange);
// }

// function troveManager_onAdjustTroveInsideBatch(uint256 _troveId, uint256 _newTroveColl, uint256 _newTroveDebt, TroveChange memory _troveChange, address _batchAddress, uint256 _newBatchColl, uint256 _newBatchDebt) public {
//     troveManager.onAdjustTroveInsideBatch(_troveId, _newTroveColl, _newTroveDebt, _troveChange, _batchAddress, _newBatchColl, _newBatchDebt);
// }

// function troveManager_onAdjustTroveInterestRate(uint256 _troveId, uint256 _newColl, uint256 _newDebt, uint256 _newAnnualInterestRate, TroveChange memory _troveChange) public {
//     troveManager.onAdjustTroveInterestRate(_troveId, _newColl, _newDebt, _newAnnualInterestRate, _troveChange);
// }

// function troveManager_onApplyTroveInterest(uint256 _troveId, uint256 _newTroveColl, uint256 _newTroveDebt, address _batchAddress, uint256 _newBatchColl, uint256 _newBatchDebt, TroveChange memory _troveChange) public {
//     troveManager.onApplyTroveInterest(_troveId, _newTroveColl, _newTroveDebt, _batchAddress, _newBatchColl, _newBatchDebt, _troveChange);
// }

// function troveManager_onCloseTrove(uint256 _troveId, TroveChange memory _troveChange, address _batchAddress, uint256 _newBatchColl, uint256 _newBatchDebt) public {
//     troveManager.onCloseTrove(_troveId, _troveChange, _batchAddress, _newBatchColl, _newBatchDebt);
// }

// function troveManager_onLowerBatchManagerAnnualFee(address _batchAddress, uint256 _newColl, uint256 _newDebt, uint256 _newAnnualManagementFee) public {
//     troveManager.onLowerBatchManagerAnnualFee(_batchAddress, _newColl, _newDebt, _newAnnualManagementFee);
// }

// function troveManager_onOpenTrove(address _owner, uint256 _troveId, TroveChange memory _troveChange, uint256 _annualInterestRate) public {
//     troveManager.onOpenTrove(_owner, _troveId, _troveChange, _annualInterestRate);
// }

// function troveManager_onOpenTroveAndJoinBatch(address _owner, uint256 _troveId, TroveChange memory _troveChange, address _batchAddress, uint256 _batchColl, uint256 _batchDebt) public {
//     troveManager.onOpenTroveAndJoinBatch(_owner, _troveId, _troveChange, _batchAddress, _batchColl, _batchDebt);
// }

// function troveManager_onRegisterBatchManager(address _account, uint256 _annualInterestRate, uint256 _annualManagementFee) public {
//     troveManager.onRegisterBatchManager(_account, _annualInterestRate, _annualManagementFee);
// }

// function troveManager_onRemoveFromBatch(uint256 _troveId, uint256 _newTroveColl, uint256 _newTroveDebt, TroveChange memory _troveChange, address _batchAddress, uint256 _newBatchColl, uint256 _newBatchDebt, uint256 _newAnnualInterestRate) public {
//     troveManager.onRemoveFromBatch(_troveId, _newTroveColl, _newTroveDebt, _troveChange, _batchAddress, _newBatchColl, _newBatchDebt, _newAnnualInterestRate);
// }

// function troveManager_onSetBatchManagerAnnualInterestRate(address _batchAddress, uint256 _newColl, uint256 _newDebt, uint256 _newAnnualInterestRate, uint256 _upfrontFee) public {
//     troveManager.onSetBatchManagerAnnualInterestRate(_batchAddress, _newColl, _newDebt, _newAnnualInterestRate, _upfrontFee);
// }

// function troveManager_onSetInterestBatchManager(ITroveManager.OnSetInterestBatchManagerParams memory _params) public {
//     troveManager.onSetInterestBatchManager(_params);
// }

// function troveManager_redeemCollateral(address _redeemer, uint256 _boldamount, uint256 _price, uint256 _redemptionRate, uint256 _maxIterations) public {
//     troveManager.redeemCollateral(_redeemer, _boldamount, _price, _redemptionRate, _maxIterations);
// }

// function troveManager_setTroveStatusToActive(uint256 _troveId) public {
//     troveManager.setTroveStatusToActive(_troveId);
// }

// function troveManager_shutdown() public {
//     troveManager.shutdown();
// }

// function troveManager_urgentRedemption(uint256 _boldAmount, uint256[] memory _troveIds, uint256 _minCollateral) public {
//     troveManager.urgentRedemption(_boldAmount, _troveIds, _minCollateral);
// }
}
