// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DIDRegistry {
    // Struct to represent a DID document
    struct DIDDocument {
        string did; // DID ID in the format "did:<method>:<unique_id>"
        string didType; // Type of DID ID
        string title;
        string signature; // sign didId
        address user; // Ethereum address of the user
    }

    // Mapping to store DID documents for each user's Ethereum address
    mapping(address => DIDDocument[]) public didDocuments;

    event DidAdded(DIDDocument didDoc);

    // Function to add a new DID document
    function addDIDDocument(
        string memory did,
        string memory didType,
        string memory title,
        address userAddress,
        string memory signature
    ) public {
        DIDDocument memory doc = DIDDocument(did, didType, title, signature, userAddress);
        // console.log("Owner contract deployed by:", msg.sender);
        didDocuments[userAddress].push(doc);

        emit DidAdded(doc);
    }

    // Function to retrieve all DID documents for a user
    function getDIDDocuments(address userAddress) public view returns (string[] memory) {
        DIDDocument[] memory didDocs = didDocuments[userAddress];
        string[] memory jsonObjects = new string[](didDocs.length);

        for (uint256 i = 0; i < didDocs.length; i++) {
            DIDDocument memory doc = didDocs[i];
            string memory jsonObject = string(
                abi.encodePacked(
                    '{"did":"',
                    doc.did,
                    '","didType":"',
                    doc.didType,
                    '","title":"',
                    doc.title,
                    '","signature":"',
                    doc.signature,
                    '","user":"',
                    addressToString(doc.user),
                    '"}'
                )
            );
            jsonObjects[i] = jsonObject;
        }

        return jsonObjects;
    }

    // Helper function to convert an address to a string
    function addressToString(address _address) internal pure returns (string memory) {
        bytes32 _bytes = bytes32(uint256(uint160(_address)));
        bytes memory HEX = "0123456789abcdef";
        bytes memory _string = new bytes(42);
        _string[0] = "0";
        _string[1] = "x";
        for (uint256 i = 0; i < 20; i++) {
            _string[2 + i * 2] = HEX[uint8(_bytes[i + 12] >> 4)];
            _string[3 + i * 2] = HEX[uint8(_bytes[i + 12] & 0x0f)];
        }
        return string(_string);
    }
}