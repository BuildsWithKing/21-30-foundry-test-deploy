// SPDX-License-Identifier: MIT

/// @title FlexiWhitelist
/// @author Michealking (@BuildsWithKing)
/**
 * @notice Created on the 16th of Sept, 2025.
 *
 *     This is a flexible whitelist smart contract where users can register to be whitelisted,
 *     only king (deployer) can approve/disaprove users and the contract tracks users status
 *     (Registered, Whitelisted & NotWhitelisted).
 */
pragma solidity ^0.8.30;

/// @notice Imports WhitelistManager and Kingable contract.
import {WhitelistManager} from "./WhitelistManager.sol";
import {Kingable} from "buildswithking-security/Kingable.sol";

contract FlexiWhitelist is WhitelistManager {
    // ---------------------------------------------------------- Constructor --------------------------------------------------
    /// @notice Accepts _kingAddress at deployment.
    /// @dev Sets _kingAddress as deployer.
    /// @param _kingAddress The deployer's address
    constructor(address _kingAddress) Kingable(_kingAddress) {
        // Set Contract state as Active on deployment.
        state = ContractState.Active;

        // emit Event ContractActivated.
        emit ContractActivated(_kingAddress);
    }

    // ----------------------------------------------------------- Users external write functions -----------------------------------------------
    /// @notice Registers caller's address.
    function registerForWhitelist() external isActive {
        // Call internal "register" function.
        register();
    }

    /// @notice Unregisters caller's address.
    function unregisterForWhitelist() external isActive onlyRegistered(msg.sender) {
        // Call internal "unregister" function.
        unregister();
    }

    /// @notice Allows caller to claim ETH they mistakenly deposited.
    function withdrawMistakenETH() external isActive {
        // Call internal "claimFunds" function.
        claimFunds();
    }

    // ----------------------------------------------------------- Users external read functions ------------------------------------------------

    /// @notice Returns true or false based on the user's registration status.
    /// @return true if registered, otherwise false.
    function checkMyRegistrationStatus() external view returns (bool) {
        // Return true || false.
        return isRegistered[msg.sender];
    }

    /// @notice Return caller's whitelist status.
    /// @return (0) NotWhitelisted, (1) Whitelisted.
    function checkMyWhitelistStatus() external view returns (WhitelistStatus) {
        // Return O || 1.
        return whitelistStatus[msg.sender];
    }

    /// @notice Return user's whitelist status.
    /// @return (0) NotWhitelisted, (1) Whitelisted.
    function checkIfWhitelisted(address _userAddress) external view returns (WhitelistStatus) {
        // Return 0 || 1.
        return whitelistStatus[_userAddress];
    }

    /// @notice Returns user's balance.
    /// @return The user's balance.
    function checkMyBalance() external view returns (uint256) {
        // Return user's balance.
        return userBalance[msg.sender];
    }

    /// @notice Returns contract balance.
    /// @return The contract's balance.
    function checkContractBalance() external view returns (uint256) {
        // Return contract balance.
        return address(this).balance;
    }

    /// @notice Returns true or false based on contract state.
    /// @return true if active otherwise false.
    function isContractActive() external view returns (bool) {
        // Return contract state.
        return state == ContractState.Active;
    }

    /// @notice Returns Existing registered users count.
    /// @return Existing registered users count.
    function getExistingUsersCount() external view returns (uint256) {
        // Return total registered users count.
        return userCount;
    }

    /// @notice Returns Total users ever registered.
    /// @return Total users ever registered including unregistered.
    function getLifetimeUsers() external view returns (uint256) {
        // Return total users ever registered.
        return lifetimeUsers;
    }

    // ------------------------------------------------------------ King's external write function --------------------------------------------

    /// @notice Whitelists users. Only callable by the king.
    /// @param _userAddress The user's address.
    function whitelistUserAddress(address _userAddress) external onlyKing {
        // Call internal "whitelistUser" function.
        whitelistUser(_userAddress);
    }

    /// @notice Revokes user's whitelist. Only callable by the king.
    /// @param _userAddress The user's address.
    function revokeUserWhitelist(address _userAddress) external onlyKing onlyRegistered(_userAddress) {
        // Call internal "revoke" function.
        revoke(_userAddress);
    }

    /// @notice Activates the contract. Only callable by the king.
    function activateContract() external onlyKing {
        // Call internal "activate" function.
        activate();
    }

    /// @notice Pauses the contract. Only callable by the king
    function pauseContract() external onlyKing {
        // Call internal "pause" function.
        pause();
    }

    // -------------------------------------------------------------- King's external read functions ----------------------------------------------

    /// @notice Returns registered users address.
    /// @param _offset The starting index.
    /// @param _limit The maximum numbers of users.
    /// @return _result Addresses of registered users.
    function getRegisteredUsers(uint256 _offset, uint256 _limit)
        external
        view
        onlyKing
        returns (address[] memory _result)
    {
        // Return internal "getRegistered" function.
        return getRegistered(_offset, _limit);
    }

    /// @notice Returns whitelisted users addresses.
    /// @param _offset The start index.
    /// @param _limit The maximum numbers of users.
    /// @return _result Addresses of whitelisted users.
    function getWhitelistedUsers(uint256 _offset, uint256 _limit)
        external
        view
        onlyKing
        returns (address[] memory _result)
    {
        // Return internal "getWhitelisted" function.
        return getWhitelisted(_offset, _limit);
    }
}
