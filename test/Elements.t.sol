// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Elements.sol";

contract ElementsTest is Test {

    function testDrums() public {

        bytes memory res = Elements.drum();

        emit log_named_bytes("drums", res);

    }

    function testDrumsFast() public {

        bytes memory res = Elements.drum_fast();

        emit log_named_bytes("drums fast", res);

    }

    function testTime() public {

        bytes memory res = Elements.time_is_running_out();

        emit log_named_bytes("time is running out", res);

    }

    function testNumber5() public {

        bytes memory res = Elements.number_5();

        emit log_named_bytes("number 5", res);

    }




}
