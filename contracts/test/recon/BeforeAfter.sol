// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Setup} from "./Setup.sol";

// ghost variables for tracking state variable values before and after function calls
abstract contract BeforeAfter is Setup {
    struct Vars {
        uint256 ICR;
        uint256 userBalance;
    }

    Vars internal _before;
    Vars internal _after;

    function __before() internal {
        (uint256 price,) = priceFeed.fetchPrice();
        _before.ICR = troveManager.getCurrentICR(currentTrove, price);
    }

    function __after() internal {
        (uint256 price,) = priceFeed.fetchPrice();
        _after.ICR = troveManager.getCurrentICR(currentTrove, price);
    }
    ////messy/// How could I segregate things elegantly ?

    function __beforeLiquidation() internal {
        _before.userBalance = _calculate_Balance_Value();
    }

    function __afterLiquidation() internal {
        _after.userBalance = _calculate_Balance_Value();
    }
    ///////////

    modifier beforeAfter() {
        __before();
        _;
        __after();
    }

    modifier liquidationTracker() {
        __beforeLiquidation();
        _;
        __afterLiquidation();
    }

    function _calculate_Balance_Value() public returns (uint256 totalVal) {
        uint256 bold = boldToken.balanceOf(currentUser);
        uint256 wethAmount = weth.balanceOf(currentUser);
        uint256 coll = collateral.balanceOf(currentUser);
        (uint256 price,) = priceFeed.fetchPrice();

        uint256 wethVal = wethAmount * 2000; // assume weth is worth 2000, no need for decimal adaptation
        uint256 collVal = coll * price; //NOTE should normalize the price decimals tho
        totalVal = collVal + bold + wethVal;
    }
}
