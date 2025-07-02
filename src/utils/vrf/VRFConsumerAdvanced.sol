// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IVRFSystemCallback} from "../../interfaces/vrf/IVRFSystemCallback.sol";
import {IVRFSystem} from "../../interfaces/vrf/IVRFSystem.sol";
import "./DataTypes.sol";
import "./Errors.sol";

/// @title VRFConsumerAdvanced
/// @author Abstract (https://github.com/Abstract-Foundation/absmate/blob/main/src/utils/VRFConsumerAdvanced.sol)
/// @notice A consumer contract for requesting randomness from Proof of Play vRNG. (https://docs.proofofplay.com/services/vrng/about)
/// @dev Allows configuration of the randomness normalization method to one of three presets.
///      Must initialize via `_setVrf` function before requesting randomness.
abstract contract VRFConsumerAdvanced is IVRFSystemCallback {
    // keccak256(abi.encode(uint256(keccak256("absmate.vrf.consumer.storage")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant VRF_STORAGE_LOCATION = 0xa2e33039c2b06aa64552c3b67ad94d03188260355f4bb3d7095983e910872300;

    /// @dev The function used to normalize the drand random number
    function(uint256,uint256) internal returns(uint256) internal immutable _normalizeRandomNumber;

    struct VRFConsumerStorage {
        IVRFSystem vrf;
        mapping(uint256 requestId => VRFRequest details) requests;
    }

    /// @notice The VRF system contract address
    IVRFSystem public immutable vrf;

    /// @dev Create a new VRF consumer with the specified normalization method.
    /// @param normalizationMethod The normalization method to use. See `VRFNormalizationMethod` for more details.
    constructor(VRFNormalizationMethod normalizationMethod) {
        if (normalizationMethod == VRFNormalizationMethod.MOST_EFFICIENT) {
            _normalizeRandomNumber = _normalizeRandomNumberHyperEfficient;
        } else if (normalizationMethod == VRFNormalizationMethod.BALANCED) {
            _normalizeRandomNumber = _normalizeRandomNumberHashWithRequestId;
        } else if (normalizationMethod == VRFNormalizationMethod.MOST_NORMALIZED) {
            _normalizeRandomNumber = _normalizeRandomNumberMostNormalized;
        }
    }

    /// @notice Callback for VRF system. Not user callable.
    /// @dev Callback function for the VRF system, normalizes the random number and calls the
    ///      _onRandomNumberFulfilled function with the normalized randomness
    /// @param requestId The request ID
    /// @param randomNumber The random number
    function randomNumberCallback(uint256 requestId, uint256 randomNumber) external {
        VRFConsumerStorage storage $ = _getVRFStorage();
        require(msg.sender == address($.vrf), VRFConsumer__OnlyVRFSystem());

        VRFRequest memory request = $.requests[requestId];
        require(request.status == VRFStatus.REQUESTED, VRFConsumer__InvalidFulfillment());
        uint256 normalizedRandomNumber = _normalizeRandomNumber(randomNumber, requestId);

        $.requests[requestId] = VRFRequest({status: VRFStatus.FULFILLED, randomNumber: normalizedRandomNumber});

        emit RandomNumberFulfilled(requestId, normalizedRandomNumber);

        _onRandomNumberFulfilled(requestId, normalizedRandomNumber);
    }

    /// @dev Set the VRF system contract address. Must be initialized before requesting randomness.
    /// @param _vrf The VRF system contract address
    function _setVrf(address _vrf) internal {
        VRFConsumerStorage storage $ = _getVRFStorage();
        $.vrf = IVRFSystem(_vrf);
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
        VRFConsumerStorage storage $ = _getVRFStorage();

        if (address($.vrf) == address(0)) {
            revert VRFConsumer__NotInitialized();
        }

        uint256 requestId = $.vrf.requestRandomNumberWithTraceId(traceId);

        VRFRequest storage request = $.requests[requestId];
        require(request.status == VRFStatus.NONE, VRFConsumer__InvalidRequestId());
        request.status = VRFStatus.REQUESTED;

        emit RandomNumberRequested(requestId);

        return requestId;
    }

    /// @dev Callback function for the VRF system. Override to handle randomness.
    /// @param requestId The request ID
    /// @param randomNumber The random number
    function _onRandomNumberFulfilled(uint256 requestId, uint256 randomNumber) internal virtual;

    /// @dev Get the VRF request details for a given request ID
    /// @param requestId The request ID
    /// @return result The VRF result
    function _getVrfRequest(uint256 requestId) internal view returns (VRFRequest memory) {
        VRFConsumerStorage storage $ = _getVRFStorage();
        return $.requests[requestId];
    }

    function _getVRFStorage() private pure returns (VRFConsumerStorage storage $) {
        assembly {
            $.slot := VRF_STORAGE_LOCATION
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
