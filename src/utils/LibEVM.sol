// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT} from "era-contracts/system-contracts/Constants.sol";
import {Utils} from "era-contracts/system-contracts/libraries/Utils.sol";

/// @notice Library for detecting EVM comaptibility of addresses
/// @author Abstract (https://github.com/Abstract-Foundation/absmate/blob/main/src/utils/LibEVM.sol)
library LibEVM {
    /// @dev returns true if the address is EVM compatible. Empty addresses are assumed to be EOAs
    /// but could potentially be undeployed zkvm contracts so this should be used with caution.
    function isEVMCompatibleAddress(address _address) internal view returns (bool) {
        bytes32 codeHash = ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT.getRawCodeHash(_address);
        if (codeHash == 0x00) {
            // empty codehash, assume that this is an EOA
            return true;
        }
        return Utils.isCodeHashEVM(codeHash);
    }
}
