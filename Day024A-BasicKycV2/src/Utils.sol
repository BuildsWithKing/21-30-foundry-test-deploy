// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title Utils (Utility contract for BasicKycV2).
/// @author Michealking (@BuildsWithKing).
/**
 * @notice Created on the 22nd of Oct, 2025.
 *
 *     This contract handles custom errors, modifier, and rejects ETH transfers.
 */

/// @notice Imports Types and KingRejectETH contract.
import {Types} from "./Types.sol";
import {KingRejectETH} from "buildswithking-security/access/guards/KingRejectETH.sol";

abstract contract Utils is KingRejectETH, Types {
    // ------------------------------------------------------- Custom Errors ------------------------------------------------
    /// @notice Thrown for an already registered user.
    /// @dev Thrown when a user tries reregistering.
    error AlreadyRegistered();

    /// @notice Thrown for the same data input.
    /// @dev Thrown when a user tries updating their data with same old data.
    error SameData();

    /// @notice Thrown for a non-registered user.
    /// @dev Thrown when a non-registered user tries unregistering or updating their data hash.
    error NotRegistered();

    /// @notice Thrown for an already verified user.
    /// @dev Thrown when the king or admin tries verifying an already verified user.
    error AlreadyVerified();

    /// @notice Thrown for an already unverified user.
    /// @dev Thrown when the king or admin tries unverifying an already unverified user.
    error AlreadyUnverified();

    /// @notice Thrown for zero registered user.
    /// @dev Thrown when the king or admin tries returning the registered users, while there's none.
    error NoRegisteredUser();

    /// @notice Thrown for an invalid startId or endId.
    /// @dev Thrown when the king or admin inputs an endId which is less than or equal to the startId.
    error InvalidRange();

    /// @notice Thrown for huge endId.
    /// @dev Thrown when the king or admin inputs an endId greater than a thousand.
    error HugeEndId();

    /// @notice Thrown for zero verified user.
    /// @dev Thrown when the king or admin tries returning the verified users, while there's none.
    error NoVerifiedUser();

    /// @notice Thrown for unauthorized access on admin and king function.
    /// @dev Thrown when a user tries performing the admin and king only operation.
    error AccessDenied();

    /// @notice Thrown for the same admin's address.
    /// @dev Thrown when the king tries assigning the old admin as the new admin.
    /// @param _admin The admin's address.
    error SameAdmin(address _admin);

    /// @notice Thrown for the zero or this contract address.
    /// @dev Thrown when the king tries assigning admin to the zero or this contract address.
    /// @param _invalid The invalid address.
    error InvalidAddress(address _invalid);

    // -------------------------------------------------------- Modifier ----------------------------------------------------
    /// @notice Restricts access to only registered users.
    /// @dev Ensures only registered users can perform the operation.
    /// @param _userAddress The user's address.
    modifier onlyRegistered(address _userAddress) {
        // Assign user.
        User memory user = userData[_userAddress];

        // Revert if the user isn't registered.
        if (!user.isRegistered) {
            revert NotRegistered();
        }
        _;
    }
}
