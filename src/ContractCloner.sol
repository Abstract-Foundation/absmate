// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibClone} from "./utils/LibClone.sol";

contract ContractCloner {
    function clone(address implementation, bytes memory constructorArgs) public payable returns (address) {
        return LibClone.clone(msg.value, implementation, constructorArgs);
    }

    function cloneDeterministic(address implementation, bytes memory constructorArgs, bytes32 salt)
        public
        payable
        returns (address)
    {
        return LibClone.cloneDeterministic(msg.value, implementation, constructorArgs, salt);
    }

    /// @dev Returns the address of the clone of
    /// `implementation` using immutable arguments encoded in `args`, with `salt`, by `deployer`.
    /// Note: The returned result has dirty upper 96 bits. Please clean if used in assembly.
    function predictDeterministicAddress(address implementation, bytes memory constructorArgs, bytes32 salt)
        public
        view
        returns (address predicted)
    {
        predicted = LibClone.predictDeterministicAddress(implementation, constructorArgs, salt);
    }
}
