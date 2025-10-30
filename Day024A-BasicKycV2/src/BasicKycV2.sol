// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title BasicKycV2.
/// @author MichealKing (@BuildsWithKing)
/* @notice Created on the 24th of Oct, 2025.

    This smart contract allows users register to be verified, unregister, 
    check their registration and verification status, and that of others.  
    Only the king and the admin can verify, unverify, view registered and verified users. 
*/

/// @notice Imports KingablePausable and KycManager contract.
import {KingablePausable} from "buildswithking-security/access/extensions/KingablePausable.sol";
import {KycManager} from "./KycManager.sol";

contract BasicKycV2 is KycManager, KingablePausable {
    // ------------------------------------------------- Constructor -------------------------------------------------
    /// @notice Sets the king and admin's address at deployment.
    /// @dev Assigns the king as the contract deployer.
    /// @param _kingAddress The king's address.
    /// @param _adminAddress The admin's address.
    constructor(address _kingAddress, address _adminAddress) KingablePausable(_kingAddress) {
        // Revert if `_adminAddress` is the zero or this contract address.
        if (_adminAddress == address(0) || _adminAddress == address(this)) {
            revert InvalidAddress(_adminAddress);
        }

        // Assign admin.
        s_admin = _adminAddress;

        // Emit the event AdminAssigned.
        emit AdminAssigned(_adminAddress);
    }

    // ------------------------------------------------- Modifier ----------------------------------------------------
    /// @notice Restricts access to only the King and the Admin.
    /// @dev Ensures only the king or admin can perform the operation.
    modifier onlyKingAndAdmin() {
        if (msg.sender != s_king && msg.sender != s_admin) {
            revert AccessDenied();
        }
        _;
    }

    // ------------------------------------------------- Users External Write Functions ------------------------------
    /// @notice Registers the caller's data.
    /// @param _dataHash The caller's off-chain data hash.
    function registerMyData(bytes32 _dataHash) external whenActive {
        // Call the internal `register` function.
        register(_dataHash);
    }

    /// @notice Updates the caller's data.
    /// @param _newDataHash The caller's new offchain data hash.
    function updateMyData(bytes32 _newDataHash) external onlyRegistered(msg.sender) whenActive {
        // Call the internal `updateData` function.
        updateData(_newDataHash);
    }

    /// @notice Unregisters the caller.
    function unregisterMyData() external onlyRegistered(msg.sender) whenActive {
        // Call the internal `unregister` function.
        unregister();
    }

    // ---------------------------------------------------- Users External Read Functions -------------------------------
    /// @notice Returns caller's data.
    /// @return The caller's stored data.
    function myData() external view returns (User memory) {
        return userData[msg.sender];
    }

    /// @notice Returns the caller's registration status.
    /// @return The caller's registration status (true || false).
    function myRegistrationStatus() external view returns (bool) {
        return userData[msg.sender].isRegistered;
    }

    /// @notice Returns the caller's registration time.
    /// @return The caller's registration time.
    function myRegistrationTimestamp() external view returns (uint256) {
        return userData[msg.sender].registeredAt;
    }

    /// @notice Returns the user's registration status.
    /// @param _userAddress The user's address.
    /// @return The user's registration status (true || false).
    function userRegistrationStatus(address _userAddress) external view returns (bool) {
        return userData[_userAddress].isRegistered;
    }

    /// @notice Returns the user's registration time.
    /// @param _userAddress The user's address.
    /// @return The user's registration time.
    function userRegistrationTimestamp(address _userAddress) external view returns (uint256) {
        return userData[_userAddress].registeredAt;
    }

    /// @notice Returns the caller's verification status.
    /// @return The caller's verification status (true || false).
    function myVerificationStatus() external view returns (bool) {
        return userData[msg.sender].isVerified;
    }

    /// @notice Returns the user's verification status.
    /// @param _userAddress The user's address.
    /// @return The user's verification status (true || false).
    function userVerificationStatus(address _userAddress) external view returns (bool) {
        return userData[_userAddress].isVerified;
    }

    /// @notice Returns the caller's verification time.
    /// @return The caller's verification time.
    function myVerificationTimestamp() external view returns (uint256) {
        return userData[msg.sender].verifiedAt;
    }

    /// @notice Returns the user's verification time.
    /// @param _userAddress The user's address.
    /// @return The user's verification time.
    function userVerificationTimestamp(address _userAddress) external view returns (uint256) {
        return userData[_userAddress].verifiedAt;
    }

    /// @notice Returns the caller's id.
    /// @return The caller's identification number.
    function myId() external view returns (uint64) {
        return userData[msg.sender].id;
    }

    /// @notice Returns the user's id.
    /// @param _userAddress The user's address.
    /// @return The user's identification number.
    function userId(address _userAddress) external view returns (uint64) {
        return userData[_userAddress].id;
    }

    // ----------------------------------------------- King's External Write Function ------------------------------------
    /// @notice Assigns the admin. Callable only by the king.
    /// @param _adminAddress The admin's address.
    function assignAdmin(address _adminAddress) external onlyKing {
        // Revert if `_adminAddress` is the current admin.
        if (_adminAddress == s_admin) {
            revert SameAdmin(_adminAddress);
        }

        // Revert if `_adminAddress` is the zero or this contract address.
        if (_adminAddress == address(0) || _adminAddress == address(this)) {
            revert InvalidAddress(_adminAddress);
        }

        // Assign admin.
        s_admin = _adminAddress;

        // Emit the event AdminAssigned.
        emit AdminAssigned(_adminAddress);
    }

    // ----------------------------------------------------- King & Admin's External Write Functions ------------------------------
    /// @notice Verifies the user. Callable only by the king and the admin.
    /// @param _userAddress The user's address.
    function verifyUser(address _userAddress) external onlyRegistered(_userAddress) onlyKingAndAdmin {
        // Call the internal `verify` function.
        verify(_userAddress);
    }

    /// @notice Verifies many users. Callable only by the king and the admin.
    /// @param _userAddresses The users' addresses.
    function verifyManyUsers(address[] memory _userAddresses) external onlyKingAndAdmin {
        // Assign len.
        uint256 len = _userAddresses.length;

        // Loop through the array and verify users.
        for (uint256 i = 0; i < len;) {
            verify(_userAddresses[i]);

            // Increment i by 1.
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Unverifies the user. Callable only by the king and the admin.
    /// @param _userAddress The user's address.
    function unverifyUser(address _userAddress) external onlyRegistered(_userAddress) onlyKingAndAdmin {
        // Call the internal `unverify` function.
        unverify(_userAddress);
    }

    /// @notice Unverifies many users. Callable only by the king and the admin.
    /// @param _userAddresses The users' addresses.
    function unverifyManyUsers(address[] memory _userAddresses) external onlyKingAndAdmin {
        // Assign len.
        uint256 len = _userAddresses.length;

        // Loop through the array and unverify users.
        for (uint256 i = 0; i < len;) {
            unverify(_userAddresses[i]);

            // Increment i by 1.
            unchecked {
                ++i;
            }
        }
    }

    // ----------------------------------------------------- King and Admin's External Read Functions ------------------------------------------
    /// @notice Returns the user's data.
    /// @param _userAddress The user's address.
    /// @return The user's stored data.
    function getUserData(address _userAddress) external view onlyKingAndAdmin returns (User memory) {
        return userData[_userAddress];
    }

    /// @notice Returns registered users addresses. Callable only by the king and the admin.
    /// @param _startId The Id of the first user.
    /// @param _endId The Id of the last user.
    /// @return _result Addresses of the registered user.
    function getRegisteredUsers(uint64 _startId, uint64 _endId)
        external
        view
        onlyKingAndAdmin
        returns (address[] memory _result)
    {
        // Return the internal `registered` function.
        return registered(_startId, _endId);
    }

    /// @notice Returns verified users addresses. Callable only by the king and the admin.
    /// @param _startId The Id of the first user.
    /// @param _endId The Id of the last user.
    /// @return _result Addresses of the verified users.
    function getVerifiedUsers(uint64 _startId, uint64 _endId)
        external
        view
        onlyKingAndAdmin
        returns (address[] memory _result)
    {
        // Return the internal `verified` function.
        return verified(_startId, _endId);
    }
}
