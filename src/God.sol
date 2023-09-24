// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {OwnerManager} from "./base/OwnerManager.sol";
import {Enum} from "./common/Enum.sol";
import {ISafe} from "./interfaces/ISafe.sol";

contract God {

    bytes32 private constant DOMAIN_SEPARATOR_TYPEHASH =
        0x035aff83d86937d35b32e04f0ddc6ff469290eef2f1b692d8a815c89404d4749;
    bytes32 private constant SAFE_TX_TYPEHASH = 0x66f22472c9f42fa1a5d7e86b0d9391ec47830a4ec8e1a2780ea24f00067ae39b;
    
    uint256 public nonce;
    address public immutable xSafe;
    address public immutable safe;

    constructor(address _safe, address _xSafe) {
        safe = _safe;
        xSafe = _xSafe;
    }

    function signatureSplit(bytes memory signatures, uint256 pos) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        assembly {
            let signaturePos := mul(0x41, pos)
            r := mload(add(signatures, add(signaturePos, 0x20)))
            s := mload(add(signatures, add(signaturePos, 0x40)))
            v := byte(0, mload(add(signatures, add(signaturePos, 0x60))))
        }
    }

    function execTx(
        address app,
        uint256 value,
        bytes calldata data,
        bytes memory signatures
    ) public payable virtual returns (bool) {
        // 1. Check sender
        require(msg.sender == xSafe, "Unauthorized.");
        
        // 2. Check signatures
        bytes32 txHash = getTransactionHash(
            app,
            value,
            data,
            1
        );

        address currentOwner;
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 i;

        uint256 threshold = ISafe(safe).getThreshold();

        for (i = 0; i < threshold; i++) {
            (v, r, s) = signatureSplit(signatures, i);
            currentOwner = ecrecover(txHash, v, r, s);
            bool isOwner = ISafe(safe).isOwner(currentOwner);
            require(isOwner, "Unauthorized.");
        }
        
        // 3. Execute transaction
        ISafe(safe).execTransactionFromModule(app, value, data, Enum.Operation.Call);

        // 4. Return true
        return true;
    }


    function domainSeparator() public view returns (bytes32) {
        // this should be the same address on all chains
        return keccak256(abi.encode(DOMAIN_SEPARATOR_TYPEHASH, this));
    }


    function encodeTransactionData(address app, uint256 value, bytes calldata data, uint256 _nonce)
        private
        view
        returns (bytes memory)
    {
        bytes32 safeTxHash = keccak256(abi.encode(SAFE_TX_TYPEHASH, app, value, keccak256(data), _nonce));
        return abi.encodePacked(bytes1(0x19), bytes1(0x01), domainSeparator(), safeTxHash);
    }

    function getTransactionHash(address app, uint256 value, bytes calldata data, uint256 _nonce)
        public
        view
        returns (bytes32)
    {
        return keccak256(encodeTransactionData(app, value, data, _nonce));
    }
}
