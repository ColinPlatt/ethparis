// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "src/Track_Register.sol";
import "src/TrackScripts.sol";
import "src/TrackURI.sol";
import "src/MockERC721.sol";

contract TrackScript is Script {
    Track_Register public registry;
    MockERC721 public BAYC;
    MockERC721 public NOUNS;
    TrackURI public uri;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);
            BAYC = new MockERC721("Bored Ape Yacht Club", "BAYC");
            NOUNS = new MockERC721("NounsDAO", "NOUNS");

            registry = new Track_Register();
            registry.createNewTrack(address(BAYC));
            registry.createNewTrack(address(NOUNS));
            for(uint i; i<10; ++i){
                registry.writeToSlot(0, i, 0, uint8(i));
            }
            uri = new TrackURI(address(registry));
        vm.stopBroadcast();
    }
}


contract FillGridScript is Script {
    Track_Register public registry = Track_Register(0x6F9bc2c85521f0FbDe8F8Bc40Aa5ed8Fdd3b9B92);
    TrackURI public uri;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // track, slot, channel, val


            registry.writeToSlot(0, 0, 2, uint8(0));
            registry.writeToSlot(0, 1, 2, uint8(0));
            registry.writeToSlot(0, 2, 2, uint8(0));
            registry.writeToSlot(0, 3, 2, uint8(0));
            registry.writeToSlot(0, 4, 2, uint8(0));
            registry.writeToSlot(0, 5, 2, uint8(0));
            registry.writeToSlot(0, 6, 2, uint8(0));
            registry.writeToSlot(0, 7, 2, uint8(0));
            registry.writeToSlot(0, 8, 2, uint8(0));
            registry.writeToSlot(0, 9, 2, uint8(0));

        vm.stopBroadcast();
    }
}


contract TrackURIScript is Script {
    Track_Register public registry = Track_Register(0x2Fb2ba909F2D2B55c4A70AEaE54cFFba2cE72205);
    TrackURI public uri;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);
        uri = new TrackURI(address(registry));
        vm.stopBroadcast();
    }
}

//forge script script/Track_Register.s.sol:TrackScript --rpc-url $RPC_URL --broadcast --slow --verify -vvvv

//forge script script/Track_Register.s.sol:TrackURIScript --rpc-url $RPC_ALT --broadcast --slow --verify -vvvv
