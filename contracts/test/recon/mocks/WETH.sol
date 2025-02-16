// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {IWETH} from "src/Interfaces/IWETH.sol";

contract Weth is IWETH, ERC20("Wrapped Ether", "WETH") {


    event Deposit(address indexed from, uint256 amount);

    event Withdrawal(address indexed to, uint256 amount);

    function deposit() public payable virtual {
        _mint(msg.sender, msg.value);

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public virtual {
        _burn(msg.sender, amount);

        emit Withdrawal(msg.sender, amount);

        msg.sender.call{value:amount}("");
    }

    function mint(address receiver, uint256 amt) public {
        _mint(receiver, amt);
    }

    receive() external payable virtual {
        deposit();
    }
}