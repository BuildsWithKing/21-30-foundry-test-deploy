//SPDX-License-Identifier: MIT

/// @title Utils for AdvancedUserStorage.
/// @author MichealKing (@BuildsWithKing).
/// @created on 14th of Aug, 2025.

/// @notice Utility contract for advanced user storage. 

pragma solidity ^0.8.30;

/// @notice Imports Types.sol. 
import {Types} from "./Types.sol";

contract Utils is Types {

// ------------------------------ Custom errors ------------------------------------------

/// @dev Thrown when a user tries to perform only owner operation.
error Unauthorized();

/// @dev Thrown when user/owner tries to perform operation while contract is not active. 
error Inactive();

/// @dev Thrown when an existing user tries to register.
error AlreadyRegistered();

/// @dev Thrown when user tries to update full name with previous full name. 
error SameName();

/// @dev Thrown when user tries to update age with previous age. 
error SameAge();

/// @dev Thrown when user tries to update gender with previous gender. 
error SameGender();

/// @dev Thrown when user tries to update email with previous email. 
error SameEmail();

/// @dev Thrown when user tries to update skill with previous skill.
error SameSkill();

/// @dev Thrown for blank name field.
error EmptyName();

/// @dev Thrown for blank age. 
error ZeroAge();

/// @dev Thrown for age above 120. 
error Above120();

/// @dev Thrown for blank gender field.
error UnsetGender();

/// @dev Thrown for blank email address field.
error EmptyEmail();

/// @dev Thrown for blank skill field.
error EmptySkill();

/// @dev Thrown when non-registered user tries to perform an operation.
error NotRegistered();

/// @dev Thrown when contract deployer tries to activate already active contract. 
error AlreadyActive();

/// @dev Thrown when contract deployer tries to deactivate inactive contract. 
error AlreadyInactive();

/// @dev Thrown when owner tries to send ETH while balance is zero.
error NoFunds();

/// @dev Thrown when ethAmount is greater than zero.
error BalanceTooLow();

/// @dev Thrown when owner's withdrawal fails.
error WithdrawFailed();

// --------------------------- Variable assignment ----------------------------------------------

    /// @notice Contract deployer's address.
    address immutable owner;

    /// @notice Records contract state. 
    ContractState internal state;

     /// @notice Users max age. 
    uint8 constant MAX_AGE = 120;

    /// @notice Records total registered users. 
    uint256 internal userCount;

    /// @dev Maps user's address to index. 
    mapping(address => uint256) internal userIndex;

    /// @notice Records users address. 
    address[] internal userAddresses;

    /// @dev Maps user's address to their data.
    mapping(address => Data) internal userData;

// ------------------------------------- Events --------------------------------------------------

    /// @notice Emits NewUser.
    /// @param userAddress New user address.
    /// @param name New user name.
    /// @param age New user age.
    /// @param gender New user gender.
    /// @param skill New user skill.
    event NewUser(address indexed userAddress, string name, uint8 age, Gender gender, string skill);

    /// @notice Emits FullNameUpdated.
    /// @param userAddress The user's address.
    /// @param newFullName The user's new name.
    event FullNameUpdated(address indexed userAddress, string newFullName);
    
    /// @notice Emits AgeUpdated. 
    /// @param userAddress The user's address.
    /// @param newAge The user's new age.
    event AgeUpdated(address indexed userAddress, uint8 newAge);
    
    /// @notice Emits GenderUpdated. 
    /// @param userAddress The user's address.
    /// @param newGender The user's new gender.
    event GenderUpdated(address indexed userAddress, Gender newGender);

    /// @notice Emits EmailUpdated. 
    /// @param userAddress The user's address.
    /// @param newEmail The user's new Email. 
    event EmailUpdated(address indexed userAddress, string newEmail);

    /// @notice Emits SkillUpdated. 
    /// @param userAddress The user's address.
    /// @param newSkill The user's new skill.
    event SkillUpdated(address indexed userAddress, string newSkill);

    /// @notice Emits UserDataDeleted.
    /// @param deletedBy The address which deleted the data (owner / user)
    /// @param deletedUser The user's address.
    event UserDataDeleted(address indexed deletedBy, address indexed deletedUser);

    /// @notice Emits EthSent.
    /// @param userAddress The user's address.
    /// @param ethAmount Amount of ETH sent. 
    event EthSent(address indexed userAddress, uint256 indexed ethAmount);

    /// @notice Emits ContractActivated. 
    /// @param ownerAddress The owner's address. 
    event ContractActivated(address indexed ownerAddress);
    
    /// @notice Emits ContractDeactivated.  
    /// @param ownerAddress The owner's address. 
    event ContractDeactivated(address indexed ownerAddress);

    /// @notice Emits EthReceived.
    /// @param senderAddress The sender's address.
    /// @param ethAmount The amount of ETH received.
    event EthReceived(address indexed senderAddress, uint256 ethAmount);

// ------------------------------ Constructor ------------------------------------------------------

    /// @notice Sets contract deployer as owner.
    constructor() {
        owner = msg.sender;

        // Set Contract state to active once deployed. 
        state = ContractState.Active;
    }

// -------------------------------- Modifiers ----------------------------------------------------

   /// @dev Restricts access to only contract deployer.
    modifier onlyOwner() {
        if(msg.sender != owner) revert Unauthorized();
        _;
    }

    /// @notice Restricts Access while contract is not active. 
    modifier isActive() {
        if(state == ContractState.NotActive) revert Inactive();
        _;
    }

    /// @notice Validates users. 
    /// @param _fullName The user's full name. 
    /// @param _age The user's age.
    /// @param _gender The user's gender. 
    /// @param _email The user's email.
    /// @param _skill The user's skill. 
    modifier validateUser(
        string memory _fullName,
        uint8 _age,
        Gender _gender, 
        string memory _email, 
        string memory _skill) {

        // Ensure user's full name is not empty. 
        if(bytes(_fullName).length == 0) revert EmptyName();

        // Ensure user's age is not zero. 
        if(_age == 0) revert ZeroAge();

        // Ensure age is not above 120. 
        if(_age > MAX_AGE) revert Above120();

        // Ensure User selects a gender. 
        if(_gender == Gender.Unset) revert UnsetGender();

        // Ensure user's email address is not empty. 
        if(bytes(_email).length == 0) revert EmptyEmail();

        // Ensure user's skill is not empty. 
        if(bytes(_skill).length == 0) revert EmptySkill();

            _;
    }

    /// @notice Ensures only registered users has access. 
    modifier mustBeRegistered() {
        // Prevent non-registered user from updating data. 
        if(!userData[msg.sender].isRegistered) revert NotRegistered();
        _;
    }

      /// @notice Ensures user is registered. 
    modifier userMustBeRegistered(address _userAddress) {

        // Revert with message when owner tries deleting or accessing non-registered user data.  
        if(!userData[_userAddress].isRegistered) revert NotRegistered();
        _;
    }

    /// @notice Ensure user havent registered. 
    modifier mustNotBeRegistered() {
        // Prevent existing user from reregistering. 
        if(userData[msg.sender].isRegistered) revert AlreadyRegistered();
        _;
    }
// ------------------------------ Internal helper function --------------------------------------------

    /// @notice Helper function for deleteMyData & deleteUserData. 
    /// @param _userAddress The user's address. 
    function _deleteUser(address _userAddress) internal {

        // Get user position. 
        uint256 index = userIndex[_userAddress];

        // Get last index on userAddresses array.
        uint256 lastIndex = userAddresses.length;

        // Get last user. 
        address lastUser = userAddresses[lastIndex - 1];

        // Move last element into deleted spot. 
        userAddresses[index -1] = lastUser;

        // Set last User index. 
        userIndex[lastUser] = index;

        // Remove last element. 
        userAddresses.pop();

        // Delete data of user's address
        delete userData[_userAddress];

        // Reset user's index to zero. 
        userIndex[_userAddress] = 0;

        // Deduct one from userCount. 
        unchecked {
            userCount--;
        }
    }

// ------------------------------ External read functions ---------------------------------------------

    /// @notice Returns Contract current state. 
    /// @return Bool "true" or "false". 
    function isContractActive() external view returns(bool) {

        // Return bool True or False. 
        return state == ContractState.Active;
    }

// -----------------------------  Owner's external write functions ------------------------------------

    /// @notice Only contract deployer can activate contract. 
    function activateContract() external onlyOwner {
        
        // Revert with message, if contract is already active. 
        if(state == ContractState.Active) revert AlreadyActive();

        // Set contract state as Active.
        state = ContractState.Active;

        // Emit event ContractActivated. 
        emit ContractActivated(owner);
    }

    /// @notice Only contract deployer can deactivate contract. 
    function deactivateContract() external onlyOwner {

         // Revert with message, if contract is already inactive. 
        if(state == ContractState.NotActive) revert AlreadyInactive();

        // Set contract state as NotActive. 
        state = ContractState.NotActive;

        // Emit event ContractDeactivated. 
        emit ContractDeactivated(owner);
    }

    /// @notice Only owner can send ETH.
    /// @notice _userAddress The user's address. 
    /// @notice _ethAmount The amount of ETH. 
    function withdrawETH(address _userAddress, uint256 _ethAmount) external onlyOwner isActive {

        // Record contract balance. 
        uint256 balance = address(this).balance;

        // Revert with message if contract balance is equal to zero. 
        if(balance == 0) revert NoFunds();

        // Revert with message if ethAmount is greater than balance. 
        if(_ethAmount > balance) revert BalanceTooLow();

        // Fund address. 
        (bool success,) = payable(_userAddress).call{value: _ethAmount}("");

        // Revert message if withdrawal fails. 
        if(!success) {

            revert WithdrawFailed();
        }

        // Emit event EthWithdrawn. 
        emit EthSent(_userAddress, _ethAmount);
    }

// ---------------------------- Receive & fallback external functions ------------------------------

    /// @notice Handles ETH transfer with no calldata.
    receive() external payable {

        // Emits event EthReceived.
        emit EthReceived(msg.sender, msg.value);
    }

    /// @notice Handles ETH transfer with calldata.
    fallback() external payable {

        // Emits event EthReceived. 
        emit EthReceived(msg.sender, msg.value);
    }
}