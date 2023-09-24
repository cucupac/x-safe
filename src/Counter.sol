// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract God {
    // keccak256(
    //     "EIP712Domain(address verifyingContract)"
    // );
    bytes32 private constant DOMAIN_SEPARATOR_TYPEHASH =
        0x035aff83d86937d35b32e04f0ddc6ff469290eef2f1b692d8a815c89404d4749;

    // keccak256(
    //     ""SafeTx(address to,uint256 value,bytes data,uint256 nonce)""
    // );
    bytes32 private constant SAFE_TX_TYPEHASH = 0x66f22472c9f42fa1a5d7e86b0d9391ec47830a4ec8e1a2780ea24f00067ae39b;

    /**
     * @dev Returns the domain separator for this contract, as defined in the EIP-712 standard.
     * @return bytes32 The domain separator hash.
     */
    function domainSeparator() public view returns (bytes32) {
        // this should be the same address on all chains
        return keccak256(abi.encode(DOMAIN_SEPARATOR_TYPEHASH, this));
    }

    /**
     * @notice Returns the pre-image of the transaction hash (see getTransactionHash).
     * @param app Destination address.
     * @param value Ether value.
     * @param data Data payload.
     * @param _nonce Transaction nonce.
     * @return Transaction hash bytes.
     */
    function encodeTransactionData(address app, uint256 value, bytes calldata data, uint256 _nonce)
        private
        view
        returns (bytes memory)
    {
        bytes32 safeTxHash = keccak256(abi.encode(SAFE_TX_TYPEHASH, app, value, keccak256(data), _nonce));
        return abi.encodePacked(bytes1(0x19), bytes1(0x01), domainSeparator(), safeTxHash);
    }

    /**
     * @notice Returns transaction hash to be signed by owners.
     * @param app Destination address.
     * @param value Ether value.
     * @param data Data payload.
     * @param _nonce Transaction nonce.
     * @return Transaction hash.
     */
    function getTransactionHash(address app, uint256 value, bytes calldata data, uint256 _nonce)
        public
        view
        returns (bytes32)
    {
        return keccak256(encodeTransactionData(app, value, data, _nonce));
    }
}
