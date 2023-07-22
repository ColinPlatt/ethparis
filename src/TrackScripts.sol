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
        _callSamples(s);
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

    function _writeSampleTransaction(uint8 index) internal view returns (string memory) {

        return _getFormedTansaction(
            'connectedAccount',
            trackAddr,
            LibString.toHexString(abi.encodeWithSignature(
                "playElement(uint8)",
                index
            ))
        );


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
                    'const res = ',
                    libBrowserProvider.ethereum_request(libJsonRPCProvider.eth_call(_writeSampleTransaction(uint8(1)), libJsonRPCProvider.blockTag.latest)),
                    '; console.log("result", res);}'
                )
            );
        _fn.appendFn("});");

       return _fn.readFn();
    }

    function _onload(STATE memory _s) internal view {
        arrowFn memory _fn;

        _fn.initializeArgsArrowFn("event");
        _fn.prependArrowFn("document.addEventListener('DOMContentLoaded', ");
        _fn.openBodyArrowFn();
        _fn.appendArrowFn("const updateButton = document.getElementById('update-btn'); console.log(updateButton);");
        _fn.appendArrowFn(_updateBtnClick());

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
