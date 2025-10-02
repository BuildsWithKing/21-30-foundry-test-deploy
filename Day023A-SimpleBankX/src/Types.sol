// SPDX-License-Identifier: MIT

/// @title Types (Types contract for SimpleBankX).
/// @author Michealking (@BuildsWithKing).
/**
 * @notice Created on the 29th of Sept, 2025.
 *
 *     This contract handles state variables, enum, mappings and events.
 */
pragma solidity ^0.8.30;

abstract contract Types {
    // ------------------------------------------------------- State variables --------------------------------------------
    /// @notice Records existing registered users.
    uint256 internal usersCount;

    /// @notice Tracks total number of users that have ever registered (lifetime count, including unregistered).
    uint256 internal lifetimeUsers;

    /// @notice Stores addresses of all currently registered users.
    address[] internal userAddresses;
    // ------------------------------------------------------- Enum ------------------------------------------------------
    /// @notice Defines users registration status.
    /// @dev 0 represents NotRegistered, 1 represents registered.

    enum RegistrationStatus {
        NotRegistered, // 0.
        Registered // 1.

    }
    // ------------------------------------------------------- Mappings -------------------------------------------------
    /// @notice Maps user address to their registration status.

    mapping(address => RegistrationStatus) internal registrationStatus;

    /// @notice Maps user address to their balance.
    mapping(address => uint256) internal userBalance;

    /// @notice Maps user address to their index in userAddresses array.
    mapping(address => uint256) internal userIndex;

    // -------------------------------------------------------- Events --------------------------------------------------
    /// @notice Emitted once a user registers.
    /// @param _userId The user's id.
    /// @param _userAddress The user's address.
    event Registered(uint256 indexed _userId, address indexed _userAddress);

    /// @notice Emitted once a user unregisters.
    /// @param _userAddress The user's address.
    /// @param _amount The amount of ETH refunded.
    event UnregisteredWithRefund(address indexed _userAddress, uint256 _amount);

    /// @notice Emitted once a user deposits ETH.
    /// @param _userAddress The user's Address.
    /// @param _amount The amount of ETH deposited.
    event EthDeposited(address indexed _userAddress, uint256 _amount);

    /// @notice Emitted once a user withdraws ETH.
    /// @param _userAddress The user's Address.
    /// @param _amount The amount of ETH withdrawn.
    event EthWithdrawn(address indexed _userAddress, uint256 _amount);

    /// @notice Emitted once a user transfers ETH.
    /// @param _senderAddress The sender's address.
    /// @param _amount The amount of ETH transferred.
    /// @param _receiverAddress The receiver's address.
    event EthTransferred(address indexed _senderAddress, uint256 _amount, address indexed _receiverAddress);
}
