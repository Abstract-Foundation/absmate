// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAGWRegistry} from "../interfaces/IAGWRegistry.sol";

/// @notice Library for detecting and interacting with AGW contracts
// @author Abstract (https://github.com/Abstract-Foundation/absmate/blob/main/src/utils/LibAGW.sol)
library LibAGW {
    IAGWRegistry constant AGW_REGISTRY = IAGWRegistry(0xd5E3efDA6bB5aB545cc2358796E96D9033496Dda);

    /// @dev returns true if the address is a deployed AGW contract
    function isAGWContract(address _address) internal view returns (bool) {
        return AGW_REGISTRY.isAGW(_address);
    }
}
