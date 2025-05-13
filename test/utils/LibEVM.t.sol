// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {TestBase} from "../TestBase.sol";
import {LibEVM} from "../../src/utils/LibEVM.sol";

contract LibEVMTest is TestBase {
    address public seaport1_6 = 0x0000000000000068F116a894984e2DB1123eB395;
    address public eoa = 0x6f6426a9b93a7567fCCcBfE5d0d6F26c1085999b;
    address public zkContract = 0xc4FaD9826681f1979c5EE03EF81404bfaaC9F201;

    function setUp() public {
        string memory rpcUrl = vm.envString("RPC_URL");
        if (bytes(rpcUrl).length == 0) {
            vm.createSelectFork("https://api.testnet.abs.xyz");
        } else {
            vm.createSelectFork(rpcUrl);
        }
    }

    function test_isEVMCompatibleAddress_seaport1_6() public view {
        assertTrue(LibEVM.isEVMCompatibleAddress(seaport1_6));
    }

    function test_isEVMCompatibleAddress_eoa() public view {
        assertTrue(LibEVM.isEVMCompatibleAddress(eoa));
    }

    function test_isEVMCompatibleAddress_zkContract() public view {
        assertFalse(LibEVM.isEVMCompatibleAddress(zkContract));
    }
}
