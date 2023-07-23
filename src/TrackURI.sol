// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {LibString} from "lib/solady/src/Milady.sol";
import {Base64} from "lib/solady/src/utils/Base64.sol";
import "lib/ethers.sol/src/ethers.sol";
import "./TrackScripts.sol";

contract TrackURI {
    using HTML for string;

    address public immutable trackAddr;
    TrackScripts public immutable scripts;

    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    constructor(address _trackAddr) {
        trackAddr = _trackAddr;
        scripts = new TrackScripts(trackAddr);
        emit Transfer(address(0), msg.sender, 0);
        emit Transfer(address(0), msg.sender, 1);
    }

    // this is our main entry point to return the full html
    function tokenURI(uint256 id) public view returns (string memory) {
        html memory page; // initializing a new HTML page

        return
            json.formattedMetadataHTML("Onchain Music Doodle Boards", "Onchain Music Doodle Boards", _getPage(page, id));
    }

    function contractURI(uint256 id) external view returns (string memory) {
        html memory page; // initializing a new HTML page

        return _getPage(page, id);
    }

    function _writeHead(html memory _page) internal view {
        _page.meta(HTML.prop("charset", "UTF-8"));
        _page.meta(
            string.concat(HTML.prop("name", "viewport"), HTML.prop("content", "width=device-width, initial-scale=1.0"))
        );
        _page.title("On-chain Music Doodle Boards");
    }

    function _writeBody(html memory _page) internal view {
        trackBody.getBody(_page, trackAddr);
    }

    function _getPage(html memory _page, uint256 _id) internal view returns (string memory) {
        _writeHead(_page);
        _page.style(trackCSS.getCSS());

        _writeBody(_page);

        _page.script_(scripts.getScripts(_id));

        return (_page.read());
    }
}

library trackBody {
    using HTML for string;
    using nestDispatcher for Callback;
    using nestDispatcher for string;
    using LibString for uint256;

    function getBody(html memory _page, address _trackAddr) internal view {
        _getHeaderBar(_page);
        _page.appendBody(ethersConnection.iframeFallback());
        _getContainer(_page, _trackAddr);
        _page.script_(ethersConnection.connectionLogic("web3-container"));
    }

    function _getHeaderBar(html memory _page) internal view {
        _page.appendBody(
            string("id").prop("header-bar").callBackbuilder("", HTML.div, 2).addToNest(
                string("").callBackbuilder("On-chain Music Doodle Boards", HTML.h2, 0), ethersConnection.walletButtons()
            ).readNest()
        );
    }

    // creates a channel tr containing 10 slot tds
    function _createChannel(uint256 channel) internal pure returns (Callback memory o) {
        string memory childrenTd;

        unchecked {
            for (uint256 i; i < 10; ++i) {
                childrenTd = LibString.concat(
                    childrenTd, td(string("class").prop(LibString.concat(string("slot-"), LibString.toString(i))))
                );
            }
        }

        o.decoded =
            tr(string("class").prop(LibString.concat(string("channel-"), LibString.toString(channel))), childrenTd);
    }

    function _createSamples() internal pure returns (Callback memory o) {
        string memory childrenTd;

        unchecked {
            for (uint256 i; i < 10; ++i) {
                childrenTd = LibString.concat(
                    childrenTd, td(string("class").prop(LibString.concat(string("sample-"), LibString.toString(i))))
                );
            }
        }

        o.decoded = tr(string(""), childrenTd);
    }

    function tr(string memory _props, string memory _children) internal pure returns (string memory) {
        return HTML.el("tr", _props, _children);
    }

    function td(string memory _props) internal pure returns (string memory) {
        return HTML.el("td", _props, "");
    }

    function table(string memory _props, string memory _children) internal pure returns (string memory) {
        return HTML.el("table", _props, _children);
    }

    function audio(string memory _props, string memory _children) internal pure returns (string memory) {
        return HTML.el("audio", _props, _children);
    }

    function _getContainer(html memory _page, address _trackAddr) internal pure {
        _page.appendBody(
            string("id").prop("web3-container").callBackbuilder("", HTML.div, 4).addToNest(
                string("").callBackbuilder("", HTML.div, 2).addToNest(
                    string("").callBackbuilder(string.concat("Track ", LibString.toHexString(_trackAddr)), HTML.h2, 0),
                    string("class").prop("description").callBackbuilder("", HTML.div, 1).addToNest(
                        string("").callBackbuilder(
                            "Click on box to select it, then on a sample to apply it to that box", HTML.p, 0
                        )
                    )
                ),
                string("class").prop("timeline").callBackbuilder("", table, 4).addToNest(
                    _createChannel(0), _createChannel(1), _createChannel(2), _createChannel(3)
                ),
                string("class").prop("controls").callBackbuilder("", HTML.div, 2).addToNest(
                    string("id").prop("update-btn").callBackbuilder("Update", HTML.button, 0),
                    string.concat(string("id").prop("player"), " controls loop").callBackbuilder("", audio, 0)
                ),
                string("class").prop("sample-container").callBackbuilder("", HTML.div, 2).addToNest(
                    string("").callBackbuilder("Samples", HTML.h2, 0),
                    string("class").prop("samples").callBackbuilder("", table, 1).addToNest(_createSamples())
                )
            ).readNest()
        );
    }
}

