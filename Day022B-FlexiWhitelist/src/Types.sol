// SPDX-License-Identifier: MIT

/// @title Types (FlexiWhitelist types contract)
/// @author Michealking (@BuildsWithKing)
/**
 * @notice Created on the 16th of Sept, 2025.
 *
 *     This contract handles state variables, mappings and enums.
 */

/// @dev Abstract contract to be inherited by Utils contract.

pragma solidity ^0.8.30;

abstract contract Types {
    // -----------------------------------------------------State variables ----------------------------------------------------
    /// @notice Records existing registered users.
    uint256 internal userCount;

    /// @notice Tracks total number of users that have ever registered (lifetime count, including unregistered).
    uint256 internal lifetimeUsers;

    /// @notice Stores addresses of all currently registered users.
    address[] internal userAddresses;

    /// @notice Records contract state.
    ContractState internal state;

    // ------------------------------------------------------ Mappings ---------------------------------------------------------------------

    /// @dev Maps users address to their index.
    mapping(address => uint256) internal userIndex;

    /// @dev Maps users address to bool (true or false).
    mapping(address => bool) internal isRegistered;

    /// @dev Maps users address to their whitelist status.
    mapping(address => WhitelistStatus) internal whitelistStatus;

    /// @dev Maps users address to their ETH_Amount deposited.
    mapping(address => uint256) internal userBalance;

    // ----------------------------------------------------- Enums ------------------------------------------------------------------------

    /// @notice Defines contract state.
    /// @dev Contract state can be `Paused` or `Active`.
    enum ContractState {
        Paused,
        Active
    }

    /// @notice Represents the whitelist status a user.
    /// @dev Users whitelist status can be `NotWhitelisted` or `Whitelisted`.
    enum WhitelistStatus {
        NotWhitelisted, // 0
        Whitelisted // 1

    }
}
