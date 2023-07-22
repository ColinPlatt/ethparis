// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "lib/solady/src/Milady.sol";
import "./Elements.sol";

contract Track_Register is Ownable {
    struct SLOT {
        uint8[4] channels;
    }

    struct TRACK {
        SLOT[10] slot;
    }

    mapping(uint256 => TRACK) tracks;

    struct ELEMENT {
        string name;
        function() internal pure returns(bytes memory) fn;
    }

    mapping(uint8 => ELEMENT) elements;

    constructor() {
        _initializeOwner(msg.sender);
        _initialize();
    }

    // start loading Elements at 1, 0 is uninitilized
    function _initElementFunctions(uint8 idx, function() internal pure returns(bytes memory) _fn, string memory _name)
        internal
    {
        elements[idx] = ELEMENT(_name, _fn);
    }

    function _initialize() internal {
        _initElementFunctions(1, Elements.arabic, "arabic");
        _initElementFunctions(2, Elements.bassline, "bassline");
        _initElementFunctions(3, Elements.blueberry, "blueberry");
        _initElementFunctions(4, Elements.drum, "drum");
        _initElementFunctions(5, Elements.drum_fast, "drum fast");
        _initElementFunctions(6, Elements.time_is_running_out, "time is running out");
        _initElementFunctions(7, Elements.explosions, "explosions");
        _initElementFunctions(8, Elements.running_man, "running_man");
        _initElementFunctions(9, Elements.sierpinski, "sierpinski");
        _initElementFunctions(10, Elements.dialup, "dialup");
        _initElementFunctions(11, Elements.dialup2, "dialup2");
    }

    function playElement(uint8 idx) public view returns (bytes memory) {
        return elements[idx].fn();
    }

    function elementName(uint8 idx) public view returns (string memory) {
        return elements[idx].name;
    }

    function getElement(uint8 idx) public view returns (string memory, bytes memory) {
        return (elements[idx].name, elements[idx].fn());
    }

    uint public constant MAX_TRACKS = 2;

    function writeToSlot(uint256 track, uint256 slot, uint256 channel, uint8 element) public {
        require(track < MAX_TRACKS, 'invalid track');
        tracks[track].slot[slot].channels[channel] = element;
    }

    function readTrack(uint256 track) public view returns (bytes memory) {
        require(track < MAX_TRACKS, 'invalid track');

        return abi.encode(tracks[track]);
    }


}
