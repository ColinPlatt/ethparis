// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {LibString} from "lib/solady/src/Milady.sol";
import {Base64} from "lib/solady/src/utils/Base64.sol";
import "lib/ethers.sol/src/ethers.sol";

contract TrackURI {
    using HTML for string;

    address public immutable trackAddr;

    constructor(address _trackAddr) {
        trackAddr = _trackAddr;
    }

    // this is our main entry point to return the full html
    function renderUI() external view returns (string memory) {
        html memory page; // initializing a new HTML page

        return _getPage(page);

    }

    function _writeHead(html memory _page) internal view {

        _page.meta(
            HTML.prop('charset', 'UTF-8')
        );
        _page.meta(
            string.concat(
                HTML.prop('name', 'viewport'),
                HTML.prop('content', 'width=device-width, initial-scale=1.0')
            )
        );
        _page.title("Cacophony");

    }

    function _writeBody(html memory _page) internal view {

        _page.p_("hello");

    }


    function _getPage(html memory _page) internal view returns (string memory) {

        _writeHead(_page);
        _writeBody(_page);

        _page.style(trackCSS.getCSS());


        return (_page.read());
    }



}

library trackCSS {
    using HTML for string;


    function getCSS() internal pure returns (string memory) {
        css memory style;

        _getFullHeaderBar(style);
        _getMainEls(style);

        return style.readCSS();
    }

    function _getTitleCSS(css memory _style) private pure {
        _style.addCSSElement(
            ".title",
            string.concat(
                string("font-size").cssDecl("1.5em"),
                string("font-weight").cssDecl("600"),
                string("font-family").cssDecl("inherit"),
                string("color").cssDecl("#fff"),
                string("margin").cssDecl("0")
            )
        );
    }

    function _getHeaderBarCSS(css memory _style) private pure {
        _style.addCSSElement(
            "#header-bar",
            string.concat(
                string("display").cssDecl("flex"),
                string("justify-content").cssDecl("space-between"),
                string("align-items").cssDecl("center"),
                string("padding").cssDecl("5px"),
                string("height").cssDecl("35px"),
                string("position").cssDecl("fixed"),
                string("top").cssDecl("0"),
                string("width").cssDecl("100%"),
                string("z-index").cssDecl("999")
            )
        );
    }

    function _getTopRight(css memory _style) private pure {
        _style.addCSSElement(
            ".top-right",
            string.concat(
                string("display").cssDecl("flex"),
                string("align-items").cssDecl("center"),
                string("right").cssDecl("15px"),
                string("padding-right").cssDecl("25px")
            )
        );
    }

    function _getDotCSS(css memory _style) private pure {
        _style.addCSSElement(
            ".dot",
            string.concat(
                string("height").cssDecl("10px"),
                string("width").cssDecl("10px"),
                string("background-color").cssDecl("red"),
                string("border-radius").cssDecl("50%"),
                string("margin-top").cssDecl("10px"),
                string("margin-right").cssDecl("5px")
            )
        );
    }

    function _getFullHeaderBar(css memory _style) private pure {
        _getTitleCSS(_style);
        _getHeaderBarCSS(_style);
        _getTopRight(_style);
        _getDotCSS(_style);
    }

    function _getMainEls(css memory _style) private pure {

        _style.addCSSElement(
            "body",
            string.concat(
                string("font-family").cssDecl("'Helvetica', sans-serif")
            )
        );

        _style.addCSSElement(
            ".timeline",
            string.concat(
                string("width").cssDecl("1200px"),
                string("margin").cssDecl("auto")
            )
        );

        _style.addCSSElement(
            "td[class^='slot-']",
            string.concat(
                string("background-color").cssDecl("#f0f0f0"),
                string("border").cssDecl("1px solid #ccc"),
                string("width").cssDecl("120px"),
                string("height").cssDecl("40px")
            )
        );

        _style.addCSSElement(
            ".samples",
            string.concat(
                string("width").cssDecl("1200px"),
                string("display").cssDecl("flex")
            )
        );

        _style.addCSSElement(
            "td[class^='sample-']",
            string.concat(
                string("background-color").cssDecl("#f0f0f0"),
                string("border").cssDecl("1px solid #ccc"),
                string("width").cssDecl("120px"),
                string("height").cssDecl("40px")
            )
        );

        _style.addCSSElement(
            "div[class^='track-']",
            string.concat(
                string("grid-template-columns").cssDecl("repeat(10, 1fr)"),
                string("display").cssDecl("grid")
            )
        );

        _style.addCSSElement(
            ".selected",
            string.concat(
                string("background-color").cssDecl("yellow !important")
            )
        );

        _style.addCSSElement(
            ".occupied",
            string.concat(
                string("background-color").cssDecl("lightgreen !important")
            )
        );



    }


}

