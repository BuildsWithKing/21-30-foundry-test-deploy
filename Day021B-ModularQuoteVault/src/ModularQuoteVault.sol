// SPDX-License-Identifier: MIT

/// @author Michealking(@BuildsWithKing).
/// @title ModularQuoteVault.
/// @notice Created on 22nd Aug, 2025.

/**
 * @notice Stores and manages users personal data, and favorites qoutes.
 */
pragma solidity ^0.8.30;

/// @notice Imports QuoteHub and Registry.
import {QuoteHub} from "./QuoteHub.sol";
import {Registry} from "./Registry.sol";

contract ModularQuoteVault is QuoteHub, Registry {
    // ------------------------------------- Users External Write Functions -----------------------------------

    /// @notice Stores users data.
    /// @param _fullName The user's name.
    /// @param _age The user's age.
    /// @param _gender The user's gender.
    /// @param _email The user's email.
    /// @param _skill The user's skill.
    function register(
        string calldata _fullName,
        uint8 _age,
        Gender _gender,
        string calldata _email,
        string calldata _skill
    ) external isActive validateUser(_fullName, _age, _gender, _email, _skill) mustNotBeRegistered {
        // Call internal function.
        store(_fullName, _age, _gender, _email, _skill);
    }

    /// @notice Update's user's name.
    /// @param _newFullName The user's new full name.
    function updateMyFullName(string calldata _newFullName) external isActive mustBeRegistered {
        // Call internal function.
        updateFullName(_newFullName);
    }

    /// @notice Updates user's age.
    /// @param _newAge The user's new age.
    function updateMyAge(uint8 _newAge) external isActive mustBeRegistered {
        // Call internal function.
        updateAge(_newAge);
    }

    /// @notice Updates User's Gender.
    /// @param _newGender The user's new gender.
    function updateMyGender(Gender _newGender) external isActive mustBeRegistered {
        // Call internal function.
        updateGender(_newGender);
    }

    /// @notice Updates user's Email.
    /// @param _newEmail The user's new email.
    function updateMyEmail(string calldata _newEmail) external isActive mustBeRegistered {
        // Call internal function.
        updateEmail(_newEmail);
    }

    /// @notice Updates user's skill.
    /// @param _newSkill The user's new skill.
    function updateMySkill(string calldata _newSkill) external isActive mustBeRegistered {
        // Call internal function.
        updateSkill(_newSkill);
    }

    /// @notice Deletes user's data.
    function deleteMyData() external isActive mustBeRegistered {
        // Call internal function.
        deleteData();
    }

    /// @notice Stores user's quotes.
    /// @param _author The quote's author.
    /// @param _description The quote.
    /// @param _category The quote's category.
    /// @param _source The quote's source.
    /// @param _personalNote The user's personal note.
    function storeQuote(
        string calldata _author,
        string calldata _description,
        string calldata _category,
        string calldata _source,
        string calldata _personalNote
    ) external isActive mustBeRegistered validateQuoteInput(_author, _description, _category, _source, _personalNote) {
        // Call internal function.
        addQuote(_author, _description, _category, _source, _personalNote);
    }

    /// @notice Updates author.
    /// @param _quoteIndex The quote's Index number.
    /// @param _newAuthor The quote's new author.
    function updateQuoteAuthor(uint256 _quoteIndex, string calldata _newAuthor) external isActive mustBeRegistered {
        // Call internal function.
        updateAuthor(_quoteIndex, _newAuthor);
    }

    /// @notice Updates description.
    /// @param _quoteIndex The quote's Index number.
    /// @param _newDescription The new quote.
    function updateQuoteDescription(uint256 _quoteIndex, string calldata _newDescription)
        external
        isActive
        mustBeRegistered
    {
        // Call internal function.
        updateDescription(_quoteIndex, _newDescription);
    }

    /// @notice Updates category.
    /// @param _quoteIndex The quote's Index number.
    /// @param _newCategory The quote's new category.
    function updateQuoteCategory(uint256 _quoteIndex, string calldata _newCategory)
        external
        isActive
        mustBeRegistered
    {
        // Call internal function.
        updateCategory(_quoteIndex, _newCategory);
    }

    /// @notice Updates source.
    /// @param _quoteIndex The quote's Index number.
    /// @param _newSource The quote's new source.
    function updateQuoteSource(uint256 _quoteIndex, string calldata _newSource) external isActive mustBeRegistered {
        // Call internal function.
        updateSource(_quoteIndex, _newSource);
    }

    /// @notice Updates PersonalNote.
    /// @param _quoteIndex The quote's Index number.
    /// @param _newPersonalNote The user's new note.
    function updateQuoteNote(uint256 _quoteIndex, string calldata _newPersonalNote)
        external
        isActive
        mustBeRegistered
    {
        // Call internal function.
        updatePersonalNote(_quoteIndex, _newPersonalNote);
    }

    /// @notice Deletes users Quote.
    /// @param _quoteIndex The quote's Index number.
    function deleteMyQuote(uint256 _quoteIndex) external isActive mustBeRegistered {
        // Call internal function.
        deleteQuote(_quoteIndex);
    }

    // --------------------------------- Users External Read Functions ---------------------------------------

    /// @notice Returns user's data.
    /// @return user stored data.
    function getMyData() external view mustBeRegistered returns (Data memory) {
        return userData[msg.sender];
    }

    /// @notice Returns user's skill.
    /// @return user's skill.
    function getMySkill() external view mustBeRegistered returns (string memory) {
        return userData[msg.sender].skill;
    }

    /// @notice Returns User's Gender.
    /// @return Male,Female or Unset.
    function getMyGender() external view returns (string memory) {
        // Return `Male` if user's gender is male.
        if (userData[msg.sender].gender == Gender.Male) return "Male";

        // Return `Female` if user's gender is female.
        if (userData[msg.sender].gender == Gender.Female) return "Female";

        // Return `Unset` if user's gender is blank.
        return "Unset";
    }

    /// @notice User's can check their registration status.
    /// @return True or false.
    function checkMyRegistrationStatus() external view returns (bool) {
        return userData[msg.sender].isRegistered;
    }

    /// @notice Checks users registration status.
    function checkIfRegistered(address _userAddress) external view returns (bool) {
        return userData[_userAddress].isRegistered;
    }

    /// @notice Returns user's quote.
    /// @return quote of the quote index.
    function getMyQuote(uint256 _quoteIndex)
        external
        view
        mustBeRegistered
        validateIndex(_quoteIndex, msg.sender)
        returns (Quote memory)
    {
        // Return user's id quote.
        return userQuotes[msg.sender][_quoteIndex];
    }

    /// @notice Returns user's stored quotes.
    /// @return result Array of user's stored quotes.
    function getAllMyQuotes(uint256 _offset, uint256 _limit)
        external
        view
        mustBeRegistered
        returns (Quote[] memory result)
    {
        // Return internal function.
        return getMyQuotes(_offset, _limit);
    }

    /// @notice Returns Total registered user.
    /// @return Total users registered.
    function getTotalRegisteredUsers() external view returns (uint256) {
        return totalUsers;
    }

    /// @notice Returns Total active users.
    /// @return Active user's count.
    function getActiveUserCount() external view returns (uint256) {
        // Return active user's count.
        return userCount;
    }

    /// @notice Returns owner's address.
    /// @return The owner's address.
    function getOwner() external view returns (address) {
        // Return owner's address.
        return owner;
    }

    /// @notice Returns Total stored quotes.
    /// @return Total quotes stored.
    function getTotalQuotes() external view returns (uint256) {
        // Return total quotes stored.
        return totalQuotes;
    }

    /// @notice Returns Total active quotes.
    /// @return Active quote count.
    function getActiveQuoteCount() external view returns (uint256) {
        // Return active quote count.
        return id;
    }

    // ---------------------------------- Owner's External Write Functions -------------------------------------

    /// @notice Only owner can delete users data.
    /// @param _userAddress The user's address.
    function deleteUserData(address _userAddress) external onlyOwner isActive userMustBeRegistered(_userAddress) {
        // Call deleteUser (internal helper function).
        _deleteUser(_userAddress);

        // Call _clearUserQuotes (internal helper function).
        _clearUserQuotes(_userAddress);

        // Emit UserDataDeleted.
        emit UserDataDeleted(owner, _userAddress);
    }

    /// @notice Only owner can delete users data.
    /// @param _quoteIndex The quote index number.
    /// @param _userAddress The user's address.
    function deleteUserQuote(uint256 _quoteIndex, address _userAddress)
        external
        onlyOwner
        isActive
        userMustBeRegistered(_userAddress)
        validateIndex(_quoteIndex, _userAddress)
    {
        // Call internal function.
        deleteUserQuoteAsOwner(_quoteIndex, _userAddress);
    }

    /// @notice Only owner can return user's quotes at index.
    /// @return Quote of the Index.
    function getUserQuoteAtIndex(uint256 _quoteIndex, address _userAddress)
        external
        view
        onlyOwner
        isActive
        userMustBeRegistered(_userAddress)
        returns (Quote memory)
    {
        // Return internal function.
        return getUserQuoteAtIndexAsOwner(_quoteIndex, _userAddress);
    }

    /// @notice Only owner can returns users stored quotes.
    /// @param _userAddress The user's address.
    /// @param _offset First quote's index.
    /// @param _limit Last quote's index.
    /// @return result Array of user's stored quotes.
    function getUserQuotes(address _userAddress, uint256 _offset, uint256 _limit)
        external
        view
        onlyOwner
        isActive
        userMustBeRegistered(_userAddress)
        returns (Quote[] memory result)
    {
        // Call internal function.
        return getUserQuotesAsOwner(_userAddress, _offset, _limit);
    }

    // ----------------------------------------------- Owner's External Read Function ---------------------------

    /// @notice Only owner can returns users data.
    /// @param _userAddress The user's address.
    /// @return User's name, age, gender, email address, skill.
    function getUserData(address _userAddress)
        external
        view
        onlyOwner
        userMustBeRegistered(_userAddress)
        returns (Data memory)
    {
        // Return internal function.
        return getUserDataAsOwner(_userAddress);
    }

    /// @notice Only owner can returns addresses of registered user.
    /// @return result Array of users Address.
    function getRegisteredUsersAddress(uint256 _offset, uint256 _limit)
        external
        view
        onlyOwner
        returns (address[] memory result)
    {
        // Return internal function.
        return getUsersAddress(_offset, _limit);
    }
}
