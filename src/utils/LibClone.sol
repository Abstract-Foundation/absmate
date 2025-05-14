// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {
    ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT,
    DEPLOYER_SYSTEM_CONTRACT
} from "era-contracts/system-contracts/Constants.sol";
import {SystemContractsCaller} from "era-contracts/system-contracts/libraries/SystemContractsCaller.sol";

/// @dev Library for deploying clones of contracts on ZKsync
/// ZKsync only requires a specfic bytecode to be deployed once and stores the hash of the bytecode.
/// This allows us to deploy the same bytecode extremely cheaply without needing to use minimal proxies.
/// @author Abstract (https://github.com/Abstract-Foundation/absmate/blob/main/src/utils/LibClone.sol)
library LibClone {
    /// @dev Deploys a clone of `implementation` using the abi encoded constructor args `constructorArgs`
    /// Deposits `value` ETH during deployment.
    function clone(uint256 value, address implementation, bytes memory constructorArgs) internal returns (address) {
        bytes32 codeHash = ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT.getCodeHash(uint256(uint160(implementation)));
        bytes memory data = SystemContractsCaller.systemCallWithPropagatedRevert(
            uint32(gasleft()),
            address(DEPLOYER_SYSTEM_CONTRACT),
            uint128(value),
            abi.encodeCall(DEPLOYER_SYSTEM_CONTRACT.create, (bytes32(0), codeHash, constructorArgs))
        );
        return abi.decode(data, (address));
    }

    /// @dev Deploys a clone of `implementation` using the abi encoded constructor args `constructorArgs`
    /// and a deterministic salt `salt`. Deposits `value` ETH during deployment.
    function cloneDeterministic(uint256 value, address implementation, bytes memory constructorArgs, bytes32 salt)
        internal
        returns (address)
    {
        bytes32 codeHash = ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT.getCodeHash(uint256(uint160(implementation)));
        bytes memory data = SystemContractsCaller.systemCallWithPropagatedRevert(
            uint32(gasleft()),
            address(DEPLOYER_SYSTEM_CONTRACT),
            uint128(value),
            abi.encodeCall(DEPLOYER_SYSTEM_CONTRACT.create2, (salt, codeHash, constructorArgs))
        );
        return abi.decode(data, (address));
    }

    /// @dev Predicts the deterministic address of a clone of `implementation` using the abi encoded constructor args `constructorArgs`
    /// and a deterministic salt `salt`.
    function predictDeterministicAddress(address implementation, bytes memory constructorArgs, bytes32 salt)
        internal
        view
        returns (address)
    {
        bytes32 codeHash = ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT.getCodeHash(uint256(uint160(implementation)));
        return DEPLOYER_SYSTEM_CONTRACT.getNewAddressCreate2(address(this), codeHash, salt, constructorArgs);
    }
}
