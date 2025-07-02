// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {MockVRFSystem} from "../mocks/MockVRFSystem.sol";
import {MockVRFConsumerImplementation} from "../mocks/MockVRFConsumerImplementation.sol";
import {MockVRFConsumerAdvancedImplementation} from "../mocks/MockVRFConsumerAdvancedImplementation.sol";
import {Test} from "forge-std/Test.sol";
import {VRFConsumer} from "../../src/utils/vrf/VRFConsumer.sol";
import {VRFConsumerAdvanced} from "../../src/utils/vrf/VRFConsumerAdvanced.sol";
import {VRFRequest, VRFNormalizationMethod} from "../../src/utils/vrf/DataTypes.sol";
import "../../src/utils/vrf/Errors.sol";
import {TestBase} from "../TestBase.sol";
import {console} from "forge-std/console.sol";

contract VRFConsumerTest is TestBase {
    mapping(uint256 randomNumber => bool seen) private _randomNumberSeen;

    MockVRFSystem public vrfSystem;
    MockVRFConsumerImplementation public vrfConsumer;
    MockVRFConsumerAdvancedImplementation public vrfConsumerMostNormalized;
    MockVRFConsumerAdvancedImplementation public vrfConsumerMostEfficient;

    function setUp() public {
        vrfSystem = new MockVRFSystem();
        vrfConsumer = new MockVRFConsumerImplementation();
        vrfConsumer.setVrf(address(vrfSystem));
        vrfConsumerMostNormalized = new MockVRFConsumerAdvancedImplementation(VRFNormalizationMethod.MOST_NORMALIZED);
        vrfConsumerMostNormalized.setVrf(address(vrfSystem));
        vrfConsumerMostEfficient = new MockVRFConsumerAdvancedImplementation(VRFNormalizationMethod.MOST_EFFICIENT);
        vrfConsumerMostEfficient.setVrf(address(vrfSystem));
    }

    function test_uninitializedVrfRevertsOnRequest() public {
        // uninitialize the vrf system
        vrfConsumer.setVrf(address(0));

        vm.expectRevert(VRFConsumer__NotInitialized.selector);
        vrfConsumer.triggerRandomNumberRequest();
    }

    function test_requestRandomNumberCallsVrfSystem() public {
        assertEq(vrfSystem.nextRequestId(), 1);
        vrfConsumer.triggerRandomNumberRequest();
        assertEq(vrfSystem.nextRequestId(), 2);
    }

    function testFuzz_fullfillRandomRequestNotFromVrfSystemReverts(address sender, uint256 randomNumber) public {
        vm.assume(sender != address(vrfSystem));
        vrfConsumer.triggerRandomNumberRequest();

        vm.prank(sender);
        vm.expectRevert(VRFConsumer__OnlyVRFSystem.selector);
        vrfConsumer.randomNumberCallback(0, randomNumber);
    }

    function testFuzz_fullfillRandomRequestNotRequestedReverts(uint256 requestId, uint256 randomNumber) public {
        vm.prank(address(vrfSystem));
        vm.expectRevert(VRFConsumer__InvalidFulfillment.selector);
        vrfConsumer.randomNumberCallback(requestId, randomNumber);
    }

    function testFuzz_fulfillRandomRequestAlreadyFulfilledReverts(uint256 randomNumber1, uint256 randomNumber2)
        public
    {
        uint256 requestId = vrfSystem.nextRequestId();
        vrfConsumer.triggerRandomNumberRequest();

        vm.prank(address(vrfSystem));
        vrfConsumer.randomNumberCallback(requestId, randomNumber1);

        vm.prank(address(vrfSystem));
        vm.expectRevert(VRFConsumer__InvalidFulfillment.selector);
        vrfConsumer.randomNumberCallback(requestId, randomNumber2);
    }

    function test_duplicateRequestIdFromVrfSystemReverts() public {
        uint256 requestId = vrfSystem.nextRequestId();

        vrfConsumer.triggerRandomNumberRequest();
        vrfSystem.setNextRequestId(requestId);

        vm.expectRevert(VRFConsumer__InvalidRequestId.selector);
        vrfConsumer.triggerRandomNumberRequest();
    }

    function testFuzz_vrfResultIsNormalizedDefaultNormalization(uint256 randomNumber) public {
        uint256 requestId = vrfSystem.nextRequestId();
        for (uint256 i = 0; i < 10; i++) {
            vrfConsumer.triggerRandomNumberRequest();
        }
        for (uint256 i = requestId; i < requestId + 10; i++) {
            vm.prank(address(vrfSystem));
            vrfConsumer.randomNumberCallback(i, randomNumber);
        }
        for (uint256 i = requestId; i < requestId + 10; i++) {
            VRFRequest memory result = vrfConsumer.getVrfRequest(i);
            assertNotEq(result.randomNumber, randomNumber);
            assertFalse(_randomNumberSeen[result.randomNumber]);
            _randomNumberSeen[result.randomNumber] = true;
        }
    }

    function testFuzz_vrfResultIsNormalizedEfficientNormalizationMethod(uint256 randomNumber) public {
        uint256 requestId = vrfSystem.nextRequestId();
        for (uint256 i = 0; i < 10; i++) {
            vrfConsumerMostEfficient.triggerRandomNumberRequest();
        }
        for (uint256 i = requestId; i < requestId + 10; i++) {
            vm.prank(address(vrfSystem));
            vrfConsumerMostEfficient.randomNumberCallback(i, randomNumber);
        }
        for (uint256 i = requestId; i < requestId + 10; i++) {
            VRFRequest memory result = vrfConsumerMostEfficient.getVrfRequest(i);
            assertNotEq(result.randomNumber, randomNumber);
            assertFalse(_randomNumberSeen[result.randomNumber]);
            _randomNumberSeen[result.randomNumber] = true;
        }
    }

    function testFuzz_vrfResultIsNormalizedMostNormalizedMethod(uint256 randomNumber) public {
        // most normalized method uses blockhash based on a pseudo random block number in the last
        // 256 blocks, so we need to roll forward to ensure there are at least 256 blocks available
        // to get a blockhash.
        vm.roll(256);

        uint256 requestId = vrfSystem.nextRequestId();
        for (uint256 i = 0; i < 10; i++) {
            vrfConsumerMostNormalized.triggerRandomNumberRequest();
        }
        for (uint256 i = requestId; i < requestId + 10; i++) {
            vm.prank(address(vrfSystem));
            vrfConsumerMostNormalized.randomNumberCallback(i, randomNumber);
        }
        for (uint256 i = requestId; i < requestId + 10; i++) {
            VRFRequest memory result = vrfConsumerMostNormalized.getVrfRequest(i);
            assertNotEq(result.randomNumber, randomNumber);
            assertFalse(_randomNumberSeen[result.randomNumber]);
            _randomNumberSeen[result.randomNumber] = true;
        }
    }

    function testFuzz_canCreateConsumerWithAnyNormalizationMethod(uint8 normalizationMethod) public {
        vm.assume(normalizationMethod <= uint8(type(VRFNormalizationMethod).max));

        address result = _assemblyCreate(normalizationMethod);

        // Deployment should be successful.
        assertNotEq(result, address(0));
    }

    function testFuzz_cannotCreateConsumerWithInvalidNormalizationMethod(uint8 normalizationMethod) public {
        vm.assume(normalizationMethod > uint8(type(VRFNormalizationMethod).max));

        address result = _assemblyCreate(normalizationMethod);

        // Deployment should be failed.
        assertEq(result, address(0));
    }

    function _assemblyCreate(uint8 normalizationMethod) internal returns (address result) {
        bytes memory code =
            abi.encodePacked(type(MockVRFConsumerAdvancedImplementation).creationCode, abi.encode(normalizationMethod));

        // Deploy via assembly to avoid enum revert inside the test code
        assembly {
            result := create(0, add(code, 0x20), mload(code))
        }
    }
}
