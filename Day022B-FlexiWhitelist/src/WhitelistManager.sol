// SPDX-License-Identifier: MIT

/// @title WhiteListManager (WhitelistManager contract for FlexiWhitelist).
/// @author Michealking (@BuildsWithKing).
/**
 * @notice Created on the 16th of Sept, 2025.
 *
 *     This contract manages users and king's write and read internal functions.
 */

/// @dev Abstract contract to be inherited by FlexiWhitelist contract.

pragma solidity ^0.8.30;

/// @notice Imports Utils contract.
import {Utils} from "./Utils.sol";

abstract contract WhitelistManager is Utils {
    // ----------------------------------------------- Users internal write functions ---------------------------------------------
    /// @notice Registers caller's address.
    function register() internal isActive {
        // Revert `AlreadyRegistered` if user is registered.
        if (isRegistered[msg.sender]) {
            revert AlreadyRegistered();
        }

        /*  Increment userCount and lifetimeUsers by 1 
            for every successful registration. */
        unchecked {
            userCount++;
            lifetimeUsers++;
        }

        // Assign user's id.
        uint256 id = userCount;

        // Register new user.
        isRegistered[msg.sender] = true;

        // Push new user's address into the array.
        userAddresses.push(msg.sender);

        // Call `_setNotWhitelisted` internal helper function.
        _setNotWhitelisted(msg.sender);

        // Assign user's index.
        userIndex[msg.sender] = userAddresses.length - 1;

        // Emit event Registered.
        emit Registered(id, msg.sender);
    }

    /// @notice Unregisters caller's address.
    function unregister() internal isActive onlyRegistered(msg.sender) {
        // Assign index.
        uint256 _index = userIndex[msg.sender];

        // Assign last index on usersAddress.
        uint256 _lastIndex = userAddresses.length - 1;

        // Swap Last index and update index.
        if (_index != _lastIndex) {
            // Assign last user.
            address _lastUser = userAddresses[_lastIndex];
            userAddresses[_index] = _lastUser;
            userIndex[_lastUser] = _index;
        }

        // Remove array's last element.
        userAddresses.pop();

        // Delete user's index.
        delete userIndex[msg.sender];

        // Subtract 1 from address count.
        unchecked {
            userCount--;
        }

        // Unregister user.
        isRegistered[msg.sender] = false;

        // Call internal helper function.
        _setNotWhitelisted(msg.sender);

        // Emit event Unregistered.
        emit Unregistered(msg.sender);
    }

    /// @notice Allows caller to claim ETH they mistakenly deposited.
    function claimFunds() internal isActive nonReentrant {
        // Assign balance.
        uint256 _balance = userBalance[msg.sender];

        // Revert `InsufficientFunds` for zero balance.
        if (_balance == 0) {
            revert InsufficientFunds();
        }

        // Set userBalance to zero.
        userBalance[msg.sender] = 0;

        // Fund user their entire balance.
        (bool success,) = payable(msg.sender).call{value: _balance}("");
        if (!success) {
            revert ClaimFailed();
        }

        // Emit event EthClaimed.
        emit EthClaimed(msg.sender, _balance);
    }

    // --------------------------------------------------------- King's internal write function -------------------------------------------------------

    /// @notice Whitelists users. Only callable by the king.
    /// @param _userAddress The user's address.
    function whitelistUser(address _userAddress) internal onlyKing nonReentrant onlyRegistered(_userAddress) {
        // Revert `AlreadyWhitelisted` if user is already whitelisted.
        if (whitelistStatus[_userAddress] == WhitelistStatus.Whitelisted) {
            revert AlreadyWhitelisted();
        }

        // Set user's whitelist status to whitelisted.
        whitelistStatus[_userAddress] = WhitelistStatus.Whitelisted;

        // Emit event Whitelisted.
        emit Whitelisted(_userAddress);
    }

    /// @notice Revokes user's whitelist. Only callable by the king.
    /// @param _userAddress The user's address.
    function revoke(address _userAddress) internal onlyKing nonReentrant onlyRegistered(_userAddress) {
        // Revert `AlreadyNotWhitelisted` if user is currently not whitelisted.
        if (whitelistStatus[_userAddress] == WhitelistStatus.NotWhitelisted) {
            revert AlreadyNotWhitelisted();
        }

        // Call internal helper function.
        _setNotWhitelisted(_userAddress);

        // Emit event WhitelistRevoked.
        emit WhitelistRevoked(msg.sender, _userAddress);
    }

    // ---------------------------------------------------------- King's internal read function -------------------------------------------------------
    /// @notice Returns registered users address. Callable by the king.
    /// @param _offset The starting index.
    /// @param _limit The maximum numbers of users.
    /// @return _result Addresses of registered users.
    function getRegistered(uint256 _offset, uint256 _limit) internal view onlyKing returns (address[] memory _result) {
        // Assign totalUsers.
        uint256 _totalUsers = userAddresses.length;

        // Revert `HighOffset` if _offset is greater than or equal to total users.
        if (_offset >= _totalUsers) {
            revert HighOffset();
        }

        // Assign _end.
        uint256 _end = _offset + _limit;

        // Reset _end to total registered users.
        if (_end > _totalUsers) {
            _end = _totalUsers;
        }

        // Compute number of addresses to be returned.
        uint256 len = _end - _offset;

        // Use a new array to store registered users.
        _result = new address[](len);

        // Assign _users.
        address[] storage _users = userAddresses;

        // Loop through the range.
        for (uint256 i; i < len; i++) {
            // Copy addresses from usersAddress to new array (_result).
            _result[i] = _users[_offset + i];
        }
    }

    /// @notice Returns whitelisted users addresses. Callable by the king.
    /// @param _offset The starting index.
    /// @param _limit The maximum numbers of users.
    /// @return _result Addresses of whitelisted users.
    function getWhitelisted(uint256 _offset, uint256 _limit)
        internal
        view
        onlyKing
        returns (address[] memory _result)
    {
        // Assign totalUsers.
        uint256 _totalUsers = userAddresses.length;

        // Return empty array, if condition is met.
        if (_totalUsers == 0) {
            return new address[](0);
        }

        // Revert `HighOffset` if _offset is greater than or equal to total users.
        if (_offset >= _totalUsers) {
            revert HighOffset();
        }

        // Assign end.
        uint256 _end = _offset + _limit;

        // Reset end to total registered users.
        if (_end > _totalUsers) {
            _end = _totalUsers;
        }

        // Assign validCount.
        uint256 _validCount = 0;

        // First pass: count how many users are actually whitelisted.
        for (uint256 i = _offset; i < _end; i++) {
            if (whitelistStatus[userAddresses[i]] == WhitelistStatus.Whitelisted) {
                unchecked {
                    _validCount++;
                }
            }

            // Allocate exact-sized array.
            _result = new address[](_validCount);

            // Assign index.
            uint256 _index = 0;

            // Second pass: collect valid addresses.
            for (uint256 j = _offset; j < _end; j++) {
                address _userAddress = userAddresses[j];
                if (whitelistStatus[_userAddress] == WhitelistStatus.Whitelisted) {
                    _result[_index] = _userAddress;
                    unchecked {
                        _index++;
                    }
                }
            }
        }
    }
}
