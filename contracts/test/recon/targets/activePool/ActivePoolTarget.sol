// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {Manager} from "../../managers/Manager.sol";
import {Modifiers} from "../../managers/Modifiers.sol";
import {Properties} from "../../Properties.sol";
import {TroveChange} from "src/Types/TroveChange.sol";
import {vm} from "@chimera/Hevm.sol";

abstract contract ActivePoolTarget is BaseTargetFunctions, Properties, Manager, Modifiers {
    // function activePool_accountForReceivedColl(uint256 _amount) public onlyBO_or_DefaultPool {
    //     activePool.accountForReceivedColl(_amount);
    // }

    // function activePool_mintAggInterest() public onlyBOorSP {
    //     activePool.mintAggInterest();
    // }

    // function activePool_mintAggInterestAndAccountForTroveChange(TroveChange memory _troveChange, address _batchAddress)
    //     public
    //     onlyBO_or_TroveM
    // {
    //     activePool.mintAggInterestAndAccountForTroveChange(_troveChange, _batchAddress);
    // }

    // function activePool_mintBatchManagementFeeAndAccountForChange(
    //     TroveChange memory _troveChange,
    //     address _batchAddress
    // ) public onlyTroveManager {
    //     activePool.mintBatchManagementFeeAndAccountForChange(_troveChange, _batchAddress);
    // }
    // //Clamp BorrowerOperationsOrDefaultPool

    // function activePool_receiveColl(uint256 _amount) public onlyBO_or_DefaultPool {
    //     activePool.receiveColl(_amount);
    // }

    // // clamp BOorTroveMorSP
    // function activePool_sendColl(address _account, uint256 _amount) public onlyBO_or_TroveM_or_SP {
    //     activePool.sendColl(_account, _amount);
    // }
    // // clamp to TroveManager

    // function activePool_sendCollToDefaultPool(uint256 _amount) public onlyTroveManager {
    //     activePool.sendCollToDefaultPool(_amount);
    // }
    // // TroveManager

    // function activePool_setShutdownFlag() public onlyTroveManager {
    //     activePool.setShutdownFlag(); //To reach coverage make it revert ?
    //     revert("Stateless");
    // }
}
