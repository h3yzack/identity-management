// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PresentRequest {
    struct Request {
        string credentialId;
        string verifierAddress;
        string requestId;
        string userDid;
        string otherInfo;
    }

    mapping(bytes32 => Request) public requests;

    function generateId(string memory requestId, string memory verifierAddress) public pure returns (bytes32) {
        bytes32 id = keccak256(
            abi.encodePacked(requestId, verifierAddress)
        );
        return id;
    }

    function save(
        string memory credentialId,
        string memory verifierAddress,
        string memory requestId,
        string memory userDid,
        string memory otherInfo
    ) public {
        bytes32 id = generateId(requestId, verifierAddress);

        requests[id] = Request(
            credentialId,
            verifierAddress,
            requestId,
            userDid,
            otherInfo
        );
    }

    function getRequest(string memory requestId, string memory verifierAddress) public view returns (string memory) {
        bytes32 id = generateId(requestId, verifierAddress);

        Request memory request = requests[id];
        return
            string(
                abi.encodePacked(
                    "{",
                    '"credentialId": "',
                    request.credentialId,
                    '",',
                    '"verifierAddress": "',
                    request.verifierAddress,
                    '",',
                    '"requestId": "',
                    request.requestId,
                    '",',
                    '"userDid": "',
                    request.userDid,
                    '",',
                    '"otherInfo": "',
                    request.otherInfo,
                    '"}'
                )
            );
    }
  
}
