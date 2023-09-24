// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Counter {
    uint256 public number;
    address public safe;

    constructor (address _safe) {
        safe = _safe;
    }

    function increment() public {
        require(msg.sender == safe, "Only the safe can increment the counter.");
        number++;
    }
}