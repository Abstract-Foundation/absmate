// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @dev VRF statuses
/// @dev NONE: No VRF request has been made
/// @dev REQUESTED: VRF request has been made, and is pending fulfillment
/// @dev FULFILLED: The VRF request has been fulfilled with a random number
enum VRFStatus {
    NONE,
    REQUESTED,
    FULFILLED
}

/// @dev VRF request details
/// @param status The status of the VRF request, see `VRFStatus`
/// @param randomNumber The random number returned by the VRF system
struct VRFRequest {
    VRFStatus status;
    uint256 randomNumber;
}

/// @dev VRF normalization methods
/// @dev MOST_EFFICIENT: The most efficient normalization method - uses requestId + randomNumber
/// @dev BALANCED: Normalization method balanced for gas efficiency and normalization - hash of
/// encoded requestId and randomNumber
/// @dev MOST_NORMALIZED: The most normalized normalization method - uses hash of encoded pseudo
/// random block hash and random number
enum VRFNormalizationMethod {
    MOST_EFFICIENT,
    BALANCED,
    MOST_NORMALIZED
}
