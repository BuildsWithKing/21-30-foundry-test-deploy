// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title Types (Types contract for BasicKycV2).
/// @author Michealking (@BuildsWithKing).
/**
 * @notice Created on the 22nd of Oct, 2025.
 *
 *     This contract handles state variables, struct, mappings and events.
 */
abstract contract Types {
    // ------------------------------------------------------- State Variables --------------------------------------------
    /// @notice Records the existing registered users.
    uint64 public s_usersCount;

    /// @notice Tracks the total number of users that has ever registered (lifetime count, including unregistered).
    uint64 public s_lifetimeUsers;

    /// @notice Records the total verified users.
    uint64 public s_totalVerifiedUsers;

    /// @notice Records the admin's address.
    address public s_admin;
    // -------------------------------------------------------- Struct ----------------------------------------------------
    /// @notice Groups user's data.

    struct User {
        uint64 id;
        bool isRegistered;
        bool isVerified;
        bytes32 dataHash;
        uint256 registeredAt;
        uint256 verifiedAt;
    }

    // ------------------------------------------------------- Mappings -------------------------------------------------
    /// @notice Maps an identity number to users address.
    mapping(uint64 => address) internal userAddresses;

    /// @notice Maps users address to their data.
    mapping(address => User) internal userData;
    // -------------------------------------------------------- Events --------------------------------------------------
    /// @notice Emitted once a user registers.
    /// @param _userId The user's id.
    /// @param _userAddress The user's address.
    /// @param _dataHash The user's offchain data hash.

    event UserRegistered(uint64 indexed _userId, address indexed _userAddress, bytes32 indexed _dataHash);

    /// @notice Emitted once a user updates their data.
    /// @param _userId The user's id.
    /// @param _userAddress The user's address.
    /// @param _newDataHash The user's new offchain data hash.
    event UserDataUpdated(uint64 indexed _userId, address indexed _userAddress, bytes32 indexed _newDataHash);

    /// @notice Emitted once a user unregisters.
    /// @param _userId The user's id.
    /// @param _userAddress The user's address.
    event UserUnregistered(uint64 indexed _userId, address indexed _userAddress);

    /// @notice Emitted once an admin is assigned.
    /// @param _adminAddress The admin's address.
    event AdminAssigned(address indexed _adminAddress);

    /// @notice Emitted once the king or admin verifies a user.
    /// @param _userId The user's Id.
    /// @param _userAddress The user's address.
    /// @param _by The king's or admin's address.
    event UserVerified(uint64 indexed _userId, address indexed _userAddress, address indexed _by);

    /// @notice Emitted once the king or admin unverifies a user.
    /// @param _userId The user's Id.
    /// @param _userAddress The user's address.
    /// @param _by The king's or admin's address.
    event UserUnverified(uint64 indexed _userId, address indexed _userAddress, address indexed _by);
}
