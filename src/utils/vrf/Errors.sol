// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @dev VRF Consumer is not initialized - must be initialized before requesting randomness
error VRFConsumer__NotInitialized();

/// @dev VRF request has not been made - request ID must be recieved before a fulfullment callback
///      can be processed
error VRFConsumer__InvalidFulfillment();

/// @dev VRF request id is invalid. Request id must be unique.
error VRFConsumer__InvalidRequestId();

/// @dev Call can only be made by the VRF system
error VRFConsumer__OnlyVRFSystem();
