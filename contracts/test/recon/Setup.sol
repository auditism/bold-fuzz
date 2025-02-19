// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseSetup} from "@chimera/BaseSetup.sol";
import {console} from "forge-std/console.sol";

import {Deployer} from "./Deployer.sol";
import {ERC20Token} from "./mocks/ERC20.sol";

import {IAddressesRegistry} from "src/Interfaces/IAddressesRegistry.sol";
import {IERC20Metadata} from "lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import {IInterestRouter} from "src/Interfaces/IInterestRouter.sol";
import {ITroveManager} from "src/Interfaces/ITroveManager.sol";

import {IWETH} from "src/Interfaces/IWETH.sol";
import {HintHelpers} from "src/HintHelpers.sol";
import {MockPriceFeed} from "./mocks/MockPriceFeed.sol";

import {Asserts} from "@chimera/Asserts.sol";
import {Weth} from "./mocks/WETH.sol";

abstract contract Setup is BaseSetup, Deployer {
    address[] users;
    address[] batchManagers;
    uint256[] activeTroves;
    uint256[] normalTroves;
    uint256[] batchTroves;
    uint256[] zombieTroves;
    uint256[] mixedTroves;
    address[] tokens;

    // USERS
    address owner = address(this);
    address bob = address(123);
    address patrick = address(234);
    address schneider = address(345);
    address interestManager = address(888);

    address currentUser;
    uint256 currentTrove;
    address currentBatchManager;
    uint256 currentBatchTrove;
    uint256 currentZombieTrove;
    uint256 currentMixedTrove;
    uint256 currentNormalTrove;

    uint256 timestamp;

    uint256 randomUnit;

    function setup() internal virtual override {
        users.push(owner);
        users.push(bob);
        users.push(patrick);
        users.push(schneider);
        users.push(bob);

        deploy(owner, 1.5e18, 1.5e18, 1.5e18, 1e17, 1.5e17);
    }
}
