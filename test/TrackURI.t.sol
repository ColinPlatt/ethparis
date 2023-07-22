// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/TrackURI.sol";
import "src/Track_Register.sol";

contract URITest is Test {
    address constant trackaddr = 0xb0eCDA741150D8e975234684B59e44c20C86c2e5;
    TrackURI public uri;

    constructor() {
        uri = new TrackURI(trackaddr);
    }

    function testSetup() public {
        Track_Register registry;
        registry = new Track_Register();
        registry.writeToSlot(0, 6, 3, 4);
        emit log_bytes(abi.encode(0,6,3,4));

        emit log_address(address(uri));
        uint[10][4] memory track = registry.readTrack(0);

        for(uint i = 0; i<4; ++i) {
            for(uint j=0; j<10; ++j) {
                emit log_named_uint(string.concat("i: ", vm.toString(i), " j: ", vm.toString(j)), track[i][j]);
            }
        }

        //registry.writeToSlot(0, 6, 3, 4);
    }

    function testUI() public {
        string memory result = uri.renderUI();

        vm.writeFile("test/output/ui.html", result);
    }
}
