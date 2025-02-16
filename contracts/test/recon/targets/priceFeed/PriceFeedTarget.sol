
// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {Properties} from "../../Properties.sol";
import {vm} from "@chimera/Hevm.sol";

abstract contract PriceFeedTarget is BaseTargetFunctions, Properties {

    function priceFeed_fetchPrice() public {
        priceFeed.fetchPrice();
    }

    function priceFeed_fetchRedemptionPrice() public {
        priceFeed.fetchRedemptionPrice();
    }

    function priceFeed_setAddresses(address _borrowerOperationsAddress) public {
        priceFeed.setAddresses(_borrowerOperationsAddress);
    }

    function priceFeed_setPrice(uint256 _price) public {
        priceFeed.setPrice(_price);
    }

    // function priceFeed_setPriceValidity(bool _isValid) public {
    //     priceFeed.setPriceValidity(_isValid);
    // }

    function priceFeed_setRedemptionPrice(uint256 _redemptionPrice) public {
        priceFeed.setRedemptionPrice(_redemptionPrice);
    }

    function priceFeed_setRedemptionPriceValidity(bool _isValid) public {
        priceFeed.setRedemptionPriceValidity(_isValid);
    }
}