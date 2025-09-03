// SPDX-License-Identifier: MIT

/// @title Types (Types file for ModularQuoteVault).
/// @author Michealking(@BuildsWithKing).
/// @notice Created on 21st Aug, 2025.

pragma solidity 0.8.30;

abstract contract Types {
    // ------------------------------------- Variable Assignment -------------------------------------------

    /// @notice Records active quotes.
    uint256 internal id;

    /// @notice Records total stored quotes.
    uint256 internal totalQuotes;

    /// @notice Contract deployer's address.
    address internal owner;

    /// @notice Records contract state.
    ContractState internal state;

    /// @notice Users max age.
    uint8 constant MAX_AGE = 120;

    /// @notice Records active users.
    uint256 internal userCount;

    /// @notice Record total registered users.
    uint256 internal totalUsers;

    /// @notice Records users address.
    address[] internal userAddresses;

    // -------------------------------------- Enums ---------------------------------------------------------

    /// @notice Defines contract state.
    enum ContractState {
        NotActive,
        Active
    }

    /// @notice Defines user's gender.
    enum Gender {
        Unset,
        Male,
        Female
    }

    // ---------------------------------- Structs -------------------------------------------------------------

    /// @notice Groups user's data.
    struct Data {
        // User timestamp.
        uint256 timestamp;
        // User age.
        uint8 age;
        // User gender.
        Gender gender;
        // Record User state.
        bool isRegistered;
        // User full name.
        string fullName;
        // User email.
        string email;
        // User skill.
        string skill;
    }

    /// @notice Groups user's quotes.
    struct Quote {
        // Quote's identity number.
        uint256 quoteId;
        // Time quote was added.
        uint256 addedAt;
        // Time quote was updated.
        uint256 updatedAt;
        // The quote's author.
        string author;
        // The quote.
        string description;
        // Quote's category.
        string category;
        // Quote's source.
        string source;
        // User's personal quote.
        string personalNote;
    }

    // ------------------------------------- Mapping -------------------------------------------------------

    /// @dev Maps user's address to their quotes.
    mapping(address => Quote[]) internal userQuotes;

    /// @dev Maps user's address to their data.
    mapping(address => Data) internal userData;

    /// @dev Maps user's address to index.
    mapping(address => uint256) internal userIndex;
}
