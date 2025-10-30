// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title KycManager (KycManager contract for BasicKycV2).
/// @author MichealKing (@BuildsWithKing)
/* @notice Created on the 22nd of Oct, 2025

    This contract handles the users, king and admin's internal logic. 
*/

/// @notice Imports Utils contract.
import {Utils} from "./Utils.sol";

abstract contract KycManager is Utils {
    // -------------------------------------------------- Users Internal Write Function ------------------------------------
    /// @notice Registers the caller's data.
    /// @dev Users Id start from 1.
    /// @param _dataHash The caller's off-chain data hash.
    function register(bytes32 _dataHash) internal {
        // Revert if the caller is already registered.
        if (userData[msg.sender].isRegistered) {
            revert AlreadyRegistered();
        }

        // Increment usersCount and lifetimeUsers by 1.
        unchecked {
            ++s_usersCount;
            ++s_lifetimeUsers;
        }

        // Assign user and register the caller's data.
        User memory user = User({
            id: s_lifetimeUsers,
            dataHash: _dataHash,
            isRegistered: true,
            isVerified: false,
            registeredAt: block.timestamp,
            verifiedAt: 0
        });

        // Store the caller's data.
        userData[msg.sender] = user;

        // Store the caller's address.
        userAddresses[s_lifetimeUsers] = msg.sender;

        // Emit the event UserRegistered.
        emit UserRegistered(user.id, msg.sender, _dataHash);
    }

    /// @notice Updates the caller's data.
    /// @param _newDataHash The caller's new off-chain data hash.
    function updateData(bytes32 _newDataHash) internal onlyRegistered(msg.sender) {
        // Revert if the caller's new data is the same as the old data.
        if (_newDataHash == userData[msg.sender].dataHash) {
            revert SameData();
        }

        // Update the caller's data hash.
        userData[msg.sender].dataHash = _newDataHash;

        // Emit the event UserDataUpdated.
        emit UserDataUpdated(userData[msg.sender].id, msg.sender, _newDataHash);
    }

    /// @notice Unregisters the caller.
    function unregister() internal onlyRegistered(msg.sender) {
        // Assign user.
        User memory user = userData[msg.sender];

        // Decrement usersCount and totalVerifiedUsers by 1, if the user is already verified.
        unchecked {
            --s_usersCount;
            if (user.isVerified == true && s_totalVerifiedUsers > 0) {
                --s_totalVerifiedUsers;
            }
        }

        // Assign userId.
        uint64 userId = user.id;

        // Delete the caller's data.
        delete userData[msg.sender];

        // Assign the caller's id to the zero address.
        userAddresses[userId] = address(0);

        // Emit the event UserUnregistered.
        emit UserUnregistered(userId, msg.sender);
    }

    // ------------------------------------------------------- King & Admin's Internal Write Functions -----------------------------------
    /// @notice Verifies the user. Callable only by the king and the admin.
    /// @param _userAddress The user's address.
    function verify(address _userAddress) internal onlyRegistered(_userAddress) {
        // Assign user.
        User memory user = userData[_userAddress];

        // Revert if user is already verified.
        if (user.isVerified) {
            revert AlreadyVerified();
        }

        // Increment totalVerifiedUsers by 1.
        unchecked {
            ++s_totalVerifiedUsers;
        }

        // Set the user's verification status to true.
        userData[_userAddress].isVerified = true;

        // Set the user's verification time.
        userData[_userAddress].verifiedAt = block.timestamp;

        // Emit the event UserVerified.
        emit UserVerified(user.id, _userAddress, msg.sender);
    }

    /// @notice Unverifies the user. Callable only by the king and the admin.
    /// @param _userAddress The user's address.
    function unverify(address _userAddress) internal onlyRegistered(_userAddress) {
        // Assign user.
        User memory user = userData[_userAddress];

        // Revert if user is already unverified.
        if (!user.isVerified) {
            revert AlreadyUnverified();
        }

        // Decrement totalVerifiedUsers by 1.
        unchecked {
            --s_totalVerifiedUsers;
        }

        // Set the user's verification status to false.
        userData[_userAddress].isVerified = false;

        // Emit the event UserUnverified.
        emit UserUnverified(user.id, _userAddress, msg.sender);
    }

    // --------------------------------------------------- King & Admin's Internal Read Function ---------------------------------------
    /// @notice Returns registered users addresses. Callable only by the king and the admin.
    /// @param _startId The Id of the first user.
    /// @param _endId The Id of the last user.
    /// @return _result Addresses of the registered users.
    function registered(uint64 _startId, uint64 _endId) internal view returns (address[] memory _result) {
        // Revert if there's no registered user.
        if (s_lifetimeUsers == 0) {
            revert NoRegisteredUser();
        }

        /* Revert if _startId is equal to zero.
        Or if _startId is greater than _endId. 
        Or if _startId is greater than lifetime users. 
        Or if _endId is less than _startId. 
       */
        if (_startId == 0 || _startId > _endId || _startId > s_lifetimeUsers || _endId < _startId) {
            revert InvalidRange();
        }

        // Revert if _endId is greater than 1000.
        if (_endId > 1000) {
            revert HugeEndId();
        }

        // Reset _endId to lifetime users.
        if (_endId > s_lifetimeUsers) {
            _endId = s_lifetimeUsers;
        }

        // Count the amount of active users between start and end.
        uint64 active = 0;

        // Loop through userAddresses, pick only the active registered users.
        for (uint64 id = _startId; id <= _endId; ++id) {
            address user = userAddresses[id];
            if (user != address(0) && userData[user].isRegistered) {
                unchecked {
                    ++active;
                }
            }
        }

        // Use a new array to store the registered users.
        _result = new address[](active);

        // Assign idx.
        uint64 idx = 0;

        // Populate the _result array.
        for (uint64 id = _startId; id <= _endId; ++id) {
            address user = userAddresses[id];
            if (user != address(0) && userData[user].isRegistered) {
                _result[idx++] = user;
            }
        }

        // return the new array of registered users.
        return _result;
    }

    /// @notice Returns verified users addresses. Callable only by the king and the admin.
    /// @param _startId The Id of the first user.
    /// @param _endId The Id of the last user.
    /// @return _result Addresses of the verified users.
    function verified(uint64 _startId, uint64 _endId) internal view returns (address[] memory _result) {
        // Revert if there's no verified user.
        if (s_totalVerifiedUsers == 0) {
            revert NoVerifiedUser();
        }

        /* Revert if _startId is equal to zero.
        Or if _startId is greater than _endId. 
        Or if _startId is greater than lifetime users. 
        Or if _endId is less than _startId.
       */
        if (_startId == 0 || _startId > _endId || _startId > s_lifetimeUsers || _endId < _startId) {
            revert InvalidRange();
        }

        // Revert if _endId is greater than 1000.
        if (_endId > 1000) {
            revert HugeEndId();
        }

        // Reset _endId to lifetime users.
        if (_endId > s_lifetimeUsers) {
            _endId = s_lifetimeUsers;
        }

        // Count the amount of active users between start and end.
        uint64 active = 0;

        // Loop through userAddresses, pick only the active verified users.
        for (uint64 id = _startId; id <= _endId; ++id) {
            address user = userAddresses[id];
            if (user != address(0) && userData[user].isVerified) {
                unchecked {
                    ++active;
                }
            }
        }

        // Use a new array to store the verified users.
        _result = new address[](active);

        // Assign idx.
        uint64 idx = 0;

        // Populate the _result array.
        for (uint64 id = _startId; id <= _endId; ++id) {
            address user = userAddresses[id];
            if (user != address(0) && userData[user].isVerified) {
                _result[idx++] = user;
            }
        }

        // return the new array of verified users.
        return _result;
    }
}
