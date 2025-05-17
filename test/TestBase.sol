// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {TestExt} from "forge-zksync-std/TestExt.sol";

contract TestBase is Test, TestExt {
    string public constant DEFAULT_RPC_URL = "https://api.testnet.abs.xyz";

    function initFork() internal {
        string memory rpcUrl = vm.envOr("RPC_URL", DEFAULT_RPC_URL);
        vm.createSelectFork(rpcUrl);
    }
}
