// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IVRNGSystem} from "../../src/interfaces/vrng/IVRNGSystem.sol";
import {IVRNGSystemCallback} from "../../src/interfaces/vrng/IVRNGSystemCallback.sol";

struct VRNGRequest {
    uint256 traceId;
    uint256 randomNumber;
    IVRNGSystemCallback callback;
    bool isFulfilled;
}

contract MockVRNGSystem is IVRNGSystem {
    uint256 public nextRequestId = 1;

    function setNextRequestId(uint256 requestId) external {
        nextRequestId = requestId;
    }

    function requestRandomNumberWithTraceId(uint256) external returns (uint256) {
        uint256 requestId = nextRequestId++;
        return requestId;
    }
}
