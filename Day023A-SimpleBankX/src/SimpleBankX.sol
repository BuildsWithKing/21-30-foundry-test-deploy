// SPDX-License-Identifier: MIT

/// @title SimpleBankX contract.
/// @author Michealking (@BuildsWithKing).
/**
 * @notice Created on the 29th of Sept, 2025.
 *
 *     This contract allows users deposit, withdraw ETH, check registration status, view their balance, and the total bank balance.
 */
pragma solidity ^0.8.30;

/// @notice Imports BankBase and KingablePausable contract.
import {BankBase} from "./BankBase.sol";
import {KingablePausable} from "buildswithking-security/access/extensions/KingablePausable.sol";

contract SimpleBankX is KingablePausable, BankBase {
    // --------------------------------------------------------- Constructor --------------------------------------------
    /// @notice Accepts king's address at deployment.
    /// @dev Sets _kingAddress as deployer.
    /// @param _kingAddress The king's address.
    constructor(address _kingAddress) KingablePausable(_kingAddress) {}

    // ----------------------------------------------------------- Users external write functions. -----------------------------------
    /// @notice Registers caller.
    function registerMyAddress() external whenActive {
        // Call internal `register` function.
        register();
    }

    /// @notice Unregisters caller.
    /* @dev Refunds full balance and resets registration in one transaction.
        Not recommended for contract accounts due to potential gas heavy fallback.
    */
    function unregisterMyAddress() external whenActive onlyRegistered(msg.sender) {
        // Call internal `unregister` function.
        unregister();
    }

    /// @notice Deposits callers ETH.
    function depositMyETH() external payable whenActive onlyRegistered(msg.sender) {
        // Call internal `deposit` function.
        deposit();
    }

    /// @notice Withdraws ETH from caller's balance.
    /// @param _ethAmount The amount of ETH to be withdrawn.
    function withdrawMyETH(uint256 _ethAmount) external whenActive onlyRegistered(msg.sender) {
        // Call internal `withdraw` function.
        withdraw(_ethAmount);
    }

    /// @notice Transfers ETH to another registered user's address.
    /// @param _userAddress The user's address.
    /// @param _ethAmount The amount of ETH to be transferred.
    function transferETH(address _userAddress, uint256 _ethAmount)
        external
        whenActive
        onlyRegistered(msg.sender)
        onlyRegistered(_userAddress)
    {
        // Call internal `transfer` function.
        transfer(_userAddress, _ethAmount);
    }

    // ---------------------------------------------------- Users external read functions. ----------------------------------------------------
    /// @notice Returns caller's registration status.
    /// @dev 0 represents NotRegistered, 1 represents registered.
    /// @return Caller's registration status.
    function myRegistrationStatus() external view returns (RegistrationStatus) {
        return registrationStatus[msg.sender];
    }

    /// @notice Returns address's registration status.
    /// @dev 0 represents NotRegistered, 1 represents registered.
    /// @param _userAddress The user's address.
    /// @return Address's registration status.
    function checkUserRegistrationStatus(address _userAddress) external view returns (RegistrationStatus) {
        return registrationStatus[_userAddress];
    }

    /// @notice Returns active users count.
    /// @return Existing registered users count. Excludes unregistered.
    function activeUsersCount() external view returns (uint256) {
        return usersCount;
    }

    /// @notice Returns lifetime users count.
    /// @return Total users ever registered. Includes unregistered.
    function lifetimeUsersCount() external view returns (uint256) {
        return lifetimeUsers;
    }

    /// @notice Returns caller's balance.
    /// @return Caller's balance.
    function myBalance() external view returns (uint256) {
        return userBalance[msg.sender];
    }

    /// @notice Returns address's balance.
    /// @param _userAddress The user's address.
    /// @return Address's balance.
    function checkUserBalance(address _userAddress) external view returns (uint256) {
        return userBalance[_userAddress];
    }
    // ---------------------------------------------------- Users public read function. ----------------------------------------------------

    /// @notice Returns bank's balance.
    /// @return Bank's balance.
    function bankBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // --------------------------------------------------------------------- King's external read function. -----------------------------------------
    /// @notice Returns registered user's address.
    /// @param _offset The starting index.
    /// @param _limit The maximum number of users.
    /// @return _result Addresses of registered user.
    function getRegisteredUsers(uint256 _offset, uint256 _limit)
        external
        view
        onlyKing
        returns (address[] memory _result)
    {
        // Return internal `getRegistered` function.
        return getRegistered(_offset, _limit);
    }
}
