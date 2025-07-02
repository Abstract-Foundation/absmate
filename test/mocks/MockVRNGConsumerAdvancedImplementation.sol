// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {VRNGConsumerAdvanced} from "../../src/utils/vrng/VRNGConsumerAdvanced.sol";
import {VRNGNormalizationMethod, VRNGRequest} from "../../src/utils/vrng/DataTypes.sol";

contract MockVRNGConsumerAdvancedImplementation is VRNGConsumerAdvanced {
    mapping(uint256 requestId => uint256 randomNumber) public _requestToRandomNumber;
    mapping(uint256 requestId => bool isFulfilled) public _requestToFulfilled;

    constructor(VRNGNormalizationMethod normalizationMethod) VRNGConsumerAdvanced(normalizationMethod) {}

    function setVRNG(address vrngSystem) public {
        _setVRNG(vrngSystem);
    }

    function triggerRandomNumberRequest() public {
        _requestRandomNumber();
    }

    function getVRNGRequest(uint256 requestId) public view returns (VRNGRequest memory) {
        return _getVRNGRequest(requestId);
    }

    function _onRandomNumberFulfilled(uint256 requestId, uint256 randomNumber) internal override {
        _requestToRandomNumber[requestId] = randomNumber;
        _requestToFulfilled[requestId] = true;
    }
}
