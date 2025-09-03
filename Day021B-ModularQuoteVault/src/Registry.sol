// SPDX-License-Identifier: MIT
/// @title Registry contract for ModularQuoteVault.
/// @author MichealKing (@BuildsWithKing).
/// @notice Created on 22nd of Aug, 2025.

/**
 * @notice Stores, updates,
 * retrieves and deletes user's name,
 * age, gender, email address, and skill.
 */

/// @dev Owned by the contract deployer.

pragma solidity ^0.8.30;

/// @notice Imports Utils file.
import {Utils} from "./Utils.sol";

abstract contract Registry is Utils {
    // ----------------------------- Users external write Functions ----------------------------------

    /// @notice Stores users data.
    /// @param _fullName The user's name.
    /// @param _age The user's age.
    /// @param _gender The user's gender.
    /// @param _email The user's email.
    /// @param _skill The user's skill.
    function store(
        string calldata _fullName,
        uint8 _age,
        Gender _gender,
        string calldata _email,
        string calldata _skill
    ) internal isActive validateUser(_fullName, _age, _gender, _email, _skill) mustNotBeRegistered {
        // Store user input.
        userData[msg.sender] = Data({
            age: _age,
            isRegistered: true,
            timestamp: block.timestamp,
            gender: _gender,
            fullName: _fullName,
            email: _email,
            skill: _skill
        });

        // Add user address to array of registered user.
        userAddresses.push(msg.sender);

        // Store postion.
        userIndex[msg.sender] = userAddresses.length - 1;

        // Record user.
        unchecked {
            userCount++;
        }

        // Records total registered.
        unchecked {
            totalUsers++;
        }

        // Emit NewUser event.
        emit NewUser(msg.sender, _fullName, _age, _gender, _skill);
    }

    /// @notice Update's user's name.
    /// @param _newFullName The user's new full name.
    function updateFullName(string calldata _newFullName) internal isActive mustBeRegistered {
        // Ensure user's full name is not empty.
        if (bytes(_newFullName).length == 0) revert EmptyName();

        // Prevent user from updating full name with previous full name.
        if (keccak256(bytes(userData[msg.sender].fullName)) == keccak256(bytes(_newFullName))) {
            revert SameName();
        }

        // Update user's full name.
        userData[msg.sender].fullName = _newFullName;

        // Emit event FullNameUpdated.
        emit FullNameUpdated(msg.sender, _newFullName);
    }

    /// @notice Updates user's age.
    /// @param _newAge The user's new age.
    function updateAge(uint8 _newAge) internal isActive mustBeRegistered {
        // Ensure user's new age is not zero.
        if (_newAge == 0) revert ZeroAge();

        // Ensure user's new age is not above 120.
        if (_newAge > MAX_AGE) revert Above120();

        // Prevent user from updating with same age.
        if (userData[msg.sender].age == _newAge) {
            revert SameAge();
        }

        // Update user age.
        userData[msg.sender].age = _newAge;

        // Emit event AgeUpdated.
        emit AgeUpdated(msg.sender, _newAge);
    }

    /// @notice Updates User's Gender.
    /// @param _newGender The user's new gender.
    function updateGender(Gender _newGender) internal isActive mustBeRegistered {
        // Ensure User selects a gender.
        if (_newGender == Gender.Unset) {
            revert UnsetGender();
        }

        // Prevent user from updating same gender.
        if (userData[msg.sender].gender == _newGender) {
            revert SameGender();
        }

        // Update user gender.
        userData[msg.sender].gender = _newGender;

        // Emit event GenderUpdated.
        emit GenderUpdated(msg.sender, _newGender);
    }

    /// @notice Updates user's Email.
    /// @param _newEmail The user's new email.
    function updateEmail(string calldata _newEmail) internal isActive mustBeRegistered {
        // Ensure user's email is not empty.
        if (bytes(_newEmail).length == 0) {
            revert EmptyEmail();
        }

        if (keccak256(bytes(userData[msg.sender].email)) == keccak256(bytes(_newEmail))) {
            revert SameEmail();
        }

        // Update user email.
        userData[msg.sender].email = _newEmail;

        // Emit event EmailUpdated.
        emit EmailUpdated(msg.sender, _newEmail);
    }

    /// @notice Updates user's skill.
    /// @param _newSkill The user's new skill.
    function updateSkill(string calldata _newSkill) internal isActive mustBeRegistered {
        // Ensure user's skill is not empty.
        if (bytes(_newSkill).length == 0) {
            revert EmptySkill();
        }

        // Prevent user from updating same skill.
        if (keccak256(bytes(userData[msg.sender].skill)) == keccak256(bytes(_newSkill))) {
            revert SameSkill();
        }

        // Update user skill.
        userData[msg.sender].skill = _newSkill;

        // Emit event SkillUpdated.
        emit SkillUpdated(msg.sender, _newSkill);
    }

    /// @notice Deletes user's data.
    function deleteData() internal isActive mustBeRegistered {
        // Call _deleteUser (internal helper function).
        _deleteUser(msg.sender);

        // Call _clearUserQuotes (internal helper function).
        _clearUserQuotes(msg.sender);

        // Emit UserDataDeleted.
        emit UserDataDeleted(msg.sender, msg.sender);
    }

    // ------------------------------ Owner's external read functions ----------------------------------

    /// @notice Only owner can returns users data.
    /// @param _userAddress The user's address.
    /// @return User's name, age, gender, email address, skill.
    function getUserDataAsOwner(address _userAddress)
        internal
        view
        onlyOwner
        userMustBeRegistered(_userAddress)
        returns (Data memory)
    {
        // Return data.
        return userData[_userAddress];
    }

    /// @notice Returns addresses of registered user.
    /// @return result Array of userAddresses.
    function getUsersAddress(uint256 _offset, uint256 _limit)
        internal
        view
        onlyOwner
        returns (address[] memory result)
    {
        // Store total number of addresses in totalNo.
        uint256 totalNo = userAddresses.length;

        // Return empty array, if _offset > totalNo.
        if (_offset > totalNo) {
            return new address[](0);
        }

        // Calculate where to stop (end).
        uint256 end = _offset + _limit;

        // Prevent length from exceeding total number of addresses.
        if (end > totalNo) end = totalNo;

        // Compute numbers of elements to be returned.
        uint256 len = end - _offset;

        //Allocate a new array "result" for the returned length.
        result = new address[](len);

        // Loop through the range.
        for (uint256 i; i < len; i++) {
            /* Copy addresses from big storage array (userAddress)
            into result (new memory array). 
            */
            result[i] = userAddresses[_offset + i];
        }
    }
}
