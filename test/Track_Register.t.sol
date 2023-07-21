// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Track_Register.sol";

import "lib/libAudio/src/libWAV.sol";

contract Track_RegisterTests is Test {
    Track_Register public registry;

    constructor() {
        registry = new Track_Register();
    } 

    function testRetrieve() public {
        bytes memory res = registry.playElement(1);

        assertEq(res, Elements.arabic());
    }

    function testCall() public {

        bytes memory call = abi.encodeWithSignature("playElement(uint8)", uint8(1));

        emit log_bytes(call);

    }

}