// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {LibString} from "lib/solady/src/Milady.sol";
import {Base64} from "lib/solady/src/utils/Base64.sol";
import {HTML, libBrowserProvider, libJsonRPCProvider} from "lib/ethers.sol/src/ethers.sol";


contract TrackURI {

    address public immutable trackAddr;

    constructor(address _trackAddr) {
        trackAddr = _trackAddr;
    }

    // this is our main entry point to return the full html
    function renderUI() external view returns (string memory) {
        


    }



}


