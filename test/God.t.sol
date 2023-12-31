// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {God} from "../src/God.sol";
import {Counter} from "../src/Counter.sol";
import "forge-std/console.sol";

contract GodTest is Test {
    God public god;

    address public constant safe = 0x983188C8617C7C4AE49f8C0D51e98B1C738dA830;  //goerli safe
    address public constant counter = 0x49A33490734f465802Dcb88a903401e9d0Ec779d;
    address public constant web2Account = 0x8ccF9A42fACA5a2FB46E4F0456AA8F3C8FABAf95;

    bytes32 public constant txHash = 0x252f474661272b6f9a5cef3a5660f313785eb5466aa00b18f5b74ad4b4c96620;
    uint256 public constant signer1PK = ; //redacted
    uint256 public constant signer2PK = ; //redacted

    function setUp() public {
        god = new God(safe, web2Account);
    }

    function test_execTx() public {
        bytes memory data = abi.encodeWithSelector(Counter.increment.selector);
        console.logBytes(data);

        // address signer1 = vm.addr(signer1PK);
        // address signer2 = vm.addr(signer2PK);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signer1PK, txHash);
        bytes memory sig1 = abi.encodePacked(r, s, v);

        (v, r, s) = vm.sign(signer2PK, txHash);
        bytes memory sig2 = abi.encodePacked(r, s, v);

        console.log("\n\n\nsig 1:");
        console.logBytes(sig1);
        console.log("\n\n\nsig 2:");
        console.logBytes(sig2);

        // bytes memory sig1 = bytes("a99c372658c1e1dd46eb53cbdf36bcb364be2c611952bcb0bce8201c18e651206acf02f7167d3b6d1c997e38975c68bfc9ae6ddfb36e21423ad25f09e7a864a21c");
        // bytes memory sig2 = bytes(0x43c0b9f2f69176d7fe24c5f6bf191c5da75b164f0a2270c5c02a741c665b71b6063bedf8be6191263c56b4b29c8beeb9b2f4351a8bf31ba52112038f5ad447901b);

        // bytes memory sigs = bytes.concat(sig1, sig2);
        bytes memory sigs = bytes.concat(sig2, sig1);

        
        console.log("\n\n\nsigs:");
        console.logBytes(sigs);

        vm.prank(web2Account);
        god.execTx(counter, 0, data, sigs);
    }
}
