// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.0;

interface IVRNGSystemCallback {
    event RandomNumberRequested(uint256 indexed requestId);
    event RandomNumberFulfilled(uint256 indexed requestId, uint256 normalizedRandomNumber);

    /**
     * Callback for when a Random Number is delivered
     *
     * @param requestId     Id of the request
     * @param randomNumber   Random number that was generated by the Verified Random Number Generator Tool
     */
    function randomNumberCallback(uint256 requestId, uint256 randomNumber) external;
}
