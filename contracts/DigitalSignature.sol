// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DigitalSignature {

    function getMessageHash(address _addr, string memory _data ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_addr, _data));
    }
    
    function getMessageHashFromTokenId(address _addr, uint256 _tokenId ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_addr, _tokenId));
    }

    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256( abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash) );
    }

    function verify( address _signer, address _addr, uint _tokenId, bytes memory signature ) public pure returns (bool) {
        bytes32 messageHash = getMessageHashFromTokenId(_addr, _tokenId);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }

    function verify( address _signer, address _addr, string memory _tokenId, bytes memory signature ) public pure returns (bool) {
        bytes32 messageHash = getMessageHash(_addr, _tokenId);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        public
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
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
}