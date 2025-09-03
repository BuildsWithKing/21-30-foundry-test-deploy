//SPDX-License-Identifier: MIT

/// @title Utils (Utility contract for ModularQuoteVault).
/// @author MichealKing (@BuildsWithKing).

/* @notice  Utility contract for ModularQuoteVault.  

    created on 22nd of Aug, 2025.
*/

pragma solidity ^0.8.30;

/// @notice Imports Types and ReentrancyGuard.
import {Types} from "./Types.sol";
import {ReentrancyGuard} from "lib/buildswithking-security/contracts/security/ReentrancyGuard.sol";

contract Utils is Types, ReentrancyGuard {
    // ------------------------------ Custom Errors ---------------------------------------------------

    /// @dev Thrown when a user tries to perform only owner operation.
    error Unauthorized();

    /// @dev Thrown when user/owner tries to perform operation while contract is not active.
    error Inactive();

    /// @dev Thrown when an existing user tries to register.
    error AlreadyRegistered();

    // --------------------------------------------- Registry Custom Errors -------------------------------

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

    // ------------------------------------------------- QuoteHub Custom Errors ------------------------------------

    /// @dev Thrown for blank author field.
    error EmptyAuthor();

    /// @dev Thrown for blank description field.
    error EmptyDescription();

    /// @dev Thrown for blank category field.
    error EmptyCategory();

    /// @dev Thrown for blank source field.
    error EmptySource();

    /// @dev Thrown for blank note field.
    error EmptyNote();

    /// @dev Thrown for non-existing index.
    error OutOfBounds();

    /// @dev Thrown for same author.
    error SameAuthor();

    /// @dev Thrown for same quote.
    error SameQuote();

    /// @dev Thrown for same category.
    error SameCategory();

    /// @dev Thrown for same source.
    error SameSource();

    /// @dev Thrown for same note.
    error SameNote();

    /// @dev Thrown when non-registered user tries to perform an operation.
    error NotRegistered();

    /// @dev Thrown when contract deployer tries to activate already active contract.
    error AlreadyActive();

    /// @dev Thrown when contract deployer tries to deactivate inactive contract.
    error AlreadyInactive();

    /// @dev Thrown when owner tries to transfer ownership to contract address or zero address.
    error InvalidAddress();

    /// @dev Thrown when owner tries to transfer ownership to self.
    error SameOwner();

    /// @dev Thrown when owner tries to send ETH while balance is zero.
    error NoFunds();

    /// @dev Thrown when ethAmount is greater than zero.
    error BalanceTooLow();

    /// @dev Thrown when owner's withdrawal fails.
    error WithdrawFailed();

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

    /// @notice Emits NewQuoteAdded.
    /// @param userAddress The user's address.
    /// @param author The quote's author.
    /// @param description The quote.
    /// @param category The quote's category.
    /// @param source The quote's source.
    event NewQuoteAdded(address indexed userAddress, string author, string description, string category, string source);

    /// @notice Emits AuthorUpdated.
    /// @param userAddress The user's address.
    /// @param _quoteIndex The quote's Index number.
    /// @param author The quote's new author.
    event AuthorUpdated(address indexed userAddress, uint256 _quoteIndex, string author);

    /// @notice Emits DescriptionUpdated.
    /// @param userAddress The user's address.
    /// @param _quoteIndex The quote's Index number.
    /// @param description The new quote.
    event DescriptionUpdated(address indexed userAddress, uint256 _quoteIndex, string description);

    /// @notice Emits CategoryUpdated.
    /// @param userAddress The user's address.
    /// @param _quoteIndex The quote's Index number.
    /// @param category The quote's new category.
    event CategoryUpdated(address indexed userAddress, uint256 _quoteIndex, string category);

    /// @notice Emits SourceUpdated.
    /// @param userAddress The user's address.
    /// @param _quoteIndex The quote's Index number.
    /// @param source The quote's new source.
    event SourceUpdated(address indexed userAddress, uint256 _quoteIndex, string source);

    /// @notice Emits UserNoteUpdated.
    /// @param userAddress The user's address.
    /// @param _quoteIndex The quote's Index number.
    /// @param note The user's new note.
    event UserNoteUpdated(address indexed userAddress, uint256 _quoteIndex, string note);

    /// @notice Emits QuoteDeleted.
    /// @param userAddress The user's address.
    /// @param quoteIndex The quote's index number.
    event QuoteDeleted(address indexed userAddress, uint256 quoteIndex);

    /// @notice Emits UserQuoteDeleted.
    /// @param ownerAddress The owner's address.
    /// @param userAddress The user's address.
    /// @param quoteIndex The quote's index number.
    event UserQuoteDeleted(address indexed ownerAddress, address indexed userAddress, uint256 quoteIndex);

    /// @notice Emits OwnershipTransferred.
    /// @param oldOwnerAddress The old owner's address.
    /// @param newOwnerAddress The new owner's address.
    event OwnershipTransferred(address indexed oldOwnerAddress, address indexed newOwnerAddress);

    /// @notice Emits OwnershipRenounced.
    /// @param ownerAddress The owner's address.
    /// @param zeroAddress The zero address.
    event OwnershipRenounced(address indexed ownerAddress, address indexed zeroAddress);

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
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    /// @dev Restricts Access while contract is not active.
    modifier isActive() {
        if (state == ContractState.NotActive) revert Inactive();
        _;
    }

    /// @dev Validates users.
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
        string memory _skill
    ) {
        // Ensure user's full name is not empty.
        if (bytes(_fullName).length == 0) {
            revert EmptyName();
        }

        // Ensure age is not above 120.
        if (_age > MAX_AGE) {
            revert Above120();
        }

        // Ensure user's age is not zero.
        if (_age == 0) {
            revert ZeroAge();
        }

        // Ensure User selects a gender.
        if (_gender == Gender.Unset) {
            revert UnsetGender();
        }

        // Ensure user's email address is not empty.
        if (bytes(_email).length == 0) {
            revert EmptyEmail();
        }

        // Ensure user's skill is not empty.
        if (bytes(_skill).length == 0) {
            revert EmptySkill();
        }
        _;
    }

    /// @dev Validates quotes input.
    /// @param _author The quote's author.
    /// @param _description The quote.
    /// @param _category The quote's category.
    /// @param _source The quote's source.
    /// @param _personalNote The user's note.
    modifier validateQuoteInput(
        string memory _author,
        string memory _description,
        string memory _category,
        string memory _source,
        string memory _personalNote
    ) {
        // Revert "EmptyAuthor" for blank author field.
        if (bytes(_author).length == 0) {
            revert EmptyAuthor();
        }

        // Revert "EmptyDescription" for blank description field.
        if (bytes(_description).length == 0) {
            revert EmptyDescription();
        }

        // Revert "EmptyCategory" for blank category field.
        if (bytes(_category).length == 0) {
            revert EmptyCategory();
        }

        // Revert "EmptySource" for blank source field.
        if (bytes(_source).length == 0) {
            revert EmptySource();
        }

        // Revert "EmptyNote" for blank note field.
        if (bytes(_personalNote).length == 0) {
            revert EmptyNote();
        }
        _;
    }

    /// @dev Validates user's quote index.
    /// @param _quoteIndex The user's quote index.
    /// @param _userAddress The user's address.
    modifier validateIndex(uint256 _quoteIndex, address _userAddress) {
        // Read through user's quote.
        Quote[] storage quotes = userQuotes[_userAddress];

        // Revert with "OutOfBounds" if index exceed quote array length.
        if (_quoteIndex >= quotes.length) revert OutOfBounds();
        _;
    }

    /// @dev Ensures user has completed registration.
    modifier mustBeRegistered() {
        // Prevent non-registered user from storing, updating deleting quotes, etc.
        if (!userData[msg.sender].isRegistered) {
            revert NotRegistered();
        }
        _;
    }

    /// @dev Ensures user is registered.
    modifier userMustBeRegistered(address _userAddress) {
        // Revert with message when owner tries deleting or accessing non-registered user data.
        if (!userData[_userAddress].isRegistered) {
            revert NotRegistered();
        }
        _;
    }

    /// @dev Ensure user haven't registered.
    modifier mustNotBeRegistered() {
        // Prevent existing user from reregistering.
        if (userData[msg.sender].isRegistered) {
            revert AlreadyRegistered();
        }
        _;
    }
    // ------------------------------ Internal helper function --------------------------------------------

    /// @notice Helper function for deleteMyData & deleteUserData.
    /// @param _userAddress The user's address.
    function _deleteUser(address _userAddress) internal {
        // Get user position.
        uint256 index = userIndex[_userAddress];

        // Get last index on userAddresses array.
        uint256 lastIndex = userAddresses.length - 1;

        // Swap lastIndex and update index.
        if (index != lastIndex) {
            address lastUser = userAddresses[lastIndex];
            userAddresses[index] = lastUser;
            userIndex[lastUser] = index;
        }

        // Remove array's last element.
        userAddresses.pop();

        // Delete data of user's address
        delete userData[_userAddress];

        // Delete the user's index.
        delete userIndex[_userAddress];

        // Deduct one from userCount.
        unchecked {
            userCount--;
        }
    }

    /// @notice Helper function for deleteMyQuote and deleteUserQuote.
    /// @param _quoteIndex The quote index.
    /// @param _userAddress The user's address.
    function _deleteQuote(uint256 _quoteIndex, address _userAddress) internal {
        // Read through user's quotes.
        Quote[] storage quotes = userQuotes[_userAddress];

        // Assign last quotes.
        uint256 last = quotes.length - 1;

        // Shift next element to last position.
        if (_quoteIndex != last) {
            quotes[_quoteIndex] = quotes[last];
        }

        // Remove array's last element.
        quotes.pop();

        // Subtract one from ids.
        unchecked {
            id--;
        }
    }

    /// @notice Clears users quotes array.
    /// @param _userAddress The user's address.
    function _clearUserQuotes(address _userAddress) internal {
        uint256 count = userQuotes[_userAddress].length;

        if (count > 0) {
            // Clear the whole array.
            delete userQuotes[_userAddress];

            // Adjust global id counter.
            unchecked {
                if (id >= count) {
                    id -= count;
                } else {
                    // Safety reset.
                    id = 0;
                }
            }
        }
    }

    // ------------------------------ External read functions ---------------------------------------------

    /// @notice Returns Contract current state.
    /// @return Bool "true" or "false".
    function isContractActive() external view returns (bool) {
        // Return bool True or False.
        return state == ContractState.Active;
    }

    // -----------------------------  Owner's external write functions -------------------------------------

    /// @notice Only contract deployer can activate contract.
    function activateContract() external onlyOwner {
        // Revert with message, if contract is already active.
        if (state == ContractState.Active) revert AlreadyActive();

        // Set contract state as Active.
        state = ContractState.Active;

        // Emit event ContractActivated.
        emit ContractActivated(owner);
    }

    /// @notice Only contract deployer can deactivate contract.
    function deactivateContract() external onlyOwner {
        // Revert with message, if contract is already inactive.
        if (state == ContractState.NotActive) revert AlreadyInactive();

        // Set contract state as NotActive.
        state = ContractState.NotActive;

        // Emit event ContractDeactivated.
        emit ContractDeactivated(owner);
    }

    /// @notice Transfers ownership.
    /// @param _newOwnerAddress The new owner address.
    function transferOwnership(address _newOwnerAddress) external onlyOwner nonReentrant {
        // Revert "InvalidAddress" if new owner address is zero address or contract address.
        if (_newOwnerAddress == address(0) || (_newOwnerAddress == address(this))) {
            revert InvalidAddress();
        }

        // Revert "SameOwner" if newOwnerAddress is the current owner.
        if (owner == _newOwnerAddress) {
            revert SameOwner();
        }

        // Emit event OwnershipTransferred.
        emit OwnershipTransferred(owner, _newOwnerAddress);

        // Set newOwnerAddress as new owner.
        owner = _newOwnerAddress;
    }

    /// @notice Only owner can renounce ownership.
    function renounceOwnership() external onlyOwner isActive {
        // Emit event OwnershipRenounced.
        emit OwnershipRenounced(owner, address(0));

        // Assign zero address as new owner.
        owner = address(0);
    }

    /// @notice Only owner can send ETH.
    /// @param _userAddress The user's address.
    /// @param _ethAmount The amount of ETH.
    function sendETH(address _userAddress, uint256 _ethAmount) external onlyOwner isActive nonReentrant {
        // Record contract balance.
        uint256 balance = address(this).balance;

        // Revert "NoFunds" if contract balance is equal to zero.
        if (balance == 0) revert NoFunds();

        // Revert "BalanceTooLow" if ethAmount is greater than balance.
        if (_ethAmount > balance) revert BalanceTooLow();

        // Fund address.
        (bool success,) = payable(_userAddress).call{value: _ethAmount}("");

        // Revert "WithdrawFailed" if withdrawal fails.
        if (!success) {
            revert WithdrawFailed();
        }

        // Emit event EthSent.
        emit EthSent(_userAddress, _ethAmount);
    }

    // ---------------------------- Receive & fallback external functions -------------------------------

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
