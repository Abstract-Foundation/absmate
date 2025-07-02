// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

enum VRFStatus {
    NONE,
    REQUESTED,
    FULFILLED
}

struct VRFResult {
    VRFStatus status;
    uint256 randomNumber;
}

enum VRFNormalizationMethod {
    MOST_EFFICIENT,
    BALANCED,
    MOST_NORMALIZED
}
