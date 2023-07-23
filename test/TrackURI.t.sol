// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/TrackURI.sol";
import "src/Track_Register.sol";

contract URITest is Test {
    address constant trackaddr = 0x2Fb2ba909F2D2B55c4A70AEaE54cFFba2cE72205;
    TrackURI public uri;

    constructor() {
        uri = new TrackURI(trackaddr);
    }

    function testSetup() public {
        Track_Register registry;
        registry = new Track_Register();
        registry.writeToSlot(0, 6, 3, 4);
        emit log_bytes(abi.encode(0, 6, 3, 4));

        emit log_address(address(uri));
        bytes memory track = registry.readTrack(0);

        emit log_bytes(track);

        //registry.writeToSlot(0, 6, 3, 4);
    }

    function testUI() public {
        string memory result = uri.contractURI(0);

        vm.writeFile("test/output/ui.html", result);
    }
}
