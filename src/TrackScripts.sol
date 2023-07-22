// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {LibString} from "lib/solady/src/Milady.sol";
import {Base64} from "lib/solady/src/utils/Base64.sol";
import "lib/ethers.sol/src/ethers.sol";

contract TrackScripts {

    address public immutable trackAddr;

    constructor(
        address _trackAddr
    ) {
        trackAddr = _trackAddr;
    }

    struct STATE {
        string content;
    }

    function getScripts() public view returns (string memory) {
        STATE memory s;

        _createWavFile(s);
        _hexStringToUint8Array(s);
        _hextToString(s);
        _writePayloads(s);
        _fetchPayloads(s);
        _writeNamePayloads(s);
        _fetchNamePayloads(s);
        _insertElementNames(s);
        _onload(s);

        return s.content;


    }

    function _createWavFile(STATE memory _s) internal pure {

        fn memory _fn;

        string memory samples = "samples";
        string memory sampleRate = "sameRate";

        _fn.initializeNamedArgsFn("createWavFile", string.concat(samples,",",sampleRate));
        _fn.openBodyFn();
            _fn.appendFn(string.concat('const byteRate = ',sampleRate,' * 1;'));
            _fn.appendFn(string.concat('const dataSize = ',samples,'.length;'));
            _fn.appendFn('const buffer = new ArrayBuffer(44 + dataSize);const view = new DataView(buffer);');
            _fn.appendFn(string.concat(
                'view.setUint32(0, 0x52494646, false); view.setUint32(4, 36 + dataSize, true); view.setUint32(8, 0x57415645, false); view.setUint32(12, 0x666d7420, false); view.setUint32(16, 16, true); view.setUint16(20, 1, true); view.setUint16(22, 1, true); view.setUint32(24, ',
                sampleRate,
                ', true); view.setUint32(28, byteRate, true); view.setUint16(32, 1, true); view.setUint16(34, 8, true); view.setUint32(36, 0x64617461, false); view.setUint32(40, dataSize, true);'
            ));

            _fn.appendFn(
                string.concat(
                    'for (let i = 0, stride = 44; i < dataSize; i++, stride++) {',
                        'view.setUint8(stride, samples[i]);',
                    '}'
                )
            );

            _fn.appendFn('return buffer;');
        _fn.closeBodyFn();
        
        _s.content = LibString.concat(_s.content, _fn.readFn());

    }

    function _hexStringToUint8Array(STATE memory _s) internal pure {
        fn memory _fn;

        _fn.initializeNamedArgsFn("hexStringToUint8Array", 'hexString');
        _fn.openBodyFn();
        _fn.appendFn('hexString = hexString.substr(2);');
        _fn.appendFn('const numPairs = hexString.length / 2;');
        _fn.appendFn('const uintArray = new Uint8Array(numPairs);');
        _fn.appendFn(
            _forLoop(
                'i', 
                'numPairs', 
                'const hexPair = hexString.substr(i * 2, 2); uintArray[i] = parseInt(hexPair, 16);'
            )
        );
        _fn.appendFn('return uintArray;');
        _fn.closeBodyFn();

        _s.content = LibString.concat(_s.content, _fn.readFn());
    }

    function _callSamples(STATE memory _s) internal pure {

        _s.content = LibString.concat(_s.content, "const samples = hexStringToUint8Array(samplesStr); const sampleRate = 8000; console.log(samples); const wavFile = createWavFile(samples, sampleRate); const blob = new Blob([wavFile], { type: 'audio/wav' }); const url = URL.createObjectURL(blob); const player = document.getElementById('player'); player.src = url; player.play();");

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

        _fn.initializeNamedArgsFn("hexToString", 'hexStr');
        _fn.openBodyFn();
        _fn.appendFn('hexStr = hexStr.substr(2);');
        //_fn.appendFn('hexStr = hexStr.replace(/^00+/, ''); ');
        _fn.appendFn('var arr = hexStr.match(/.{1,2}/g);');
        _fn.appendFn('var str = "";');
        _fn.appendFn('let first = 0;');
        _fn.appendFn(
            _forLoop(
                'i', 
                'arr.length', 
                'let parsedInt = parseInt(arr[i], 16); if(parsedInt !== 0) { if(first <2) { first++; } else {str += String.fromCharCode(parsedInt);}}'
            )
        );
        _fn.appendFn('return str;');
        _fn.closeBodyFn();

        _s.content = LibString.concat(_s.content, _fn.readFn());


    }

    function _writeSampleTransaction(uint8 index) internal view returns (string memory) {
        return _getFormedTansaction(
            trackAddr,
            LibString.toHexString(abi.encodeWithSignature(
                "playElement(uint8)",
                index
            ))
        );
    }

    function _writeNameTransaction(uint8 index) internal view returns (string memory) {
        return _getFormedTansaction(
            trackAddr,
            LibString.toHexString(abi.encodeWithSignature(
                "elementName(uint8)",
                index
            ))
        );
    }
    

    function _writePayloads(STATE memory _s) internal view returns (string memory payloads) {

        payloads = "const payloads = [";

        unchecked {
            for(uint i = 0; i<10; ++i) {
                payloads = string.concat(payloads, i==0?"" :", ", _writeSampleTransaction(uint8(i+1)));
            }
        }

        _s.content = string.concat(_s.content, payloads, "];");
    }

    function _writeNamePayloads(STATE memory _s) internal view returns (string memory payloads) {

        payloads = "const name_payloads = [";

        unchecked {
            for(uint i = 0; i<10; ++i) {
                payloads = string.concat(payloads, i==0?"" :", ", _writeNameTransaction(uint8(i+1)));
            }
        }

        _s.content = string.concat(_s.content, payloads, "];");
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
                        libBrowserProvider.ethereum_request(libJsonRPCProvider.eth_call("payloads[i]", libJsonRPCProvider.blockTag.latest)),
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
                        libBrowserProvider.ethereum_request(libJsonRPCProvider.eth_call("name_payloads[i]", libJsonRPCProvider.blockTag.latest)),
                        "));"
                    )
                )
            );

            _fn.appendFn("console.log(elementNames); ");
        _fn.closeBodyFn();

        _s.content = LibString.concat(_s.content, _fn.readFn());
    }

    function _insertElementNames(STATE memory _s)  internal view {
        fn memory _fn;

        _fn.initializeNamedFn("insertElementNames");
        _fn.openBodyFn();
        _fn.appendFn(
            _forLoop(
                "i",
                'elementNames.length', 
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
                    'await fetchPayloads();}'
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
        _fn.appendArrowFn("const updateButton = document.getElementById('update-btn'); console.log(updateButton);");
        _fn.appendArrowFn('await fetchPayloads(); await fetchNamePayloads();');
        _fn.appendArrowFn('insertElementNames();');

        _fn.appendArrowFn("});");

        _s.content = LibString.concat(_s.content, _fn.readArrowFn());
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

        return string.concat(
            '{',
                'to: "', LibString.toHexString(_to), '",'
                'data: "', _data,
            '"}'
        );
    }

    function _getFormedTansaction(string memory _from, address _to, string memory _data) internal view returns (string memory) {

        return string.concat(
            '{',
                'from: ', _from, ','
                'to: "', LibString.toHexString(_to), '",'
                'data: "', _data,
            '"}'
        );
    }

    function _getFormedTansaction(string memory _from, address _to, uint _value, string memory _data) internal view returns (string memory) {

        return string.concat(
            '{',
                'from: ', _from, ','
                'to: "', LibString.toHexString(_to), '",'
                'value: "', LibString.toMinimalHexString(_value), '",'
                'data: "', _data,
            '"}'
        );
    }

    function _getFormedTansaction(address _from, address _to, uint _value, string memory _data) internal view returns (string memory) {

        return string.concat(
            '{',
                'from: "', LibString.toHexString(_from), '",'
                'to: "', LibString.toHexString(_to), '",'
                'value: "', LibString.toMinimalHexString(_value), '",'
                'data: "', _data,
            '"}'
        );
    }


}
