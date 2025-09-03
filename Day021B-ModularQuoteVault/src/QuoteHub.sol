// SPDX-License-Identifier: MIT

/// @author Michealking(@BuildsWithKing).
/// @title QuoteHub contract for ModularQuoteVault.
/// @notice Created on 20th Aug, 2025.

/**
 * @notice Allows users store, view, update and delete their favorite quotes.
 *     Owner can view and delete users quote.
 */
pragma solidity ^0.8.30;

/// @notice Imports Utils file.
import {Utils} from "./Utils.sol";

abstract contract QuoteHub is Utils {
    // ------------------------------------------ User's Internal Write Functions ------------------------------

    /// @notice Stores user's quotes.
    /// @param _author The quote's author.
    /// @param _description The quote.
    /// @param _category The quote's category.
    /// @param _source The quote's source.
    /// @param _personalNote The user's personal note.
    function addQuote(
        string memory _author,
        string memory _description,
        string memory _category,
        string memory _source,
        string memory _personalNote
    ) internal isActive mustBeRegistered validateQuoteInput(_author, _description, _category, _source, _personalNote) {
        // Increment id by one.
        unchecked {
            id++;
        }

        // Read available data on struct.
        Quote memory quote = Quote({
            // Store user's input.
            quoteId: id,
            author: _author,
            description: _description,
            category: _category,
            source: _source,
            personalNote: _personalNote,
            addedAt: block.timestamp,
            updatedAt: block.timestamp
        });

        // Push quote to user's array.
        userQuotes[msg.sender].push(quote);

        // Records total registered.
        unchecked {
            totalQuotes++;
        }

        // Emit event NewQuoteAdded.
        emit NewQuoteAdded(msg.sender, _author, _description, _category, _source);
    }

    /// @notice Updates author.
    /// @param _quoteIndex The quote's Index number.
    /// @param _newAuthor The quote's new author.
    function updateAuthor(uint256 _quoteIndex, string calldata _newAuthor)
        internal
        isActive
        mustBeRegistered
        validateIndex(_quoteIndex, msg.sender)
    {
        // Revert with "EmptyAuthor" if new author is Empty.
        if (bytes(_newAuthor).length == 0) revert EmptyAuthor();

        // Read through user's stored quotes.
        Quote[] storage quote = userQuotes[msg.sender];

        // Revert with "SameAuthor" if old author is same as new author.
        if (keccak256(bytes(quote[_quoteIndex].author)) == keccak256(bytes(_newAuthor))) {
            revert SameAuthor();
        }

        // Update author of the quote index.
        quote[_quoteIndex].author = _newAuthor;

        // Update time.
        quote[_quoteIndex].updatedAt = block.timestamp;

        // Emit event AuthorUpdated.
        emit AuthorUpdated(msg.sender, _quoteIndex, _newAuthor);
    }

    /// @notice Updates description.
    /// @param _quoteIndex The quote's Index number.
    /// @param _newDescription The new quote.
    function updateDescription(uint256 _quoteIndex, string calldata _newDescription)
        internal
        isActive
        mustBeRegistered
        validateIndex(_quoteIndex, msg.sender)
    {
        // Revert with "EmptyDescription" if new description is Empty.
        if (bytes(_newDescription).length == 0) revert EmptyDescription();

        // Read through user's stored quotes.
        Quote[] storage quote = userQuotes[msg.sender];

        // Revert with "SameQuote" if old quote is same as new quote.
        if (keccak256(bytes(quote[_quoteIndex].description)) == keccak256(bytes(_newDescription))) {
            revert SameQuote();
        }

        // Update quote of the quote index.
        quote[_quoteIndex].description = _newDescription;

        // Update time.
        quote[_quoteIndex].updatedAt = block.timestamp;

        // Emit event DescriptionUpdated.
        emit DescriptionUpdated(msg.sender, _quoteIndex, _newDescription);
    }

    /// @notice Updates category.
    /// @param _quoteIndex The quote's Index number.
    /// @param _newCategory The quote's new category.
    function updateCategory(uint256 _quoteIndex, string calldata _newCategory)
        internal
        isActive
        mustBeRegistered
        validateIndex(_quoteIndex, msg.sender)
    {
        // Revert with "EmptyCategory" if new category is Empty.
        if (bytes(_newCategory).length == 0) revert EmptyCategory();

        // Read through user's stored quotes.
        Quote[] storage quote = userQuotes[msg.sender];

        // Revert with "SameCategory" if old category is same as new category.
        if (keccak256(bytes(quote[_quoteIndex].category)) == keccak256(bytes(_newCategory))) {
            revert SameCategory();
        }

        // Update category of the quote index.
        quote[_quoteIndex].category = _newCategory;

        // Update time.
        quote[_quoteIndex].updatedAt = block.timestamp;

        // Emit event CategoryUpdated.
        emit CategoryUpdated(msg.sender, _quoteIndex, _newCategory);
    }

    /// @notice Updates source.
    /// @param _quoteIndex The quote's Index number.
    /// @param _newSource The quote's new source.
    function updateSource(uint256 _quoteIndex, string calldata _newSource)
        internal
        isActive
        mustBeRegistered
        validateIndex(_quoteIndex, msg.sender)
    {
        // Revert with "EmptySource" if new source is Empty.
        if (bytes(_newSource).length == 0) revert EmptySource();

        // Read through user's stored quotes.
        Quote[] storage quote = userQuotes[msg.sender];

        // Revert with "SameSource" if old source is same as new source.
        if (keccak256(bytes(quote[_quoteIndex].source)) == keccak256(bytes(_newSource))) {
            revert SameSource();
        }

        // Update source of the quote index.
        quote[_quoteIndex].source = _newSource;

        // Update time.
        quote[_quoteIndex].updatedAt = block.timestamp;

        // Emit event SourceUpdated.
        emit SourceUpdated(msg.sender, _quoteIndex, _newSource);
    }

    /// @notice Updates PersonalNote.
    /// @param _quoteIndex The quote's Index number.
    /// @param _newPersonalNote The user's new note.
    function updatePersonalNote(uint256 _quoteIndex, string calldata _newPersonalNote)
        internal
        isActive
        mustBeRegistered
        validateIndex(_quoteIndex, msg.sender)
    {
        // Revert with "EmptyNote" if new personal note is Empty.
        if (bytes(_newPersonalNote).length == 0) revert EmptyNote();

        // Read through user's stored quotes.
        Quote[] storage quote = userQuotes[msg.sender];

        // Revert with "SameNote" if old note is same as new note.
        if (keccak256(bytes(quote[_quoteIndex].personalNote)) == keccak256(bytes(_newPersonalNote))) {
            revert SameNote();
        }

        // Update note of the quote index.
        quote[_quoteIndex].personalNote = _newPersonalNote;

        // Update time.
        quote[_quoteIndex].updatedAt = block.timestamp;

        // Emit event UserNoteUpdated.
        emit UserNoteUpdated(msg.sender, _quoteIndex, _newPersonalNote);
    }

    /// @notice Deletes users Quote.
    /// @param _quoteIndex The quote index number.
    function deleteQuote(uint256 _quoteIndex)
        internal
        isActive
        mustBeRegistered
        validateIndex(_quoteIndex, msg.sender)
    {
        // Call internal helper function.
        _deleteQuote(_quoteIndex, msg.sender);

        // Emit event QuoteDeleted.
        emit QuoteDeleted(msg.sender, _quoteIndex);
    }

    // ------------------------------------- User's External Read Function --------------------------------------------

    /// @notice Returns user's stored quotes.
    /// @param _offset First quote's index.
    /// @param _limit Last quote's index.
    /// @return result Array of user's stored quotes.
    function getMyQuotes(uint256 _offset, uint256 _limit)
        internal
        view
        mustBeRegistered
        returns (Quote[] memory result)
    {
        // Store user's total quotes.
        uint256 totalQuotes = userQuotes[msg.sender].length;

        // Return empty array, if _offset > totalQuotes.
        if (_offset > totalQuotes) {
            return new Quote[](0);
        }

        // Calculate end point.
        uint256 end = _offset + _limit;

        // Prevent length from exceeding total number of quotes.
        if (end > totalQuotes) end = totalQuotes;

        // Compute number of element to be returned.
        uint256 len = end - _offset;

        // Allocate a new array "result" for the returned element.
        result = new Quote[](len);

        // Loop through the range.
        for (uint256 i; i < len; i++) {
            /* Copy Quotes from big storage array (userQuotes) 
                into result (new memory array). 
            */
            result[i] = userQuotes[msg.sender][_offset + i];
        }
    }

    // ------------------------------------- Owner's Internal Write Function -------------------------------------------

    /// @notice Only owner can delete users data.
    /// @param _quoteIndex The quote index number.
    /// @param _userAddress The user's address.
    function deleteUserQuoteAsOwner(uint256 _quoteIndex, address _userAddress)
        internal
        onlyOwner
        isActive
        userMustBeRegistered(_userAddress)
        validateIndex(_quoteIndex, _userAddress)
    {
        // Call internal helper function.
        _deleteQuote(_quoteIndex, _userAddress);

        // Emit event UserQuoteDeleted.
        emit UserQuoteDeleted(owner, _userAddress, _quoteIndex);
    }

    // ------------------------------------- Owner's internal Read Functions -------------------------------------------

    /// @notice Only owner can return user's quotes at index.
    /// @return Quote of the Index.
    function getUserQuoteAtIndexAsOwner(uint256 _quoteIndex, address _userAddress)
        internal
        view
        onlyOwner
        isActive
        userMustBeRegistered(_userAddress)
        returns (Quote memory)
    {
        // Return user's id quote.
        return userQuotes[_userAddress][_quoteIndex];
    }

    /// @notice Only owner can returns users stored quotes.
    /// @param _userAddress The user's address.
    /// @param _offset First quote's index.
    /// @param _limit Last quote's index.
    /// @return result Array of user's stored quotes.
    function getUserQuotesAsOwner(address _userAddress, uint256 _offset, uint256 _limit)
        internal
        view
        onlyOwner
        isActive
        userMustBeRegistered(_userAddress)
        returns (Quote[] memory result)
    {
        // Store user's total quotes.
        uint256 totalQuotes = userQuotes[_userAddress].length;

        // Return empty array, if _offset > totalQuotes.
        if (_offset > totalQuotes) {
            return new Quote[](0);
        }

        // Calculate end point.
        uint256 end = _offset + _limit;

        // Prevent length from exceeding total number of quotes.
        if (end > totalQuotes) end = totalQuotes;

        // Compute number of element to be returned.
        uint256 len = end - _offset;

        // Allocate a new array "result" for the returned element.
        result = new Quote[](len);

        // Loop through the range.
        for (uint256 i; i < len; i++) {
            /* Copy Quotes from big storage array (userQuotes) 
                into result (new memory array). 
            */
            result[i] = userQuotes[_userAddress][_offset + i];
        }
    }
}
