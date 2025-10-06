// SPDX-License-Identifier: MIT

/// @title Utils (Utility contract for DonationVaultV2).
/// @author Michealking (@BuildsWithKing).
/**
 * @notice Created on the 4th of Oct, 2025.
 *
 *     This contract handles custom errors, internal helper function, receive and fallback.
 */
pragma solidity ^0.8.30;

/// @notice Imports Types and ReentrancyGuard contract.
import {Types} from "./Types.sol";
import {ReentrancyGuard} from "buildswithking-security/security/ReentrancyGuard.sol";

abstract contract Utils is ReentrancyGuard, Types {
    // ------------------------------------------------------- Custom errors ------------------------------------------------
    /// @notice Thrown when donor tries donating zero ETH.
    /// @dev Thrown when a donor tries donating zero ETH.
    error AmountTooLow();

    /// @notice Thrown when contract balance is lower than amount being withdrawn.
    /// @dev Thrown when king attempts withdrawing more ETH than contract balance.
    error InsufficientBalance();

    /// @notice Thrown when king tries withdrawing ETH to the zero or this contract address.
    /// @dev Thrown when the king attempts withdrawing ETH to the zero or this contract address.
    error InvalidAddress();

    /// @notice Thrown when king's withdrawal fails.
    /// @dev Thrown when the king withdrawal fails.
    error WithdrawalFailed();

    /// @notice Thrown when king inputs high offset.
    /// @dev Thrown when king inputs a high offset.
    error HighOffset();

    /// @notice Thrown when king inputs high limit.
    /// @dev Thrown when king inputs a high limit.
    error HighLimit();

    // ------------------------------------------------------- Internal helper function ----------------------------------------
    /// @notice Donates ETH.
    function _donateETH() internal {
        // Revert if caller's donation is equal to zero.
        if (msg.value == 0) {
            revert AmountTooLow();
        }

        // Increment lifetime donor count if donor's balance is equal to zero.
        if (donorBalance[msg.sender] == 0) {
            unchecked {
                lifetimeDonors++;
            }
        }

        // Add ETH amount to totalDonated.
        totalDonated += msg.value;

        // Add ETH amount to donor's balance.
        donorBalance[msg.sender] += msg.value;

        /* Set donor's donation status to true, 
        and push donor's address into donorAddresses array, 
        Only if donor haven't donated before. */
        if (!hasDonated[msg.sender]) {
            // Set the donor's donation status to true.
            hasDonated[msg.sender] = true;

            // Push donor's address into donorAddresses array.
            donorAddresses.push(msg.sender);
        }

        // Emit event EthDonated.
        emit EthDonated(msg.sender, msg.value);
    }

    // ---------------------------------------------------- Receive & fallback function ---------------------------------------
    /// @notice Handles ETH donation without call data. Emits {EthDonated} event on success.
    receive() external payable {
        // Call internal `_donateETH` helper function.
        _donateETH();
    }

    /// @notice Handles ETH donation with call data. Emits {EthDonated} event on success.
    fallback() external payable {
        // Call internal `_donateETH` helper function.
        _donateETH();
    }
}
