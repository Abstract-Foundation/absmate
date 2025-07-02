// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @dev VRNG Consumer is not initialized - must be initialized before requesting randomness
error VRNGConsumer__NotInitialized();

/// @dev VRNG request has not been made - request ID must be recieved before a fulfullment callback
///      can be processed
error VRNGConsumer__InvalidFulfillment();

/// @dev VRNG request id is invalid. Request id must be unique.
error VRNGConsumer__InvalidRequestId();

/// @dev Call can only be made by the VRNG system
error VRNGConsumer__OnlyVRNGSystem();
