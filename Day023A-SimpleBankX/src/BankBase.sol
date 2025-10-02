// SPDX-License-Identifier: MIT

/// @title BankBase (BankBase for SimpleBankX contract).
/// @author Michealking (@BuildsWithKing).
/**
 * @notice Created on the 29th of Sept, 2025.
 *
 *     This contract handles internal deposit, withdrawal, and transfer ETH logic.
 */
pragma solidity ^0.8.30;

/// @notice Imports Utils and ReentrancyGuard contract.
import {Utils} from "./Utils.sol";
import {ReentrancyGuard} from "buildswithking-security/security/ReentrancyGuard.sol";

abstract contract BankBase is Utils, ReentrancyGuard {
    // ----------------------------------------------------------- Users internal write function -----------------------------------
    /// @notice Registers caller.
    function register() internal {
        // Revert if user is already registered.
        if (registrationStatus[msg.sender] == RegistrationStatus.Registered) {
            revert AlreadyRegistered();
        }

        // Increment usersCount and lifetimeUsers by one.
        unchecked {
            usersCount++;
            lifetimeUsers++;
        }

        // Assign id.
        uint256 id = usersCount;

        // Register caller's address.
        registrationStatus[msg.sender] = RegistrationStatus.Registered;

        // Push caller's address into userAddresses array.
        userAddresses.push(msg.sender);

        // Assign caller's index .
        userIndex[msg.sender] = userAddresses.length - 1;

        // Emit event Registered.
        emit Registered(id, msg.sender);
    }

    /// @notice Unregisters caller.
    /* @dev Refunds full balance and resets registration in one transaction.
        Not recommended for contract accounts due to potential gas heavy fallback.
    */
    function unregister() internal nonReentrant onlyRegistered(msg.sender) {
        // Assign _index.
        uint256 _index = userIndex[msg.sender];

        // Assign _lastIndex of userAddresses.
        uint256 _lastIndex = userAddresses.length - 1;

        // Swap last index and update index.
        if (_index != _lastIndex) {
            // Assign _lastUser.
            address _lastUser = userAddresses[_lastIndex];
            userAddresses[_index] = _lastUser;
            userIndex[_lastUser] = _index;
        }

        // Remove array's last element.
        userAddresses.pop();

        // Delete caller's index.
        delete userIndex[msg.sender];

        // Assign caller's balance.
        uint256 _balance = userBalance[msg.sender];

        // Deduct one from usersCount.
        unchecked {
            usersCount--;
        }

        // Unregister caller's address.
        registrationStatus[msg.sender] = RegistrationStatus.NotRegistered;

        // Set caller's balance to zero.
        userBalance[msg.sender] = 0;

        // Fund caller their entire balance, Revert if withdrawal fails.
        (bool success,) = payable(msg.sender).call{value: _balance}("");
        if (!success) {
            revert WithdrawalFailed();
        }

        // Emit event Unregistered.
        emit UnregisteredWithRefund(msg.sender, _balance);
    }

    /// @notice Deposits callers ETH. Emits {EthDeposited} event on success.
    function deposit() internal onlyRegistered(msg.sender) {
        // Call internal `_depositETH` helper function.
        _depositETH();
    }

    /// @notice Withdraws ETH from caller's balance.
    /// @param _ethAmount The amount of ETH to be withdrawn.
    function withdraw(uint256 _ethAmount) internal nonReentrant onlyRegistered(msg.sender) {
        // Revert if _ethAmount is greater than user's balance.
        if (_ethAmount > userBalance[msg.sender]) {
            revert InsufficientBalance();
        }

        // Deduct _ethAmount from caller's balance.
        userBalance[msg.sender] -= _ethAmount;

        // Fund caller amount withdrawn, Revert if withdrawal fails.
        (bool success,) = payable(msg.sender).call{value: _ethAmount}("");
        if (!success) {
            revert WithdrawalFailed();
        }

        // Emit event EthWithdrawn.
        emit EthWithdrawn(msg.sender, _ethAmount);
    }

    /// @notice Transfers ETH to another registered user's address.
    /// @param _userAddress The user's address.
    /// @param _ethAmount The amount of ETH to be transferred.
    function transfer(address _userAddress, uint256 _ethAmount)
        internal
        nonReentrant
        onlyRegistered(msg.sender)
        onlyRegistered(_userAddress)
    {
        // Revert if caller's address is _userAddress.
        if (msg.sender == _userAddress) {
            revert SelfTransferFailed();
        }
        // Revert if _ethAmount is greater than caller's balance.
        if (_ethAmount > userBalance[msg.sender]) {
            revert InsufficientBalance();
        }

        // Deduct _ethAmount from caller's balance.
        userBalance[msg.sender] -= _ethAmount;

        // Fund _userAddress _ethAmount.
        userBalance[_userAddress] += _ethAmount;

        // Emit event EthTransferred.
        emit EthTransferred(msg.sender, _ethAmount, _userAddress);
    }

    // ------------------------------------------------------ King's internal read function ------------------------------------------
    /// @notice Returns registered user's address.
    /// @param _offset The starting index.
    /// @param _limit The maximum number of users.
    /// @return _result Addresses of registered user.
    function getRegistered(uint256 _offset, uint256 _limit) internal view returns (address[] memory _result) {
        // Assign _totalUsers.
        uint256 _totalUsers = userAddresses.length;

        // Return empty array if total users is equal zero.
        if (_totalUsers == 0) {
            return new address[](0);
        }

        // Revert if _offset is greater than or equal to totalUsers.
        if (_offset >= _totalUsers) {
            revert HighOffset();
        }

        // Revert if _limit is greater than 1000.
        if (_limit > 1000) {
            revert HighLimit();
        }

        // Assign _end.
        uint256 _end = _offset + _limit;

        // Reset _end to total registered users.
        if (_end > _totalUsers) {
            _end = _totalUsers;
        }

        // Compute numbers of addresses to be returned.
        uint256 len = _end - _offset;

        // Use a new array to store registered users.
        _result = new address[](len);

        // Assign _user.
        address[] storage _user = userAddresses;

        // Loop through the range.
        for (uint256 i; i < len; i++) {
            // Copy address from userAddresses to new array (_result).
            _result[i] = _user[_offset + i];
        }
    }
}
