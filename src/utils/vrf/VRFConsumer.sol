// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.26;

import {VRFConsumerAdvanced} from "./VRFConsumerAdvanced.sol";
import {VRFNormalizationMethod} from "./DataTypes.sol";

/// @title VRFConsumer
/// @author Abstract (https://github.com/Abstract-Foundation/absmate/blob/main/src/utils/VRFConsumer.sol)
/// @notice A simple VRF consumer contract for requesting randomness from Proof of Play VRF.
/// @dev Must initialize via `_setVrf` function before requesting randomness.
abstract contract VRFConsumer is VRFConsumerAdvanced {
    constructor() VRFConsumerAdvanced(VRFNormalizationMethod.BALANCED) {}
}
