// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.0;

interface IVRFSystem {
    /**
     * Starts a VRF random number request
     *
     * @param traceId Optional Id to use when tracing the request
     * @return requestId for the random number, will be passed to the callback contract
     */
    function requestRandomNumberWithTraceId(uint256 traceId) external returns (uint256);
}
