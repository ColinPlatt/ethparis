// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/TrackURI.sol";

contract URITest is Test {

    address constant track = 0x94c16a950D0e044ef12BbC1705c237D89474Be5B;
    TrackURI public uri;

    constructor(){
        uri = new TrackURI(track);
    }

    function testSetup() public {
        emit log_address(address(uri));
    }




}