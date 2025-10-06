// SPDX-License-Identifier: MIT

/// @title Types (Types contract for DonationVaultV2).
/// @author Michealking (@BuildsWithKing).
/**
 * @notice Created on the 4th of Oct, 2025.
 *
 *     This contract handles state variables, mappings and events.
 */
pragma solidity ^0.8.30;

abstract contract Types {
    // ------------------------------------------------------- State variables --------------------------------------------
    /// @notice Tracks total number of donors.
    uint64 internal lifetimeDonors;

    /// @notice Tracks total ETH ever donated.
    uint256 internal totalDonated;

    /// @notice Stores addresses of all donors.
    address[] internal donorAddresses;

    // ------------------------------------------------------- Mappings -------------------------------------------------

    /// @notice Maps donor address to their balance.
    mapping(address => uint256) internal donorBalance;

    /// @notice Maps donor address to whether they've ever donated at least once (true || false).
    mapping(address => bool) internal hasDonated;

    // -------------------------------------------------------- Events --------------------------------------------------
    /// @notice Emitted once a donor donates ETH.
    /// @param _donorAddress The donor's Address.
    /// @param _amount The amount of ETH deposited.
    event EthDonated(address indexed _donorAddress, uint256 _amount);

    /// @notice Emitted once king withdraws ETH.
    /// @param _kingAddress The king's address.
    /// @param _receiverAddress The receiver's address.
    /// @param _amount The amount of ETH withdrawn.
    event EthWithdrawn(address indexed _kingAddress, address indexed _receiverAddress, uint256 _amount);
}
