// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

contract VerifiableCredential {
    struct Credential {
        string credentialId;
        address issuer;
        string userDid;
        string data;
        bool isRevoked;
        bytes signature;
    }

    mapping(bytes32 => Credential) public credentials;


    function getMessageHash(string memory userDid, string memory credentialId) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(userDid, credentialId));
    }

    function getMessageHashHex(string memory userDid, string memory credentialId) public pure returns (string memory) {
        return convertBytes32ToHex(getMessageHash(userDid, credentialId));
    }

    function issue(
        string memory userDid,
        string memory credentialId,
        string memory data,
        bytes memory signature
    ) public {
        bytes32 id = generateId(userDid, credentialId);

        credentials[id] = Credential(
            credentialId,
            msg.sender,
            userDid,
            data,
            false,
            signature
        );
    }

    function getCredential(string memory userDid, string memory credentialId) public view returns (string memory) {
        bytes32 id = generateId(userDid, credentialId);

        Credential memory credential = credentials[id];
        return
            string(
                abi.encodePacked(
                    "{",
                    '"issuer": "',
                    toString(credential.issuer),
                    '",',
                    '"userDid": "',
                    credential.userDid,
                    '",',
                    '"data": "',
                    credential.data,
                    '",',
                    '"credentialId": "',
                    credential.credentialId,
                    '",',
                    '"isRevoked": "',
                    boolToString(credential.isRevoked),
                    '", "signature": "',
                    toString(credential.signature),
                    '"}'
                )
            );
    }

    function verify(string memory userDid, string memory credentialId) public view returns (bool isValid) {
        bytes32 id = generateId(userDid, credentialId);

        Credential storage credential = credentials[id];
        if (credential.isRevoked) {
            return false;
        }
     
        bytes32 hashMessage = getMessageHash(credential.userDid, credential.credentialId);
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hashMessage));


        return recoverSigner(ethSignedMessageHash, credential.signature) == credential.issuer;

    }

    function revoke(string memory userDid, string memory credentialId) public {
        bytes32 id = generateId(userDid, credentialId);

        require(msg.sender == credentials[id].issuer, "Only issuer can revoke this credential");
        credentials[id].isRevoked = true;
    }

    function generateId(string memory userDid, string memory credentialId) public pure returns (bytes32) {
        bytes32 id = keccak256(
            abi.encodePacked(userDid, credentialId)
        );

        return id;
    }

    function toString(address account) internal pure returns (string memory) {
        return toString(abi.encodePacked(account));
    }

    function toString(uint256 value) internal pure returns (string memory) {
        return toString(abi.encodePacked(value));
    }

    function toString(bytes memory data) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint i = 0; i < data.length; i++) {
            str[2 + i * 2] = alphabet[uint(uint8(data[i] >> 4))];
            str[3 + i * 2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }

    function convertBytes32ToHex(bytes32 _value) internal pure returns (string memory) {
        return Strings.toHexString(uint256(_value));
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        internal
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        internal
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        ) {
        // Check the length of the signature, 65 is the standard length for r, s, v signature.
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 0x20))
            // second 32 bytes
            s := mload(add(sig, 0x40))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 0x60)))
        }

        // implicitly return (r, s, v)
    }

    function boolToString(bool _b) internal pure returns (string memory) {
        return _b ? "true" : "false";
    }

}
