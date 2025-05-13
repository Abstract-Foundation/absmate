// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT} from "era-contracts/system-contracts/Constants.sol";
import {Utils} from "era-contracts/system-contracts/libraries/Utils.sol";

library LibEVM {
    function isEVMCompatibleAddress(address _address) internal view returns (bool) {
        bytes32 codeHash = ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT.getRawCodeHash(_address);
        if (codeHash == 0x00) {
            // empty codehash, assume that this is an EOA
            return true;
        }
        return Utils.isCodeHashEVM(codeHash);
    }
}
