// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {LibString} from "lib/solady/src/Milady.sol";
import {Base64} from "lib/solady/src/utils/Base64.sol";
import "lib/ethers.sol/src/ethers.sol";

contract TrackScripts {
    address public immutable trackAddr;

    constructor(address _trackAddr) {
        trackAddr = _trackAddr;
    }

    struct STATE {
        string content;
    }

    function getScripts(uint256 _id) public view returns (string memory) {
        STATE memory s;

        s.content = string.concat("const trackID = ", LibString.toString(_id), ";");
        _createWavFile(s);
        _hexStringToUint8Array(s);
        _hextToString(s);
        _transactions(s, _id);
        _insertElementNames(s);
        _onload(s);
        _handlers(s);

        return s.content;
    }

    function _transactions(STATE memory _s, uint256 _id) internal view {
        _writePayloads(_s);
        _fetchPayloads(_s);
        _writeNamePayloads(_s);
        _fetchNamePayloads(_s);
        _writeTrackPayloads(_s, _id);
        _fetchTrackPayloads(_s);
        //_writeUpdatePayload(_s);
    }

    function _createWavFile(STATE memory _s) internal pure {
        fn memory _fn;

        string memory samples = "samples";
        string memory sampleRate = "sameRate";

        _fn.initializeNamedArgsFn("createWavFile", string.concat(samples, ",", sampleRate));
        _fn.openBodyFn();
        _fn.appendFn(string.concat("const byteRate = ", sampleRate, " * 1;"));
        _fn.appendFn(string.concat("const dataSize = ", samples, ".length;"));
        _fn.appendFn("const buffer = new ArrayBuffer(44 + dataSize);const view = new DataView(buffer);");
        _fn.appendFn(
            string.concat(
                "view.setUint32(0, 0x52494646, false); view.setUint32(4, 36 + dataSize, true); view.setUint32(8, 0x57415645, false); view.setUint32(12, 0x666d7420, false); view.setUint32(16, 16, true); view.setUint16(20, 1, true); view.setUint16(22, 1, true); view.setUint32(24, ",
                sampleRate,
                ", true); view.setUint32(28, byteRate, true); view.setUint16(32, 1, true); view.setUint16(34, 8, true); view.setUint32(36, 0x64617461, false); view.setUint32(40, dataSize, true);"
            )
        );

        _fn.appendFn(
            string.concat(
                "for (let i = 0, stride = 44; i < dataSize; i++, stride++) {", "view.setUint8(stride, samples[i]);", "}"
            )
        );

        _fn.appendFn("return buffer;");
        _fn.closeBodyFn();

        _s.content = LibString.concat(_s.content, _fn.readFn());
    }

    function _hexStringToUint8Array(STATE memory _s) internal pure {
        fn memory _fn;

        _fn.initializeNamedArgsFn("hexStringToUint8Array", "hexString");
        _fn.openBodyFn();
        _fn.appendFn("hexString = hexString.substr(2);");
        _fn.appendFn("const numPairs = hexString.length / 2;");
        _fn.appendFn("const uintArray = new Uint8Array(numPairs);");
        _fn.appendFn(
            _forLoop(
                "i", "numPairs", "const hexPair = hexString.substr(i * 2, 2); uintArray[i] = parseInt(hexPair, 16);"
            )
        );
        _fn.appendFn("return uintArray;");
        _fn.closeBodyFn();

        _s.content = LibString.concat(_s.content, _fn.readFn());
    }

    function _callSamples(STATE memory _s) internal pure {
        _s.content = LibString.concat(
            _s.content,
            "const samples = hexStringToUint8Array(samplesStr); const sampleRate = 8000; console.log(samples); const wavFile = createWavFile(samples, sampleRate); const blob = new Blob([wavFile], { type: 'audio/wav' }); const url = URL.createObjectURL(blob); const player = document.getElementById('player'); player.src = url; player.play();"
        );
    }

    function _hextToString(STATE memory _s) internal pure {
        /*function hexToString(hex) {
            var arr = hex.match(/.{1,2}/g); // Split hex string into array of 2-char groups
            var str = '';
            for(var i = 0; i < arr.length; i++) {
                str += String.fromCharCode(parseInt(arr[i], 16)); // Convert each group into a character
            }
            return str;
        }*/

        fn memory _fn;

        _fn.initializeNamedArgsFn("hexToString", "hexStr");
        _fn.openBodyFn();
        _fn.appendFn("hexStr = hexStr.substr(2);");
        //_fn.appendFn('hexStr = hexStr.replace(/^00+/, ''); ');
        _fn.appendFn("var arr = hexStr.match(/.{1,2}/g);");
        _fn.appendFn('var str = "";');
        _fn.appendFn("let first = 0;");
        _fn.appendFn(
            _forLoop(
                "i",
                "arr.length",
                "let parsedInt = parseInt(arr[i], 16); if(parsedInt !== 0) { if(first <2) { first++; } else {str += String.fromCharCode(parsedInt);}}"
            )
        );
        _fn.appendFn("return str;");
        _fn.closeBodyFn();

        _s.content = LibString.concat(_s.content, _fn.readFn());
    }

    function _writeSampleTransaction(uint8 index) internal view returns (string memory) {
        return
            _getFormedTansaction(trackAddr, LibString.toHexString(abi.encodeWithSignature("playElement(uint8)", index)));
    }

    function _writeNameTransaction(uint8 index) internal view returns (string memory) {
        return
            _getFormedTansaction(trackAddr, LibString.toHexString(abi.encodeWithSignature("elementName(uint8)", index)));
    }

    function _writeTrackTransaction(uint8 index) internal view returns (string memory) {
        return
            _getFormedTansaction(trackAddr, LibString.toHexString(abi.encodeWithSignature("readTrack(uint256)", index)));
    }

    // this we just get the func sig and then need to assemble the rest
    function _writeUpdateTransaction() internal view returns (string memory) {
        return _getFormedTansaction(trackAddr, "0x89370e2d");
    }

    function _writePayloads(STATE memory _s) internal view returns (string memory payloads) {
        payloads = "const payloads = [";

        unchecked {
            for (uint256 i = 0; i < 10; ++i) {
                payloads = string.concat(payloads, i == 0 ? "" : ", ", _writeSampleTransaction(uint8(i + 1)));
            }
        }

        _s.content = string.concat(_s.content, payloads, "];");
    }

    function _writeNamePayloads(STATE memory _s) internal view returns (string memory payloads) {
        payloads = "const name_payloads = [";

        unchecked {
            for (uint256 i = 0; i < 10; ++i) {
                payloads = string.concat(payloads, i == 0 ? "" : ", ", _writeNameTransaction(uint8(i + 1)));
            }
        }

        _s.content = string.concat(_s.content, payloads, "];");
    }

    function _writeTrackPayloads(STATE memory _s, uint256 _id) internal view returns (string memory payloads) {
        _s.content = string.concat(_s.content, "const track_payloads = ", _writeTrackTransaction(uint8(_id)), ";");
    }

    function _writeUpdatePayload(STATE memory _s) internal view returns (string memory payloads) {
        _s.content = string.concat(_s.content, "const partialupdate = ", _writeUpdateTransaction(), ";");
    }

    function _fetchPayloads(STATE memory _s) internal view {
        fn memory _fn;

        _fn.initializeNamedFn("fetchPayloads");
        _fn.asyncFn();
        _fn.prependFn("let rawAudio = []; ");

        _fn.openBodyFn();
        _fn.appendFn(
            _forLoop(
                "i",
                "payloads.length",
                string.concat(
                    "rawAudio.push(createWavFile(hexStringToUint8Array(await ",
                    libBrowserProvider.ethereum_request(
                        libJsonRPCProvider.eth_call("payloads[i]", libJsonRPCProvider.blockTag.latest)
                    ),
                    ",8000)))"
                )
            )
        );

        _fn.appendFn("console.log(rawAudio); ");
        _fn.closeBodyFn();

        _s.content = LibString.concat(_s.content, _fn.readFn());
    }

    function _fetchNamePayloads(STATE memory _s) internal view {
        fn memory _fn;

        _fn.initializeNamedFn("fetchNamePayloads");
        _fn.asyncFn();
        _fn.prependFn("let elementNames = []; ");

        _fn.openBodyFn();
        _fn.appendFn(
            _forLoop(
                "i",
                "name_payloads.length",
                string.concat(
                    "elementNames.push(hexToString(await ",
                    libBrowserProvider.ethereum_request(
                        libJsonRPCProvider.eth_call("name_payloads[i]", libJsonRPCProvider.blockTag.latest)
                    ),
                    "));"
                )
            )
        );

        _fn.appendFn("console.log(elementNames); ");
        _fn.closeBodyFn();

        _s.content = LibString.concat(_s.content, _fn.readFn());
    }

    function _fetchTrackPayloads(STATE memory _s) internal view {
        fn memory _fn;

        _fn.initializeNamedFn("fetchTrackPayloads");
        _fn.asyncFn();
        _fn.prependFn("let tracks_filled; ");

        _fn.openBodyFn();
        _fn.appendFn(
            string.concat(
                "tracks_filled = await ",
                libBrowserProvider.ethereum_request(
                    libJsonRPCProvider.eth_call("track_payloads", libJsonRPCProvider.blockTag.latest)
                ),
                ";"
            )
        );

        _fn.appendFn(
            'const trackMatrix = []; const track = tracks_filled.substr(2 + 128); console.log(track); for (let i = 0; i < track.length; i += 64) { trackMatrix.push(parseInt(track.slice(i, i + 64))); } let matrix = []; for (let i = 0; i < trackMatrix.length; i += 4) { const val = trackMatrix.slice(i, i + 4); matrix.push(val); } console.log(matrix); for (var i = 0; i < matrix.length; i++) { for (var j = 0; j < matrix[i].length; j++) { var slot = matrix[i][j]; var chan = document.querySelector(".channel-" + j); var slotEl = chan.querySelector(".slot-" + i); if (slot != 0) { console.log(chan, slotEl); } if (slot !== 0) { slotEl.textContent = elementNames[slot - 1]; slotEl.dataset.index = slot - 1; } } }'
        );
        _fn.closeBodyFn();

        _s.content = LibString.concat(_s.content, _fn.readFn());
    }

    function _insertElementNames(STATE memory _s) internal view {
        fn memory _fn;

        _fn.initializeNamedFn("insertElementNames");
        _fn.openBodyFn();
        _fn.appendFn(
            _forLoop(
                "i",
                "elementNames.length",
                string.concat(
                    "let td = document.querySelector('.sample-' + i);",
                    "let textNode = document.createTextNode(elementNames[i]);",
                    "td.appendChild(textNode);"
                )
            )
        );
        _fn.closeBodyFn();

        _s.content = LibString.concat(_s.content, _fn.readFn());
    }

    function _updateBtnClick() internal view returns (string memory) {
        fn memory _fn;

        _fn.initializeFn();
        _fn.asyncFn();
        _fn.prependFn("updateButton.addEventListener('click', ");
        _fn.openBodyFn();
        _fn.appendFn(
            string.concat(
                'if (connectedAccount == undefined) {alert("Please connect your wallet first"); } else {',
                "await fetchPayloads();}"
            )
        );
        _fn.appendFn("});");

        return _fn.readFn();
    }

    function _onload(STATE memory _s) internal view {
        arrowFn memory _fn;

        _fn.initializeArgsArrowFn("event");
        _fn.asyncArrowFn();
        _fn.prependArrowFn("document.addEventListener('DOMContentLoaded', ");
        _fn.openBodyArrowFn();
        _fn.appendArrowFn("let elementId = undefined; let slotId = undefined; let channelId = undefined;");
        _fn.appendArrowFn("await fetchPayloads(); await fetchNamePayloads(); await fetchTrackPayloads();");
        _fn.appendArrowFn("insertElementNames(); editHandler(); updateHandler(); playHandler();");

        _fn.appendArrowFn("});");

        _s.content = LibString.concat(_s.content, _fn.readArrowFn());
    }

    function _handlers(STATE memory _s) internal view {
        string memory handlers = string.concat(
            'function editHandler() { let selectedTimeline; let selectedSample; let boardLocked = false; document.querySelectorAll(".timeline td").forEach(function (td) { td.addEventListener("click", function () { console.log(boardLocked); if (boardLocked) return; if (selectedTimeline === this) { this.classList.remove("editing"); document.querySelector(".samples").classList.remove("editing"); selectedTimeline = undefined; return; } if (selectedTimeline) { selectedTimeline.classList.remove("editing"); } this.classList.add("editing"); selectedTimeline = this; document.querySelector(".samples").classList.add("editing"); slotId = parseInt(this.className.split("-")[1]); channelId = parseInt(this.parentNode.className.split("-")[1]); }); }); document.querySelectorAll(".samples td").forEach(function (td) { td.addEventListener("click", function () { if (selectedTimeline) { elementId = parseInt(this.className.split("-")[1]) + 1; selectedTimeline.textContent = this.textContent; document.querySelector(".samples").classList.remove("editing"); boardLocked = true; } }); }); } function updateHandler() { function updateBuffer(int1, int2, int3, int4) { const buffer = new ArrayBuffer(128); const view = new DataView(buffer); view.setInt32(28, int1); view.setInt32(60, int2); view.setInt32(92, int3); view.setInt32(124, int4); const uint8Array = new Uint8Array(buffer); let hexString = Array.from(uint8Array) .map((b) => ("00" + b.toString(16)).slice(-2)) .join(""); return hexString; } const updateButton = document.getElementById("update-btn"); updateButton.addEventListener("click", async function () { const partialupdate = { from: connectedAccount, to: "',
            LibString.toHexString(trackAddr),
            '", data: "0x89370e2d", }; partialupdate.data += updateBuffer(0, slotId, channelId, elementId); console.log(partialupdate); const txHash = await ethereum.request({ method: "eth_sendTransaction", params: [partialupdate], }); const receipt = await new Promise((resolve) => { const interval = setInterval(async () => { const receipt = await ethereum.request({ method: "eth_getTransactionReceipt", params: [txHash], }); if (receipt) { clearInterval(interval); resolve(receipt); } }, 5000); }); if (receipt) location.reload(); }); }'
        );
        handlers = string.concat(
            handlers,
            'function playHandler() { console.log(rawAudio); let audioMatrix = []; document.querySelectorAll(".timeline tr").forEach(function (tr) { let channelAudio = []; tr.querySelectorAll("td").forEach(function (td) { const index = td.dataset.index; const audio = index ? rawAudio[index].slice(108) : new ArrayBuffer(48000); channelAudio.push(audio); }); let totalLength = channelAudio.reduce( (acc, buffer) => acc + buffer.byteLength, 0 ); let result = new Uint8Array(totalLength); let offset = 0; for (let buffer of channelAudio) { result.set(new Uint8Array(buffer), offset); offset += buffer.byteLength; } audioMatrix.push(result); channelAudio = []; }); console.log(audioMatrix); let length = audioMatrix[0].length; let result = new Uint8Array(length); for (let i = 0; i < length; i++) { let sum = audioMatrix.reduce((acc, arr) => acc + arr[i], 0); result[i] = sum / 4; } let completedAudio = createWavFile(result, 8000); console.log("x", completedAudio); const blob = new Blob([completedAudio], { type: "audio/wav" }); const url = URL.createObjectURL(blob); const player = document.getElementById("player"); player.src = url; player.play(); var lastLoggedSecond = -1; let currentColumn = 0; let previousColumn; function highlightCoumns() { let newColumn = Math.floor(player.currentTime / 6); if (previousColumn !== undefined) { document .querySelectorAll(`.timeline .slot-${previousColumn}`) .forEach((td) => { td.classList.remove("blink"); }); } document .querySelectorAll(`.timeline .slot-${newColumn}`) .forEach((td) => { td.classList.add("blink"); }); previousColumn = currentColumn; currentColumn = newColumn; } highlightCoumns(); setInterval(highlightCoumns, 1000); }'
        );

        _s.content = LibString.concat(_s.content, handlers);
    }

    function _forLoop(string memory _varName, string memory _length, string memory _body)
        private
        pure
        returns (string memory)
    {
        return string.concat(
            "for (let ", _varName, " = 0; ", _varName, " < ", _length, "; ", _varName, "++) {", _body, "}"
        );
    }

    function _forLoop(string memory _varName, string memory _length, string memory _increments, string memory _body)
        private
        pure
        returns (string memory)
    {
        return string.concat(
            "for (let ",
            _varName,
            " = 0; ",
            _varName,
            " <",
            _length,
            "; ",
            _varName,
            "+=",
            _increments,
            ") {",
            _body,
            "}"
        );
    }

    function _getFormedTansaction(address _to, string memory _data) internal view returns (string memory) {
        return string.concat("{", 'to: "', LibString.toHexString(_to), '",' 'data: "', _data, '"}');
    }

    function _getFormedTansaction(string memory _from, address _to, string memory _data)
        internal
        view
        returns (string memory)
    {
        return string.concat("{", "from: ", _from, "," 'to: "', LibString.toHexString(_to), '",' 'data: "', _data, '"}');
    }

    function _getFormedTansaction(string memory _from, address _to, uint256 _value, string memory _data)
        internal
        view
        returns (string memory)
    {
        return string.concat(
            "{",
            "from: ",
            _from,
            "," 'to: "',
            LibString.toHexString(_to),
            '",' 'value: "',
            LibString.toMinimalHexString(_value),
            '",' 'data: "',
            _data,
            '"}'
        );
    }

    function _getFormedTansaction(address _from, address _to, uint256 _value, string memory _data)
        internal
        view
        returns (string memory)
    {
        return string.concat(
            "{",
            'from: "',
            LibString.toHexString(_from),
            '",' 'to: "',
            LibString.toHexString(_to),
            '",' 'value: "',
            LibString.toMinimalHexString(_value),
            '",' 'data: "',
            _data,
            '"}'
        );
    }
}
