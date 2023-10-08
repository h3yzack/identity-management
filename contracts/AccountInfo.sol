// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AccountInfo {
 
  // Function to get the balance of an address
    function getBalance(address _address) public view returns (uint256) {
        return _address.balance;
    }

    // Function to get the address of the contract
    function getAddress() public view returns (address) {
        return address(this);
    }

}
