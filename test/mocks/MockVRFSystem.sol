// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IVRFSystem} from "../../src/interfaces/vrf/IVRFSystem.sol";
import {IVRFSystemCallback} from "../../src/interfaces/vrf/IVRFSystemCallback.sol";

struct VRFRequest {
    uint256 traceId;
    uint256 randomNumber;
    IVRFSystemCallback callback;
    bool isFulfilled;
}

contract MockVRFSystem is IVRFSystem {
    uint256 public nextRequestId = 1;

    function setNextRequestId(uint256 requestId) external {
        nextRequestId = requestId;
    }

    function requestRandomNumberWithTraceId(uint256) external returns (uint256) {
        uint256 requestId = nextRequestId++;
        return requestId;
    }
}
