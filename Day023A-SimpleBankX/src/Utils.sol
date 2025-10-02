// SPDX-License-Identifier: MIT

/// @title Utils (Utility contract for SimpleBankX).
/// @author Michealking (@BuildsWithKing).
/**
 * @notice Created on the 29th of Sept, 2025.
 *
 *     This contract handles custom errors, modifier, receive and fallback.
 */
pragma solidity ^0.8.30;

/// @notice Imports Types contract.
import {Types} from "./Types.sol";

abstract contract Utils is Types {
    // ------------------------------------------------------- Custom errors ------------------------------------------------
    /// @notice Thrown when a user is already registered.
    /// @dev Thrown when a user tries reregistering.
    error AlreadyRegistered();

    /// @notice Thrown when non-registered users tries performing `onlyRegistered` users operation.
    /// @dev Thrown when a non-registered user tries depositing or withdrawing ETH.
    error NotRegistered();

    /// @notice Thrown when users tries depositing zero ETH.
    /// @dev Thrown when a user tries depositing zero ETH.
    error AmountTooLow();

    /// @notice Thrown when users balance is lower than amount being withdrawn.
    /// @dev Thrown when a user attempts to withdraw more ETH than their balance.
    error InsufficientBalance();

    /// @notice Thrown when users tries transferring ETH to self.
    /// @dev Thrown when a user attempts transferring ETH to self.
    error SelfTransferFailed();

    /// @notice Thrown when users withdrawal fails.
    /// @dev Thrown when a user's withdrawal fails.
    error WithdrawalFailed();

    /// @notice Thrown when king inputs high offset.
    /// @dev Thrown when king inputs a high offset.
    error HighOffset();

    /// @notice Thrown when king inputs high limit.
    /// @dev Thrown when king inputs a high limit.
    error HighLimit();

    // -------------------------------------------------------- Modifier --------------------------------------------------------
    /// @notice Restricts access to registered users.
    /// @dev Ensures only registered users can perform operation.
    /// @param _userAddress The user's address.
    modifier onlyRegistered(address _userAddress) {
        // Revert if user isn't registered.
        if (registrationStatus[_userAddress] != RegistrationStatus.Registered) {
            revert NotRegistered();
        }
        _;
    }

    // ------------------------------------------------------- Internal helper function ----------------------------------------
    /// @notice Deposits ETH.
    function _depositETH() internal {
        // Revert if caller's deposit is equal to zero.
        if (msg.value == 0) {
            revert AmountTooLow();
        }

        /// Add amount to caller's balance.
        userBalance[msg.sender] += msg.value;

        // Emit event ETHDeposited.
        emit EthDeposited(msg.sender, msg.value);
    }

    // ---------------------------------------------------- Receive & fallback function ---------------------------------------
    /// @notice Handles ETH deposit without call data.
    receive() external payable onlyRegistered(msg.sender) {
        // Call internal _depositETH function.
        _depositETH();
    }

    /// @notice Handles ETH deposit with call data.
    fallback() external payable onlyRegistered(msg.sender) {
        // Call internal _depositETH function.
        _depositETH();
    }
}
