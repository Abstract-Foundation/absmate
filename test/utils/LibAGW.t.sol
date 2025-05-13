// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {TestBase} from "../TestBase.sol";
import {LibAGW} from "../../src/utils/LibAGW.sol";

contract LibAGWTest is TestBase {
    function setUp() public {
        string memory rpcUrl = vm.envString("RPC_URL");
        if (bytes(rpcUrl).length == 0) {
            vm.createSelectFork("https://api.testnet.abs.xyz");
        } else {
            vm.createSelectFork(rpcUrl);
        }
    }

    function test_isAGWContract_true() public view {
        assertTrue(LibAGW.isAGWContract(0x917a67DE1a4e29d8820E1AeAfd1E7e53F19F2Df7));
    }

    function test_isAGWContract_false() public view {
        assertFalse(LibAGW.isAGWContract(0x6f6426a9b93a7567fCCcBfE5d0d6F26c1085999b));
    }
}
