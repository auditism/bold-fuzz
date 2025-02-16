// Represents a symbolic/dummy ERC20 token

// SPDX-License-Identifier: agpl-3.0

import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

pragma solidity ^0.8.0;

contract ERC20Token is ERC20("TOKEN", "TKN") {
    function mint(address receiver, uint256 amt) public {
        _mint(receiver, amt);
    }

}
