// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {ActivePoolTarget} from "./targets/activePool/ActivePoolTarget.sol";
import {BoldTokenTarget} from "./targets/boldToken/BoldTokenTarget.sol";
import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "./BeforeAfter.sol";
import {BOClamped} from "./targets/borrowerOperations/BOClamped.sol";
import {Manager} from "./managers/Manager.sol";
import {PriceFeedTarget} from "./targets/priceFeed/PriceFeedTarget.sol";
import {Properties} from "./Properties.sol";
import {vm} from "@chimera/Hevm.sol";

abstract contract TargetFunctions is BaseTargetFunctions, Properties, ActivePoolTarget, BoldTokenTarget, BOClamped, PriceFeedTarget {}
