// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {Modifiers} from "../../managers/Modifiers.sol";
import {Properties} from "../../Properties.sol";
import {vm} from "@chimera/Hevm.sol";

abstract contract BoldTokenTarget is BaseTargetFunctions, Properties, Modifiers {
    function boldToken_setBranchAddresses(
        address _troveManagerAddress,
        address _stabilityPoolAddress,
        address _borrowerOperationsAddress,
        address _activePoolAddress
    ) public ownerCalls {
        boldToken.setBranchAddresses(
            _troveManagerAddress, _stabilityPoolAddress, _borrowerOperationsAddress, _activePoolAddress
        );
        revert("Stateless"); //NOTE FOR now
    }

    function boldToken_setCollateralRegistry(address _collateralRegistryAddress) public ownerCalls {
        boldToken.setCollateralRegistry(_collateralRegistryAddress);
        revert("Stateless"); // annoying
    }
}
