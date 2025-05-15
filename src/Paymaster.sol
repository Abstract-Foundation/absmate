// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BOOTLOADER_FORMAL_ADDRESS} from "era-contracts/system-contracts/Constants.sol";
import {Transaction} from "era-contracts/system-contracts/libraries/TransactionHelper.sol";
import {
    IPaymaster,
    ExecutionResult,
    PAYMASTER_VALIDATION_SUCCESS_MAGIC
} from "era-contracts/system-contracts/interfaces/IPaymaster.sol";

/// @dev Abstract paymaster contract for simplifying the development of onchain paymasters
/// @author Abstract (https://github.com/Abstract-Foundation/absmate/blob/main/src/Paymaster.sol)
abstract contract Paymaster is IPaymaster {
    error BootloaderTransferFailed();

    /// @dev Called by the bootloader to verify that the paymaster agrees to pay for the
    /// fee for the transaction. This transaction should also send the necessary amount of funds onto the bootloader
    /// address.
    /// @param _transaction The transaction itself.
    /// @return magic The value that should be equal to the signature of the validateAndPayForPaymasterTransaction
    /// if the paymaster agrees to pay for the transaction.
    /// @return context The "context" of the transaction: an array of bytes of length at most 1024 bytes, which will be
    /// passed to the `postTransaction` method of the account.
    /// @dev The developer should strive to preserve as many steps as possible both for valid
    /// and invalid transactions as this very method is also used during the gas fee estimation
    /// (without some of the necessary data, e.g. signature).
    function validateAndPayForPaymasterTransaction(bytes32, bytes32, Transaction calldata _transaction)
        external
        payable
        returns (bytes4 magic, bytes memory context)
    {
        uint256 requiredETH = _transaction.gasLimit * _transaction.maxFeePerGas;

        context = _validateTransaction(
            address(uint160(_transaction.from)),
            address(uint160(_transaction.to)),
            requiredETH,
            _transaction.value,
            _transaction.data,
            _transaction.paymasterInput
        );

        magic = PAYMASTER_VALIDATION_SUCCESS_MAGIC;
        (bool success,) = BOOTLOADER_FORMAL_ADDRESS.call{value: requiredETH}("");
        if (!success) {
            revert BootloaderTransferFailed();
        }
    }

    /// @dev Called by the bootloader after the execution of the transaction. Please note that
    /// there is no guarantee that this method will be called at all. Unlike the original EIP4337,
    /// this method won't be called if the transaction execution results in out-of-gas.
    /// @param _context, the context of the execution, returned by the "validateAndPayForPaymasterTransaction" method.
    /// @param  _transaction, the users' transaction.
    /// @param _txHash The hash of the transaction
    /// @param _suggestedSignedHash The hash of the transaction that is signed by an EOA
    /// @param _txResult, the result of the transaction execution (success or failure).
    /// @param _maxRefundedGas, the upper bound on the amount of gas that could be refunded to the paymaster.
    /// @dev The exact amount refunded depends on the gas spent by the "postOp" itself and so the developers should
    /// take that into account.
    function postTransaction(
        bytes calldata _context,
        Transaction calldata _transaction,
        bytes32 _txHash,
        bytes32 _suggestedSignedHash,
        ExecutionResult _txResult,
        uint256 _maxRefundedGas
    ) external payable virtual {}

    /// @dev Validates the transaction and ensures that the paymaster is willing to sponsor the transaction.
    /// If the paymaster is unwilling to sponsor the transaction, the function should revert
    /// @param _sender The sender of the transaction
    /// @param _target The target of the transaction
    /// @param _requiredETH The maximum amount of ETH required to sponsor the transaction
    /// @param _value The value of the transaction
    /// @param _data The data of the transaction
    /// @param _paymasterInput The paymaster input of the transaction
    /// @return context The "context" of the transaction: an array of bytes of length at most 1024 bytes, which will be
    /// passed to the `postTransaction` method of the account.
    function _validateTransaction(
        address _sender,
        address _target,
        uint256 _requiredETH,
        uint256 _value,
        bytes calldata _data,
        bytes calldata _paymasterInput
    ) internal virtual returns (bytes memory context);
}
