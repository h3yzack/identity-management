// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyIdUtil {

    // Mapping of addresses to their tokenIds
    // mapping(address => uint256) public tokenIds;

    constructor() {}

    // Function to generate a tokenId
    function generateTokenId(address userAddress, string memory timestamp) public pure returns (uint256) {

        // Hash the user's address and the timestamp
        bytes32 hash = keccak256(abi.encodePacked(userAddress, timestamp));
        
        // Convert the hash to a uint256
        uint256 tokenId = uint256(hash);


        return tokenId;
    }

    
}