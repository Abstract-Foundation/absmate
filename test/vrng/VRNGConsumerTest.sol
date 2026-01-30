// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {MockVRNGSystem} from "../mocks/MockVRNGSystem.sol";
import {MockVRNGConsumerImplementation} from "../mocks/MockVRNGConsumerImplementation.sol";
import {MockVRNGConsumerAdvancedImplementation} from "../mocks/MockVRNGConsumerAdvancedImplementation.sol";
import {Test} from "forge-std/Test.sol";
import {VRNGConsumer} from "../../src/utils/vrng/VRNGConsumer.sol";
import {VRNGConsumerAdvanced} from "../../src/utils/vrng/VRNGConsumerAdvanced.sol";
import {VRNGRequest, VRNGNormalizationMethod} from "../../src/utils/vrng/DataTypes.sol";
import "../../src/utils/vrng/Errors.sol";
import {TestBase} from "../TestBase.sol";
import {console} from "forge-std/console.sol";

contract VRNGConsumerTest is TestBase {
    mapping(uint256 randomNumber => bool seen) private _randomNumberSeen;

    MockVRNGSystem public vrngSystem;
    MockVRNGConsumerImplementation public vrngConsumer;
    MockVRNGConsumerAdvancedImplementation public vrngConsumerMostNormalized;
    MockVRNGConsumerAdvancedImplementation public vrngConsumerMostEfficient;

    function setUp() public {
        vrngSystem = new MockVRNGSystem();
        vrngConsumer = new MockVRNGConsumerImplementation();
        vrngConsumer.setVRNG(address(vrngSystem));
        vrngConsumerMostNormalized = new MockVRNGConsumerAdvancedImplementation(VRNGNormalizationMethod.MOST_NORMALIZED);
        vrngConsumerMostNormalized.setVRNG(address(vrngSystem));
        vrngConsumerMostEfficient = new MockVRNGConsumerAdvancedImplementation(VRNGNormalizationMethod.MOST_EFFICIENT);
        vrngConsumerMostEfficient.setVRNG(address(vrngSystem));
    }

    function test_vrngGetterReturnsVrngSystem() public view {
        assertEq(address(vrngConsumer.vrng()), address(vrngSystem));
        assertEq(address(vrngConsumerMostNormalized.vrng()), address(vrngSystem));
        assertEq(address(vrngConsumerMostEfficient.vrng()), address(vrngSystem));
    }

    function test_uninitializedVrngRevertsOnRequest() public {
        // uninitialize the vrng system
        vrngConsumer.setVRNG(address(0));

        vm.expectRevert(VRNGConsumer__NotInitialized.selector);
        vrngConsumer.triggerRandomNumberRequest();
    }

    function test_requestRandomNumberCallsVrngSystem() public {
        assertEq(vrngSystem.nextRequestId(), 1);
        vrngConsumer.triggerRandomNumberRequest();
        assertEq(vrngSystem.nextRequestId(), 2);
    }

    function testFuzz_fullfillRandomRequestNotFromVrngSystemReverts(address sender, uint256 randomNumber) public {
        vm.assume(sender != address(vrngSystem));
        vrngConsumer.triggerRandomNumberRequest();

        vm.prank(sender);
        vm.expectRevert(VRNGConsumer__OnlyVRNGSystem.selector);
        vrngConsumer.randomNumberCallback(0, randomNumber);
    }

    function testFuzz_fullfillRandomRequestNotRequestedReverts(uint256 requestId, uint256 randomNumber) public {
        vm.prank(address(vrngSystem));
        vm.expectRevert(VRNGConsumer__InvalidFulfillment.selector);
        vrngConsumer.randomNumberCallback(requestId, randomNumber);
    }

    function testFuzz_fulfillRandomRequestAlreadyFulfilledReverts(uint256 randomNumber1, uint256 randomNumber2) public {
        uint256 requestId = vrngSystem.nextRequestId();
        vrngConsumer.triggerRandomNumberRequest();

        vm.prank(address(vrngSystem));
        vrngConsumer.randomNumberCallback(requestId, randomNumber1);

        vm.prank(address(vrngSystem));
        vm.expectRevert(VRNGConsumer__InvalidFulfillment.selector);
        vrngConsumer.randomNumberCallback(requestId, randomNumber2);
    }

    function test_duplicateRequestIdFromVrngSystemReverts() public {
        uint256 requestId = vrngSystem.nextRequestId();

        vrngConsumer.triggerRandomNumberRequest();
        vrngSystem.setNextRequestId(requestId);

        vm.expectRevert(VRNGConsumer__InvalidRequestId.selector);
        vrngConsumer.triggerRandomNumberRequest();
    }

    function testFuzz_vrngResultIsNormalizedDefaultNormalization(uint256 randomNumber) public {
        uint256 requestId = vrngSystem.nextRequestId();
        for (uint256 i = 0; i < 10; i++) {
            vrngConsumer.triggerRandomNumberRequest();
        }
        for (uint256 i = requestId; i < requestId + 10; i++) {
            vm.prank(address(vrngSystem));
            vrngConsumer.randomNumberCallback(i, randomNumber);
        }
        for (uint256 i = requestId; i < requestId + 10; i++) {
            VRNGRequest memory result = vrngConsumer.getVRNGRequest(i);
            assertNotEq(result.randomNumber, randomNumber);
            assertFalse(_randomNumberSeen[result.randomNumber]);
            _randomNumberSeen[result.randomNumber] = true;
        }
    }

    function testFuzz_vrngResultIsNormalizedEfficientNormalizationMethod(uint256 randomNumber) public {
        uint256 requestId = vrngSystem.nextRequestId();
        for (uint256 i = 0; i < 10; i++) {
            vrngConsumerMostEfficient.triggerRandomNumberRequest();
        }
        for (uint256 i = requestId; i < requestId + 10; i++) {
            vm.prank(address(vrngSystem));
            vrngConsumerMostEfficient.randomNumberCallback(i, randomNumber);
        }
        for (uint256 i = requestId; i < requestId + 10; i++) {
            VRNGRequest memory result = vrngConsumerMostEfficient.getVRNGRequest(i);
            assertNotEq(result.randomNumber, randomNumber);
            assertFalse(_randomNumberSeen[result.randomNumber]);
            _randomNumberSeen[result.randomNumber] = true;
        }
    }

    function testFuzz_vrngResultIsNormalizedMostNormalizedMethod(uint256 randomNumber) public {
        // most normalized method uses blockhash based on a pseudo random block number in the last
        // 256 blocks, so we need to roll forward to ensure there are at least 256 blocks available
        // to get a blockhash.
        vm.roll(256);

        uint256 requestId = vrngSystem.nextRequestId();
        for (uint256 i = 0; i < 10; i++) {
            vrngConsumerMostNormalized.triggerRandomNumberRequest();
        }
        for (uint256 i = requestId; i < requestId + 10; i++) {
            vm.prank(address(vrngSystem));
            vrngConsumerMostNormalized.randomNumberCallback(i, randomNumber);
        }
        for (uint256 i = requestId; i < requestId + 10; i++) {
            VRNGRequest memory result = vrngConsumerMostNormalized.getVRNGRequest(i);
            assertNotEq(result.randomNumber, randomNumber);
            assertFalse(_randomNumberSeen[result.randomNumber]);
            _randomNumberSeen[result.randomNumber] = true;
        }
    }

    function testFuzz_canCreateConsumerWithAnyNormalizationMethod(uint8 normalizationMethod) public {
        vm.assume(normalizationMethod <= uint8(type(VRNGNormalizationMethod).max));

        address result = _assemblyCreate(normalizationMethod);

        // Deployment should be successful.
        assertNotEq(result, address(0));
    }

    function testFuzz_cannotCreateConsumerWithInvalidNormalizationMethod(uint8 normalizationMethod) public {
        vm.assume(normalizationMethod > uint8(type(VRNGNormalizationMethod).max));

        address result = _assemblyCreate(normalizationMethod);

        // Deployment should be failed.
        assertEq(result, address(0));
    }

    function _assemblyCreate(uint8 normalizationMethod) internal returns (address result) {
        bytes memory code = abi.encodePacked(
            type(MockVRNGConsumerAdvancedImplementation).creationCode, abi.encode(normalizationMethod)
        );

        // Deploy via assembly to avoid enum revert inside the test code
        assembly {
            result := create(0, add(code, 0x20), mload(code))
        }
    }
}
