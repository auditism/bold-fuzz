// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import {CryticAsserts} from "@chimera/CryticAsserts.sol";
import {Test} from "forge-std/Test.sol";

contract PredeployCalculator {
    // contract PredeployCalculator is Test {
    function setupPrecomputedAddresses(address deployer) public pure returns (address[] memory addresses) {
        addresses = new address[](16); // Number of contracts to deploy
        uint256 nonce = 4; // Starting nonce

        // Calculate addresses in alphabetical order
        addresses[0] = _computeCreateAddress(deployer, nonce++); // activePool
        addresses[1] = _computeCreateAddress(deployer, nonce++); // boldToken
        addresses[2] = _computeCreateAddress(deployer, nonce++); // borrowerOperations
        addresses[3] = _computeCreateAddress(deployer, nonce++); // collSurplusPool
        addresses[4] = _computeCreateAddress(deployer, nonce++); // defaultPool
        addresses[5] = _computeCreateAddress(deployer, nonce++); // fixedAssetReader
        addresses[6] = _computeCreateAddress(deployer, nonce++); // hintHelpers
        addresses[7] = _computeCreateAddress(deployer, nonce++); // metadataNFT
        addresses[8] = _computeCreateAddress(deployer, nonce++); // multiTroveGetter
        addresses[9] = _computeCreateAddress(deployer, nonce++); // priceFeed
        addresses[10] = _computeCreateAddress(deployer, nonce++); // stabilityPool
        addresses[11] = _computeCreateAddress(deployer, nonce++); // troveManager
        addresses[12] = _computeCreateAddress(deployer, nonce++); // 
        addresses[13] = _computeCreateAddress(deployer, nonce++); // 
        addresses[14] = _computeCreateAddress(deployer, nonce++); // 
        addresses[15] = _computeCreateAddress(deployer, nonce++); // 
    }

    function _computeCreateAddress(address deployer, uint256 nonce) internal pure returns (address) {
        return address(
            uint160(uint256(keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), deployer, bytes1(uint8(nonce))))))
        );
    }
}
