// SPDX-License-Identifier: MIT

/// @title Utils (FlexiWhitelist utility contract).
/// @author Michealking (@BuildsWithKing).
/**
 * @notice Created on the 16th of Sept, 2025.
 *
 *     This contract contains custom errors, events, modifiers, internal helper functions,
 *     king's write functions (handling contract state), with fallback and receive function.
 */

/// @dev Abstract contract to be inherited by WhitelistManager contract.

pragma solidity ^0.8.30;

/// @notice Imports Types and kingable contract.
import {Types} from "./Types.sol";
import {Kingable} from "buildswithking-security/Kingable.sol";

abstract contract Utils is Types, Kingable {
    // --------------------------------------------------------- Custom errors -------------------------------------------------
    /// @notice Thrown for duplicate registration.
    /// @dev Thrown when users tries registering more than once.
    error AlreadyRegistered();

    /// @notice Thrown for zero balance.
    /// @dev Thrown when users with zero balance tries to claim ETH.
    error InsufficientFunds();

    /// @notice Thrown for failed claim transaction.
    /// @dev Thrown when users ETH claim fails.
    error ClaimFailed();

    /// @notice Thrown for non-registered user.
    /// @dev Thrown when king tries whitelisting a non-registered user.
    error NotRegistered();

    /// @notice Thrown for an already whitelisted user.
    /// @dev Thrown when king tries whitelisting an already whitelisted user.
    error AlreadyWhitelisted();

    /// @notice Thrown for users currently not whitelisted.
    /// @dev Thrown when king tries dewhitelisting an already dewhitelisted user.
    error AlreadyNotWhitelisted();

    /// @notice Thrown for high offset input.
    /// @dev Thrown when king inputs high starting index (_offset).
    error HighOffset();

    /// @notice Thrown for paused contract.
    /// @dev Thrown when contract state is set to `Paused`.
    error PausedContract();

    /// @notice Thrown for already active contract.
    /// @dev Thrown when king tries activating contract when already active.
    error AlreadyActive();

    /// @notice Thrown for already paused contract.
    /// @dev Thrown when king tries pausing contract when already paused.
    error AlreadyPaused();

    /// @notice Thrown for zero ETH deposit.
    /// @dev Thrown when a user tries depositing zero ETH.
    error AmountTooLow();

    // ---------------------------------------------------------- Events -------------------------------------------------------

    /// @notice Emitted when a user registers.
    /// @param _userId The user's identity number.
    /// @param _userAddress The user's address.
    event Registered(uint256 indexed _userId, address indexed _userAddress);

    /// @notice Emitted when a user unregisters.
    /// @param _userAddress The user's address.
    event Unregistered(address indexed _userAddress);

    /// @notice Emitted when a user successfully claims ETH mistakenly deposited.
    /// @param _userAddress The user's address.
    /// @param _ethAmount The amount of ETH claimed.
    event EthClaimed(address indexed _userAddress, uint256 _ethAmount);

    /// @notice Emitted when king whitelists a user.
    /// @param _userAddress The user's address.
    event Whitelisted(address indexed _userAddress);

    /// @notice Emitted when king revokes a user's whitelist.
    /// @param _kingAddress The king's address.
    /// @param _userAddress The user's address.
    event WhitelistRevoked(address indexed _kingAddress, address indexed _userAddress);

    /// @notice Emitted when king activates contract.
    /// @param _kingAddress The contract deployer's address.
    event ContractActivated(address indexed _kingAddress);

    /// @notice Emitted when king pauses contract.
    /// @param _kingAddress The contract deployer's address.
    event ContractPaused(address indexed _kingAddress);

    /// @notice Emitted when a user deposits ETH.
    /// @param _userAddress The user's address.
    /// @param _ethAmount The amount of ETH deposited.
    event EthDeposited(address indexed _userAddress, uint256 _ethAmount);
    // --------------------------------------------------------------- Modifiers --------------------------------------------------

    /// @notice Retricts access when contract is paused.
    /// @dev Retricts access once contract is set to `Paused`.
    modifier isActive() {
        // Revert `PausedContract` if contract is paused.
        if (state == ContractState.Paused) {
            revert PausedContract();
        }
        _;
    }

    /// @notice Restricts access to registered users.
    /// @dev Reverts `NotRegistered` if user isn't registered.
    /// @param _userAddress The user's address.
    modifier onlyRegistered(address _userAddress) {
        // Revert `NotRegistered` if user isn't registered.
        if (!isRegistered[_userAddress]) {
            revert NotRegistered();
        }
        _;
    }

    // --------------------------------------------------------------------- Internal helper function ---------------------------------------------------------
    /// @notice Sets user's whitelist status to NotWhitelisted.
    /// @dev Assigns NotWhitelisted to user's whitelist status.
    /// @param _userAddress The user's address.
    function _setNotWhitelisted(address _userAddress) internal {
        // Set user's whitelist status to NotWhitelisted.
        whitelistStatus[_userAddress] = WhitelistStatus.NotWhitelisted;
    }

    /// @notice Accepts ETH deposit.
    /// @dev Accepts users deposit through receive & fallback.
    function _depositETH() private {
        // Revert `AmountTooLow` if user's deposit is equal to zero.
        if (msg.value == 0) {
            revert AmountTooLow();
        }
        // Add amount to user's balance.
        userBalance[msg.sender] += msg.value;

        // Emit event EthDeposited.
        emit EthDeposited(msg.sender, msg.value);
    }

    // -------------------------------------------------------------- King's internal write functions --------------------------------------

    /// @notice Activates the contract. Only callable by the king.
    function activate() internal onlyKing {
        // Revert `AlreadyActive` if contract is currently active.
        if (state == ContractState.Active) {
            revert AlreadyActive();
        }

        // Set contract state to active.
        state = ContractState.Active;

        // Emit event ContractActivated.
        emit ContractActivated(msg.sender);
    }

    /// @notice Pauses the contract. Only callable by the king
    function pause() internal onlyKing {
        // Revert `AlreadyPaused` if contract is currently paused.
        if (state == ContractState.Paused) {
            revert AlreadyPaused();
        }

        // Set contract state to paused.
        state = ContractState.Paused;

        // Emit event ContractPaused.
        emit ContractPaused(msg.sender);
    }

    // ------------------------------------------------------------ Receive & fallback function --------------------------------------------

    /// @notice Handles ETH deposit without call data.
    receive() external payable {
        // Call internal _depositETH function.
        _depositETH();
    }

    /// @notice Handles ETH deposit with calldata.
    fallback() external payable {
        // Call internal _depositETH function.
        _depositETH();
    }
}
