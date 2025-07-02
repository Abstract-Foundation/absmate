// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {VRFConsumerAdvanced} from "../../src/utils/vrf/VRFConsumerAdvanced.sol";
import {VRFNormalizationMethod, VRFRequest} from "../../src/utils/vrf/DataTypes.sol";

contract MockVRFConsumerAdvancedImplementation is VRFConsumerAdvanced {
    mapping(uint256 requestId => uint256 randomNumber) public _requestToRandomNumber;
    mapping(uint256 requestId => bool isFulfilled) public _requestToFulfilled;

    constructor(VRFNormalizationMethod normalizationMethod) VRFConsumerAdvanced(normalizationMethod) {}

    function setVrf(address vrfSystem) public {
        _setVrf(vrfSystem);
    }

    function triggerRandomNumberRequest() public {
        _requestRandomNumber();
    }

    function getVrfRequest(uint256 requestId) public view returns (VRFRequest memory) {
        return _getVrfRequest(requestId);
    }

    function _onRandomNumberFulfilled(uint256 requestId, uint256 randomNumber) internal override {
        _requestToRandomNumber[requestId] = randomNumber;
        _requestToFulfilled[requestId] = true;
    }
}