library ethersConnection {
    using HTML for string;

    function iframeFallback() internal pure returns (string memory) {
        return
        '<div class="iframe-fallback"><span class="body">Please open original media to enable Web3 features</span></div>';
    }

    function walletButtons() internal pure returns (Callback memory walletBtns) {
        walletBtns.decoded =
            '<div class="top-right"><div class="dot"></div><button class="connect-button">Connect Wallet</button><button class="switch-button">Switch Networks</button></div>';
    }

    struct ChainInfo {
        string chainName;
        string chainId;
        string rpcUrl;
        string blockExplorer;
        string nativeCurrencyName;
        string nativeCurrencySymbol;
        string nativeCurrencyDecimals;
    }

    function _chainInfoToString(ChainInfo memory _chainInfo) private pure returns (string memory) {
        return string.concat(
            '{ chainId: "',
            _chainInfo.chainId,
            '", chainName: "',
            _chainInfo.chainName,
            '", rpcUrls: ["',
            _chainInfo.rpcUrl,
            '"], blockExplorerUrls: ["',
            _chainInfo.blockExplorer,
            '"], nativeCurrency: { name: "',
            _chainInfo.nativeCurrencyName,
            '", symbol: "',
            _chainInfo.nativeCurrencySymbol,
            '", decimals: ',
            _chainInfo.nativeCurrencyDecimals,
            " } }"
        );
    }

    function connectionLogic(string memory web3Container) internal view returns (string memory) {
        ChainInfo memory _chainInfo = ChainInfo(
            "Goerli",
            LibString.toMinimalHexString(block.chainid),
            "https://eth-goerli.public.blastapi.io",
            "https://goerli.etherscan.io/",
            "ETH",
            "ETH",
            "18"
        );

        return string.concat(
            'let isIframe; let provider; let accounts; let connectedAccount; function setDotColor(e) {document.querySelector(".dot").style.backgroundColor = e} document.addEventListener("DOMContentLoaded", function () {if (window == window.top) {provider = window.ethereum; isIframe = false; var e = document.getElementById("',
            web3Container,
            '", document.querySelector(".iframe-fallback").style.display = "none"),t = document.querySelector(".connect-button"), n = document.querySelector(".switch-button"); e.style.display = "block",',
            'void 0 !== provider ? (window.ethereum.request({method: "eth_requestAccounts"}), ethereum.request({method: "eth_accounts"}).then(function (accounts) {accounts.length === 0 ? (setDotColor("red"), t.style.display = "block", n.style.display = "none") : ethereum.request({method: "eth_chainId"}).then(function (e) {if("',
            _chainInfo.chainId,
            '" === e) { (ethereum.enable().then(function (accounts) { setDotColor("green"); console.log(accounts); connectedAccount = accounts[0]; n.style.display = "none"; t.innerText = "Connected"; }).catch(console.error))} else {(setDotColor("red"), t.style.display = "none", n.style.display = "block")} }).catch(console.error)}).catch(console.error), t.addEventListener("click", function () {ethereum.request({method: "eth_requestAccounts"}).then(function (accounts) {if(accounts.length > 0) {setDotColor("green"); t.innerText = "Connected"; n.style.display = "none"; connectedAccount = accounts[0]; } else { ethereum.enable().then(function (accounts) { setDotColor("green"); console.log(accounts); connectedAccount = accounts[0]; n.style.display = "none"; t.innerText = "Connected";}).catch(console.error); } }).catch(console.error)}), n.addEventListener("click", function () {window.ethereum.request({ method: "wallet_addEthereumChain", params: [',
            _chainInfoToString(_chainInfo),
            ']}).then(function () {n.style.display = "none"; setDotColor("green")}).catch(console.error)})) : (setDotColor("red"), t.style.display = "block", n.style.display = "none")} else {document.querySelector(".iframe-fallback").style.display = "block"; document.getElementById("',
            web3Container,
            '").style.display = "none", isIframe = true;}});'
        );
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
                string("color").cssDecl("#000"),
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
                string("top").cssDecl("0"),
                string("width").cssDecl("100%")
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
                string("font-family").cssDecl("monospace"), string("background-color").cssDecl("rgb(155, 227, 255)")
            )
        );

        _style.addCSSElement(
            ".timeline",
            string.concat(
                string("width").cssDecl("1200px"),
                string("margin").cssDecl("auto"),
                string("background-color").cssDecl("darkgray"),
                string("box-shadow").cssDecl("2px 2px 21px -5px #000000")
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
            "td[class^='slot-']:hover",
            string.concat(string("background-color").cssDecl("#e0e0e0"), string("cursor").cssDecl("pointer"))
        );

        _style.addCSSElement(".editing", string("background-color").cssDecl("yellow !important"));

        _style.addCSSElement(".samples.editing td", string("cursor").cssDecl("pointer"));

        _style.addCSSElement(
            ".samples", string.concat(string("width").cssDecl("1200px"), string("display").cssDecl("flex"))
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
            string.concat(string("grid-template-columns").cssDecl("repeat(10, 1fr)"), string("display").cssDecl("grid"))
        );

        _style.addCSSElement(".selected", string.concat(string("background-color").cssDecl("yellow !important")));

        _style.addCSSElement(".occupied", string.concat(string("background-color").cssDecl("lightgreen !important")));

        _style.addCSSElement(
            "@keyframes blink",
            string.concat(
                string.concat("0% {", string("background").cssDecl("rgba(182, 199, 183, 0.5)"), "}"),
                string.concat("50% {", string("background").cssDecl("rgba(91, 206, 100, 0.5)"), "}"),
                string.concat("100% {", string("background").cssDecl("rgba(182, 199, 183, 0.5)"), "}")
            )
        );

        _style.addCSSElement(".timeline td", string("position").cssDecl("relative"));

        _style.addCSSElement(
            ".timeline td.blink::before",
            'content: ""; display: block; position: absolute; top: 0; bottom: 0; right: 0; left: 0; z-index: 1; animation: blink 0.5s linear infinite;'
        );

        _style.addCSSElement(
            ".controls",
            string.concat(
                string("display").cssDecl("flex"),
                string("padding").cssDecl("2em"),
                string("gap").cssDecl("104px"),
                string("justify-content").cssDecl("center"),
                string("align-items").cssDecl("center")
            )
        );

        _style.addCSSElement(
            "button",
            string.concat(
                string("background-color").cssDecl("aliceblue"),
                string("border").cssDecl("1px solid darkgrey"),
                string("margin").cssDecl("16px"),
                string("width").cssDecl("100px"),
                string("height").cssDecl("34px"),
                string("cursor").cssDecl("pointer"),
                string("font-family").cssDecl("inherit")
            )
        );

        _style.addCSSElement("table", string("text-align").cssDecl("center"));
    }
}
