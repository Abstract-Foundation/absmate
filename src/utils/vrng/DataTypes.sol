// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @dev VRNG statuses
/// @dev NONE: No VRNG request has been made
/// @dev REQUESTED: VRNG request has been made, and is pending fulfillment
/// @dev FULFILLED: The VRNG request has been fulfilled with a random number
enum VRNGStatus {
    NONE,
    REQUESTED,
    FULFILLED
}

/// @dev VRNG request details
/// @param status The status of the VRNG request, see `VRNGStatus`
/// @param randomNumber The random number returned by the VRNG system
struct VRNGRequest {
    VRNGStatus status;
    uint256 randomNumber;
}

/// @dev VRNG normalization methods
/// @dev MOST_EFFICIENT: The most efficient normalization method - uses requestId + randomNumber
/// @dev BALANCED: Normalization method balanced for gas efficiency and normalization - hash of
/// encoded requestId and randomNumber
/// @dev MOST_NORMALIZED: The most normalized normalization method - uses hash of encoded pseudo
/// random block hash and random number
enum VRNGNormalizationMethod {
    MOST_EFFICIENT,
    BALANCED,
    MOST_NORMALIZED
}
