// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {Modifiers} from "../../managers/Modifiers.sol";
import {Properties} from "../../Properties.sol";
import {vm} from "@chimera/Hevm.sol";

abstract contract BoldTokenTarget is BaseTargetFunctions, Properties, Modifiers {
//     function boldToken_approve(address spender, uint256 amount) public {
//         boldToken.approve(spender, amount);
//     }
//     // clamp  _requireCallerIsCRorBOorTMorSP
//     function boldToken_burn(address _account, uint256 _amount) public onlyBO_or_CR_or_TM_SP {
//         boldToken.burn(_account, _amount);
//     }

//     function boldToken_decreaseAllowance(address spender, uint256 subtractedValue) public {
//         boldToken.decreaseAllowance(spender, subtractedValue);
//     }

//     function boldToken_increaseAllowance(address spender, uint256 addedValue) public {
//         boldToken.increaseAllowance(spender, addedValue);
//     }
//     // clamp _requireCallerIsBOorAP
//     function boldToken_mint(address _account, uint256 _amount) public onlyBOorAP {
//         boldToken.mint(_account, _amount);
//     }

//     function boldToken_permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
//         boldToken.permit(owner, spender, value, deadline, v, r, s);
//     }
//     // _requireCallerIsStabilityPool
//     function boldToken_returnFromPool(address _poolAddress, address _receiver, uint256 _amount) public onlySP {
//         boldToken.returnFromPool(_poolAddress, _receiver, _amount);
//     }
//     // _requireCallerIsStabilityPool
//     function boldToken_sendToPool(address _sender, address _poolAddress, uint256 _amount) public onlySP {
//         boldToken.sendToPool(_sender, _poolAddress, _amount);
//     }
//     // _owner
//     function boldToken_setBranchAddresses(address _troveManagerAddress, address _stabilityPoolAddress, address _borrowerOperationsAddress, address _activePoolAddress) public ownerCalls {
//         boldToken.setBranchAddresses(_troveManagerAddress, _stabilityPoolAddress, _borrowerOperationsAddress, _activePoolAddress);
//     }
//     // onlyOwner
//     function boldToken_setCollateralRegistry(address _collateralRegistryAddress) public ownerCalls {
//         boldToken.setCollateralRegistry(_collateralRegistryAddress);
//         revert("Stateless"); // annoying

//     }

//     function boldToken_transfer(address recipient, uint256 amount) public {
//         boldToken.transfer(recipient, amount);
//     }

//     function boldToken_transferFrom(address sender, address recipient, uint256 amount) public {
//         boldToken.transferFrom(sender, recipient, amount);
//     }
}
