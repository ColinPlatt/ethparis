// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "lib/solady/src/Milady.sol";

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
    }

    function _initElementFunctions(uint8 idx, function() internal pure returns(bytes memory) _fn, string memory _name)
        internal
    {
        elements[idx] = ELEMENT(_name, _fn);
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

    function writeToSlot(uint256 track, uint256 slot, uint256 channel, uint8 element) public {
        tracks[track].slot[slot].channels[channel] = element;
    }
}
