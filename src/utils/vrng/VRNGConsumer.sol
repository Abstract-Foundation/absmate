// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.26;

import {VRNGConsumerAdvanced} from "./VRNGConsumerAdvanced.sol";
import {VRNGNormalizationMethod} from "./DataTypes.sol";

/// @title VRNGConsumer
/// @author Abstract (https://github.com/Abstract-Foundation/absmate/blob/main/src/utils/VRNGConsumer.sol)
/// @notice A simple consumer contract for requesting randomness from Proof of Play vRNG. (https://docs.proofofplay.com/services/vrng/about)
/// @dev Must initialize via `_setVRNG` function before requesting randomness.
abstract contract VRNGConsumer is VRNGConsumerAdvanced {
    constructor() VRNGConsumerAdvanced(VRNGNormalizationMethod.BALANCED) {}
}
