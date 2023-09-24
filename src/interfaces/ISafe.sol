// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Enum} from "../common/Enum.sol";

interface ISafe {
    function checkSignatures(bytes32 dataHash, bytes memory data, bytes memory signatures) external;

    function execTransactionFromModule(
        address app,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) external returns (bool success);
}


