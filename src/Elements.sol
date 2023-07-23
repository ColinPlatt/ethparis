// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "lib/solady/src/Milady.sol";

library Elements {
    uint256 constant SAMPLE_RATE = 8000;
    uint256 constant LENGTH = 6;

    function bassline0() internal pure returns (bytes memory) {
        bytes memory buf = new bytes(SAMPLE_RATE*LENGTH);

        unchecked {
            for (uint256 t; t < (SAMPLE_RATE * LENGTH); ++t) {
                buf[t] = bytes1(uint8(t / 20 << (t / 40)));
            }
        }

        return buf;
    }

    function bassline1() internal pure returns (bytes memory) {
        bytes memory buf = new bytes(SAMPLE_RATE*LENGTH);

        unchecked {
            for (uint256 t; t < (SAMPLE_RATE * LENGTH); ++t) {
                buf[t] = bytes1(uint8(t / 20 | t ** (t % 10000 > 1000 ? 1: 0) & t >> 4));
            }
        }

        return buf;
    }

    function drumkick0() internal pure returns (bytes memory) {
        bytes memory buf = new bytes(SAMPLE_RATE*LENGTH);

        unchecked {
            for (uint256 t; t < (SAMPLE_RATE * LENGTH); ++t) {
                buf[t] = bytes1(uint8(t / 20));
            }
        }

        return buf;
    }

    function drumkick1() internal pure returns (bytes memory) {
        bytes memory buf = new bytes(SAMPLE_RATE*LENGTH);

        unchecked {
            for (uint256 t; t < (SAMPLE_RATE * LENGTH); ++t) {
                buf[t] = bytes1(uint8(t / 10));
            }
        }

        return buf;
    }

    function techno() internal pure returns (bytes memory) {
        bytes memory buf = new bytes(SAMPLE_RATE*LENGTH);

        unchecked {
            for (uint256 t; t < (SAMPLE_RATE * LENGTH); ++t) {
                buf[t] = bytes1(uint8(t/20&100));
            }
        }

        return buf;
    }

    function deadmau5() internal pure returns (bytes memory) {
        bytes memory buf = new bytes(SAMPLE_RATE*LENGTH);

        unchecked {
            for (uint256 t; t < (SAMPLE_RATE * LENGTH); ++t) {
                buf[t] = bytes1(uint8(t&128 | t&64 & t/20 ^ t/15));
            }
        }

        return buf;
    }

    function danzfloor() internal pure returns (bytes memory) {
        bytes memory buf = new bytes(SAMPLE_RATE*LENGTH);

        unchecked {
            for (uint256 t; t < (SAMPLE_RATE * LENGTH); ++t) {
                buf[t] = bytes1(uint8((t*4|t|t>>3&t+t/4&t*12|t*8>>10|t/20&t+140)&t>>4));
            }
        }

        return buf;
    }

    function industrial() internal pure returns (bytes memory) {
        bytes memory buf = new bytes(SAMPLE_RATE*LENGTH);

        unchecked {
            for (uint256 t; t < (SAMPLE_RATE * LENGTH); ++t) {
                buf[t] = bytes1(uint8(((t/4)>>(t/4))>>(t>>(t/8))|t>>2));
            }
        }

        return buf;
    }

    function modulator() internal pure returns (bytes memory) {
        bytes memory buf = new bytes(SAMPLE_RATE*LENGTH);

        unchecked {
            for (uint256 t; t < (SAMPLE_RATE * LENGTH); ++t) {
                buf[t] = bytes1(uint8(t/20 | t&64));
            }
        }

        return buf;
    }

    function arabic() internal pure returns (bytes memory) {
        //t%((t&-16|t>>10)&42)<<2|t>>4
        bytes memory buf = new bytes(SAMPLE_RATE*LENGTH);

        uint256 u;

        unchecked {
            for (uint256 t; t < (SAMPLE_RATE * LENGTH); ++t) {
                u = uint256(int256(t) & -int256(16)) | t >> 10 & 42;
                buf[t] = bytes1(uint8(u == 0 ? 0 : t % u << 2 | t >> 4));
            }
        }

        return buf;
    }


    /////////////////////////////////////

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

    function time_is_running_out() internal pure returns (bytes memory) {
        //t*(t&16384?7:5)*(3-(3&t>>9)+(3&t>>8))>>(3&-t>>(t%65536<59392?t&4096?2:16:2))|t>>3

        bytes memory buf = new bytes(SAMPLE_RATE*LENGTH);

        unchecked {
            for (uint256 t; t < (SAMPLE_RATE * LENGTH); ++t) {
                buf[t] = bytes1(
                    uint8(
                        (
                            t * (t & 16384 == 0 ? 7 : 5) * (uint256(3 - int256(3 & t >> 9)) + (3 & t >> 8))
                                >> (uint256(int256(3) & -int256(t)))
                                >> (((t % 65536) < 59392) ? ((t & 4096) == uint256(0)) ? 2 : 16 : 2)
                        ) | t >> 3
                    )
                );
            }
        }

        return buf;
    }

    function number_5() internal pure returns (bytes memory) {
        //(u=3*t>>t/4096%4&-t%(t>>16|16)*t)/(u>>6|1)*4

        bytes memory buf = new bytes(SAMPLE_RATE*LENGTH);

        uint256 u;

        unchecked {
            for (uint256 t; t < (SAMPLE_RATE * LENGTH); ++t) {
                u = 3 * t >> uint256(int256(t / 4096 % 4) & -int256(t)) % (t >> 16 | 16) * t >> 14 & 8191;
                buf[t] = bytes1(uint8(u / (u >> 6 | 1) * 4));
            }
        }

        return buf;
    }

    function blueberry() internal pure returns (bytes memory) {
        //t*(((t>>9)^((t>>9)-1)^1)%13)
        bytes memory buf = new bytes(SAMPLE_RATE*LENGTH);

        unchecked {
            for (uint256 t; t < (SAMPLE_RATE * LENGTH); ++t) {
                buf[t] = bytes1(uint8(t * (((t >> 9) ^ ((t >> 9) - 1) ^ 1) % 13)));
            }
        }

        return buf;
    }

    function explosions() internal pure returns (bytes memory) {
        //(t>>4)*(t>>3)|t>>3
        bytes memory buf = new bytes(SAMPLE_RATE*LENGTH);

        unchecked {
            for (uint256 t; t < (SAMPLE_RATE * LENGTH); ++t) {
                buf[t] = bytes1(uint8((t >> 4) * (t >> 3) | t >> 3));
            }
        }

        return buf;
    }

    function running_man() internal pure returns (bytes memory) {
        //(t*((3+(1^t>>10&5))*(5+(3&t>>14))))>>(t>>8&3)
        bytes memory buf = new bytes(SAMPLE_RATE*LENGTH);

        unchecked {
            for (uint256 t; t < (SAMPLE_RATE * LENGTH); ++t) {
                buf[t] = bytes1(uint8(t * ((3 + (1 ^ t >> 10 & 5)) * (5 + (3 & t >> 14)))) >> (t >> 8 & 3));
            }
        }

        return buf;
    }

    //sierpinski
    function sierpinski() internal pure returns (bytes memory) {
        //t&t>>8
        bytes memory buf = new bytes(SAMPLE_RATE*LENGTH);

        unchecked {
            for (uint256 t; t < (SAMPLE_RATE * LENGTH); ++t) {
                buf[t] = bytes1(uint8(t & t >> 8));
            }
        }

        return buf;
    }

    function bassline() internal pure returns (bytes memory) {
        //(~t>>2)*((127&t*(7&t>>10))<(245&t*(2+(5&t>>14))))
        bytes memory buf = new bytes(SAMPLE_RATE*LENGTH);

        unchecked {
            for (uint256 t; t < (SAMPLE_RATE * LENGTH); ++t) {
                buf[t] =
                    bytes1(uint8((~t >> 2) * (((127 & t * (7 & t >> 10)) < (245 & t * (2 + (5 & t >> 14)))) ? 1 : 0)));
            }
        }

        return buf;
    }

    function dialup() internal pure returns (bytes memory) {
        //10*((t<<3|t>>5|t^63)&(t<<10|t>>12))
        bytes memory buf = new bytes(SAMPLE_RATE*LENGTH);

        unchecked {
            for (uint256 t; t < (SAMPLE_RATE * LENGTH); ++t) {
                buf[t] = bytes1(uint8(10 * ((t << 3 | t >> 5 | t ^ 63) & (t << 10 | t >> 12))));
            }
        }

        return buf;
    }

    uint256 constant OFFSET = SAMPLE_RATE * LENGTH;

    function dialup2() internal pure returns (bytes memory) {
        //10*((t<<3|t>>5|t^63)&(t<<10|t>>12))
        bytes memory buf = new bytes(SAMPLE_RATE*LENGTH);

        unchecked {
            for (uint256 t = OFFSET; t < (OFFSET + (SAMPLE_RATE * LENGTH)); ++t) {
                buf[t - OFFSET] = bytes1(uint8(10 * ((t << 3 | t >> 5 | t ^ 63) & (t << 10 | t >> 12))));
            }
        }

        return buf;
    }
}
