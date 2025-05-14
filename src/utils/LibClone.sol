// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {
    ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT,
    DEPLOYER_SYSTEM_CONTRACT
} from "era-contracts/system-contracts/Constants.sol";
import {SystemContractsCaller} from "era-contracts/system-contracts/libraries/SystemContractsCaller.sol";

library LibClone {
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

    function predictDeterministicAddress(address implementation, bytes memory constructorArgs, bytes32 salt)
        internal
        view
        returns (address)
    {
        bytes32 codeHash = ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT.getCodeHash(uint256(uint160(implementation)));
        return DEPLOYER_SYSTEM_CONTRACT.getNewAddressCreate2(address(this), codeHash, salt, constructorArgs);
    }
}
