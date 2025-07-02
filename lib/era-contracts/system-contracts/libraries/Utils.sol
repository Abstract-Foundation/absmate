// SPDX-License-Identifier: MIT
// We use a floating point pragma here so it can be used within other projects that interact with the ZKsync ecosystem without using our exact pragma version.
pragma solidity ^0.8.0;

import {Overflow} from "../SystemContractErrors.sol";
import {EVM_BYTECODE_FLAG} from "../Constants.sol";

/**
 * @author Matter Labs
 * @custom:security-contact security@matterlabs.dev
 * @dev Common utilities used in ZKsync system contracts
 */
library Utils {

    function safeCastToU32(uint256 _x) internal pure returns (uint32) {
        if (_x > type(uint32).max) {
            revert Overflow();
        }

        return uint32(_x);
    }

    /// @return If this bytecode hash for EVM contract or not
    function isCodeHashEVM(bytes32 _bytecodeHash) internal pure returns (bool) {
        return (uint8(_bytecodeHash[0]) == EVM_BYTECODE_FLAG);
    }
}
