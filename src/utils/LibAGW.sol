// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAGWRegistry} from "../interfaces/IAGWRegistry.sol";

library LibAGW {
    IAGWRegistry constant AGW_REGISTRY = IAGWRegistry(0xd5E3efDA6bB5aB545cc2358796E96D9033496Dda);

    function isAGWContract(address _address) internal view returns (bool) {
        return AGW_REGISTRY.isAGW(_address);
    }
}
