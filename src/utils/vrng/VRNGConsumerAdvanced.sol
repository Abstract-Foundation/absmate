// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IVRNGSystemCallback} from "../../interfaces/vrng/IVRNGSystemCallback.sol";
import {IVRNGSystem} from "../../interfaces/vrng/IVRNGSystem.sol";
import "./DataTypes.sol";
import "./Errors.sol";

/// @title VRNGConsumerAdvanced
/// @author Abstract (https://github.com/Abstract-Foundation/absmate/blob/main/src/utils/VRNGConsumerAdvanced.sol)
/// @notice A consumer contract for requesting randomness from Proof of Play vRNG. (https://docs.proofofplay.com/services/vrng/about)
/// @dev Allows configuration of the randomness normalization method to one of three presets.
///      Must initialize via `_setVRNG` function before requesting randomness.
abstract contract VRNGConsumerAdvanced is IVRNGSystemCallback {
    // keccak256(abi.encode(uint256(keccak256("absmate.vrng.consumer.storage")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant VRNG_STORAGE_LOCATION = 0xfc4de942100e62e9eb61034c75124e3689e7605ae081e19c59907d5c442ea700;

    /// @dev The function used to normalize the drand random number
    function(uint256, uint256) internal returns (uint256) internal immutable _normalizeRandomNumber;

    struct VRNGConsumerStorage {
        IVRNGSystem vrng;
        mapping(uint256 requestId => VRNGRequest details) requests;
    }

    /// @notice The VRNG system contract address
    function vrng() public view virtual returns (address) {
        return address(_getVRNGStorage().vrng);
    }

    /// @dev Create a new VRNG consumer with the specified normalization method.
    /// @param normalizationMethod The normalization method to use. See `VRNGNormalizationMethod` for more details.
    constructor(VRNGNormalizationMethod normalizationMethod) {
        if (normalizationMethod == VRNGNormalizationMethod.MOST_EFFICIENT) {
            _normalizeRandomNumber = _normalizeRandomNumberHyperEfficient;
        } else if (normalizationMethod == VRNGNormalizationMethod.BALANCED) {
            _normalizeRandomNumber = _normalizeRandomNumberHashWithRequestId;
        } else if (normalizationMethod == VRNGNormalizationMethod.MOST_NORMALIZED) {
            _normalizeRandomNumber = _normalizeRandomNumberMostNormalized;
        }
    }

    /// @notice Callback for VRNG system. Not user callable.
    /// @dev Callback function for the VRNG system, normalizes the random number and calls the
    ///      _onRandomNumberFulfilled function with the normalized randomness
    /// @param requestId The request ID
    /// @param randomNumber The random number
    function randomNumberCallback(uint256 requestId, uint256 randomNumber) external {
        VRNGConsumerStorage storage $ = _getVRNGStorage();
        require(msg.sender == address($.vrng), VRNGConsumer__OnlyVRNGSystem());

        VRNGRequest memory request = $.requests[requestId];
        require(request.status == VRNGStatus.REQUESTED, VRNGConsumer__InvalidFulfillment());
        uint256 normalizedRandomNumber = _normalizeRandomNumber(randomNumber, requestId);

        $.requests[requestId] = VRNGRequest({status: VRNGStatus.FULFILLED, randomNumber: normalizedRandomNumber});

        emit RandomNumberFulfilled(requestId, normalizedRandomNumber);

        _onRandomNumberFulfilled(requestId, normalizedRandomNumber);
    }

    /// @dev Set the VRNG system contract address. Must be initialized before requesting randomness.
    /// @param _vrng The VRNG system contract address
    function _setVRNG(address _vrng) internal {
        VRNGConsumerStorage storage $ = _getVRNGStorage();
        $.vrng = IVRNGSystem(_vrng);
    }

    /// @dev Request a random number. Guards against duplicate requests.
    /// @return requestId The request ID
    function _requestRandomNumber() internal returns (uint256) {
        return _requestRandomNumber(0);
    }

    /// @dev Request a random number with a trace ID. Guards against duplicate requests.
    /// @param traceId The trace ID
    /// @return requestId The request ID
    function _requestRandomNumber(uint256 traceId) internal returns (uint256) {
        VRNGConsumerStorage storage $ = _getVRNGStorage();

        if (address($.vrng) == address(0)) {
            revert VRNGConsumer__NotInitialized();
        }

        uint256 requestId = $.vrng.requestRandomNumberWithTraceId(traceId);

        VRNGRequest storage request = $.requests[requestId];
        require(request.status == VRNGStatus.NONE, VRNGConsumer__InvalidRequestId());
        request.status = VRNGStatus.REQUESTED;

        emit RandomNumberRequested(requestId);

        return requestId;
    }

    /// @dev Callback function for the VRNG system. Override to handle randomness.
    /// @param requestId The request ID
    /// @param randomNumber The random number
    function _onRandomNumberFulfilled(uint256 requestId, uint256 randomNumber) internal virtual;

    /// @dev Get the VRNG request details for a given request ID
    /// @param requestId The request ID
    /// @return result The VRNG result
    function _getVRNGRequest(uint256 requestId) internal view returns (VRNGRequest memory) {
        VRNGConsumerStorage storage $ = _getVRNGStorage();
        return $.requests[requestId];
    }

    function _getVRNGStorage() private pure returns (VRNGConsumerStorage storage $) {
        assembly {
            $.slot := VRNG_STORAGE_LOCATION
        }
    }

    /// @dev Most efficient, but least normalized method of normalization - uses requestId + number
    function _normalizeRandomNumberHyperEfficient(uint256 randomNumber, uint256 requestId)
        private
        pure
        returns (uint256)
    {
        // allow overflow here in case of a very large requestId and randomness
        unchecked {
            return requestId + randomNumber;
        }
    }

    /// @dev Hash with requestId - balance of efficiency and normalization
    function _normalizeRandomNumberHashWithRequestId(uint256 randomNumber, uint256 requestId)
        private
        pure
        returns (uint256)
    {
        return uint256(keccak256(abi.encodePacked(requestId, randomNumber)));
    }

    /// @dev Most expensive, but most normalized method of normalization - hash of encoded blockhash
    ///      from pseudo random block number derived via requestId
    function _normalizeRandomNumberMostNormalized(uint256 randomNumber, uint256 requestId)
        private
        view
        returns (uint256)
    {
        unchecked {
            return uint256(keccak256(abi.encodePacked(blockhash(block.number - (requestId % 256)), randomNumber)));
        }
    }
}
