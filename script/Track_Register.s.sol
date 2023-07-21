// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "src/Track_Register.sol";

contract TrackScript is Script {
    Track_Register public registry;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);
            registry = new Track_Register();
        vm.stopBroadcast();
    }
}

//forge script script/Track_Register.s.sol:TrackScript --rpc-url $RPC_URL --broadcast --slow --verify -vvvv

