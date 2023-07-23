// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "lib/solady/src/Milady.sol";
import "./Elements.sol";

interface IERC721 {
    function balanceOf(address) external view returns(uint256);
}

contract Track_Register is Ownable {
    struct SLOT {
        uint8[4] channels;
    }

    struct TRACK {
        SLOT[10] slot;
    }

    mapping(uint256 => TRACK) tracks;
    mapping(uint256 => address) trackOwner;

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
        _initElementFunctions(10, Elements.bassline0, "bassline0");
        _initElementFunctions(3, Elements.bassline1, "bassline1");
        _initElementFunctions(4, Elements.drumkick0, "drumkick0");
        _initElementFunctions(5, Elements.drumkick1, "drumkick1");
        _initElementFunctions(6, Elements.techno, "techno");
        _initElementFunctions(7, Elements.deadmau5, "deadmau5");
        _initElementFunctions(8, Elements.danzfloor, "danzfloor");
        _initElementFunctions(9, Elements.industrial, "industrial");
        _initElementFunctions(2, Elements.modulator, "modulator");
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

    uint256 public MAX_TRACKS;

    function createNewTrack(address contractAddress) public onlyOwner {
        trackOwner[MAX_TRACKS] = contractAddress;
        MAX_TRACKS++;

    }

    function writeToSlot(uint256 track, uint256 slot, uint256 channel, uint8 element) public {
        require(track < MAX_TRACKS, "invalid track");
        require(IERC721(trackOwner[track]).balanceOf(msg.sender) != 0, "not authorized");
        tracks[track].slot[slot].channels[channel] = element;
    }

    function readTrack(uint256 track) public view returns (bytes memory) {
        require(track < MAX_TRACKS, "invalid track");

        return abi.encode(tracks[track]);
    }
}
