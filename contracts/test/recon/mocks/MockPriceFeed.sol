// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IPriceFeed} from "src/Interfaces/IPriceFeed.sol";

contract MockPriceFeed is IPriceFeed {
    address public borrowerOperationsAddress;
    uint256 private price;
    uint256 private redemptionPrice;
    bool private priceValid;
    bool private redemptionPriceValid;

    // Events for tracking state changes
    event PriceUpdated(uint256 newPrice);
    event RedemptionPriceUpdated(uint256 newRedemptionPrice);
    event PriceValidityUpdated(bool isValid);
    event RedemptionPriceValidityUpdated(bool isValid);

    constructor(uint256 _initialPrice) {
        price = _initialPrice;
        redemptionPrice = _initialPrice;
        priceValid = true;
        redemptionPriceValid = true;
    }

    function fetchPrice() external override returns (uint256, bool) {
        return (price, false);
    }

    function fetchRedemptionPrice() external override returns (uint256, bool) {
        return (redemptionPrice, redemptionPriceValid);
    }

    function lastGoodPrice() external view override returns (uint256) {
        return price;
    }

    function setAddresses(address _borrowerOperationsAddress) external override {
        borrowerOperationsAddress = _borrowerOperationsAddress;
    }

    // Helper functions for testing
    function setPrice(uint256 _price) external {
        price = _price;
        emit PriceUpdated(_price);
    }

    function setRedemptionPrice(uint256 _redemptionPrice) external {
        redemptionPrice = _redemptionPrice;
        emit RedemptionPriceUpdated(_redemptionPrice);
    }

    function setPriceValidity(bool _isValid) external {
        priceValid = _isValid;
        emit PriceValidityUpdated(_isValid);
    }

    function setRedemptionPriceValidity(bool _isValid) external {
        redemptionPriceValid = _isValid;
        emit RedemptionPriceValidityUpdated(_isValid);
    }
}
