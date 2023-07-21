// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "lib/solady/src/Milady.sol";

library Elements {
    uint256 constant SAMPLE_RATE = 8000;
    uint256 constant LENGTH = 6;

    function drum() internal pure returns (bytes memory) {
        bytes memory buf = new bytes(SAMPLE_RATE*LENGTH);

        unchecked {
            for (uint256 t; t < (SAMPLE_RATE * LENGTH); ++t) {
                buf[t] = bytes1(uint8(t >> 4));
            }
        }

        return buf;
    }

    function drum_fast() internal pure returns (bytes memory) {
        bytes memory buf = new bytes(SAMPLE_RATE*LENGTH);

        unchecked {
            for (uint256 t; t < (SAMPLE_RATE * LENGTH); ++t) {
                buf[t] = bytes1(uint8(2 * (t >> 4)));
            }
        }

        return buf;
    }

    function time_is_running_out() internal pure returns (bytes memory){
        //t*(t&16384?7:5)*(3-(3&t>>9)+(3&t>>8))>>(3&-t>>(t%65536<59392?t&4096?2:16:2))|t>>3

        bytes memory buf = new bytes(SAMPLE_RATE*LENGTH);

        unchecked {
            for (uint256 t; t < (SAMPLE_RATE * LENGTH); ++t) {
                buf[t] = bytes1(uint8((t*(t&16384==0?7:5)*(uint(3-int(3&t>>9))+(3&t>>8))>>(uint(int(3)&-int(t)))>>(((t%65536)<59392)?((t&4096)==uint(0))?2:16:2))|t>>3));
            }
        }

        return buf;
    }

    function number_5() internal pure returns (bytes memory) {
        //(u=3*t>>t/4096%4&-t%(t>>16|16)*t)/(u>>6|1)*4

        bytes memory buf = new bytes(SAMPLE_RATE*LENGTH);
        
        uint u;

        unchecked {
            for (uint256 t; t < (SAMPLE_RATE * LENGTH); ++t) {
                u=3*t>>uint(int(t/4096%4)&-int(t))%(t>>16|16)*t>>14&8191;
                buf[t] = bytes1(uint8(u/(u>>6|1)*4));
            }
        }

        return buf;
    }
}
