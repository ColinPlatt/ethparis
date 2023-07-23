// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Elements.sol";
import "lib/libAudio/src/libWAV.sol";

contract ElementsTest is Test {
    using WAV_8BIT for bytes;

    function testDrums() public {
        bytes memory res = Elements.drum();

        //emit log_named_bytes("drums", res);

        string memory encodedWAV = res.encodeWAV(8000);
        emit log_string(encodedWAV);
        _writeAsSite("drums", encodedWAV);
    }

    function testsawTooth() public {
        bytes memory res = Elements.industrial();

        //emit log_named_bytes("drums fast", res);

        string memory encodedWAV = res.encodeWAV(8000);
        emit log_string(encodedWAV);
        _writeAsSite("sawTooth", encodedWAV);
    }

    function testDrumsFast() public {
        bytes memory res = Elements.drum_fast();

        //emit log_named_bytes("drums fast", res);

        string memory encodedWAV = res.encodeWAV(8000);
        emit log_string(encodedWAV);
        _writeAsSite("drums_fast", encodedWAV);
    }

    function testTime() public {
        bytes memory res = Elements.time_is_running_out();

        //emit log_named_bytes("time is running out", res);

        string memory encodedWAV = res.encodeWAV(8000);
        emit log_string(encodedWAV);
        _writeAsSite("time_is_running_out", encodedWAV);
    }

    function testNumber5() public {
        bytes memory res = Elements.number_5();

        //emit log_named_bytes("number 5", res);

        string memory encodedWAV = res.encodeWAV(8000);
        emit log_string(encodedWAV);
        _writeAsSite("number5", encodedWAV);
    }

    function testBlueberry() public {
        bytes memory res = Elements.blueberry();

        //emit log_named_bytes("number 5", res);

        string memory encodedWAV = res.encodeWAV(8000);
        emit log_string(encodedWAV);
        _writeAsSite("blueberry", encodedWAV);
    }

    function testExplosions() public {
        bytes memory res = Elements.explosions();

        //emit log_named_bytes("number 5", res);

        string memory encodedWAV = res.encodeWAV(8000);
        emit log_string(encodedWAV);
        _writeAsSite("explosions", encodedWAV);
    }

    function testArabic() public {
        bytes memory res = Elements.arabic();

        string memory encodedWAV = res.encodeWAV(8000);
        emit log_string(encodedWAV);
        _writeAsSite("arabic", encodedWAV);
    }

    function testRunningMan() public {
        bytes memory res = Elements.running_man();

        string memory encodedWAV = res.encodeWAV(8000);
        emit log_string(encodedWAV);
        _writeAsSite("running_man", encodedWAV);
    }

    function testSiepinksi() public {
        bytes memory res = Elements.sierpinski();

        string memory encodedWAV = res.encodeWAV(8000);
        emit log_string(encodedWAV);
        _writeAsSite("sierpinski", encodedWAV);
    }

    function testBassline() public {
        bytes memory res = Elements.bassline();

        string memory encodedWAV = res.encodeWAV(8000);
        emit log_string(encodedWAV);
        _writeAsSite("bassline", encodedWAV);
    }

    function testDialup() public {
        bytes memory res = Elements.dialup();

        string memory encodedWAV = res.encodeWAV(8000);
        emit log_string(encodedWAV);
        _writeAsSite("dialup", encodedWAV);
    }

    function testDialup2() public {
        bytes memory res = Elements.dialup2();

        string memory encodedWAV = res.encodeWAV(8000);
        emit log_string(encodedWAV);
        _writeAsSite("dialup2", encodedWAV);
    }

    function _writeAsSite(string memory _filename, string memory _data) internal {
        string memory site = string.concat(
            '<!DOCTYPE html><html><head><meta charset="utf-8"><title>WAV</title></head><body><audio controls loop><source src="',
            _data,
            '" type="audio/wav"></audio></body></html>'
        );

        vm.writeFile(string.concat("test/output/", _filename, ".html"), site);
    }
}
