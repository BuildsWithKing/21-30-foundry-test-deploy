// SPDX-License-Identifier: MIT

/// @author Michealking(@BuildsWithKing).
/// @title ModularQuoteVaultTest.
/// @notice Created on 30th Aug, 2025.

pragma solidity ^0.8.30;

/**
 * @notice Imports Test from forge standard library, modularQuoteVault,
 *     Types, and Utils contract.
 */
import {Test} from "forge-std/Test.sol";
import {ModularQuoteVault} from "../src/ModularQuoteVault.sol";
import {Types} from "../src/Types.sol";
import {Utils} from "../src/Utils.sol";

contract ModularQuoteVaultTest is Test {
    // ------------------------------------- Variable Assignment ------------------------------------------

    /// @notice Assigns modularQuoteVault.
    ModularQuoteVault modularQuoteVault;

    /// @notice Assigns utils.
    Utils utils;

    /// @notice Assigns zero, owner, newOwner user1, user2 and user3.
    address zero = address(0);
    address owner = address(this);
    address newOwner = address(0x10);
    address user1 = address(0x1);
    address user2 = address(0x2);
    address user3 = address(0x3);

    /// @notice Sets ETH_AMOUNT and STARTING_BALANCE.
    uint256 constant ETH_AMOUNT = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    // --------------------------------------------- Modifiers -----------------------------------------

    /// @dev Registers user1.
    modifier registerUser1() {
        // Write as user1.
        vm.prank(user1);
        vm.expectEmit(true, true, true, true);
        emit Utils.NewUser(user1, "Michealking BuildsWithKing", 23, Types.Gender.Male, "Solidity Developer");

        // Register user1.
        modularQuoteVault.register(
            "Michealking BuildsWithKing", 23, Types.Gender.Male, "buildswithking@gmail.com", "Solidity Developer"
        );
        _;
    }

    /// @dev Registers user2.
    modifier registerUser2() {
        // Write as user 2.
        vm.startPrank(user2);
        vm.expectEmit(true, true, true, true);
        emit Utils.NewUser(user2, "SolidityQueen BuildsWithKing", 25, Types.Gender.Female, "Solidity Developer");
        modularQuoteVault.register(
            "SolidityQueen BuildsWithKing", 25, Types.Gender.Female, "solidityQueen@gmail.com", "Solidity Developer"
        );
        _;
    }

    /// @dev Registers user3.
    modifier registerUser3() {
        // Write as user 3.
        vm.startPrank(user3);
        vm.expectEmit(true, true, true, true);
        emit Utils.NewUser(user3, "BuildsWithKing Michealking", 25, Types.Gender.Male, "Solidity Developer");
        modularQuoteVault.register(
            "BuildsWithKing Michealking", 25, Types.Gender.Male, "solidityKing@gmail.com", "Solidity Developer"
        );
        _;
    }

    /// @dev Access user1 data.
    modifier user1Data() {
        //Write as user1.
        vm.prank(user1);
        ModularQuoteVault.Data memory data = modularQuoteVault.getMyData();

        // Assert Both are Equal.
        assertEq(data.fullName, "Michealking BuildsWithKing");
        assertEq(data.age, 23);
        assertEq(uint8(data.gender), uint8(Types.Gender.Male));
        assertEq(data.email, "buildswithking@gmail.com");
        assertEq(data.skill, "Solidity Developer");
        _;
    }

    /// @dev Store user1 quote.
    modifier storeUser1Quote() {
        // Write as user1 and Emit "NewQuoteAdded".
        vm.prank(user1);
        vm.expectEmit(true, true, true, true);
        emit Utils.NewQuoteAdded(user1, "Michealking BuildsWithKing", "Consistency builds mastery", "Self", "Mindset");

        // Store user1's quote.
        modularQuoteVault.storeQuote(
            "Michealking BuildsWithKing", "Consistency builds mastery", "Self", "Mindset", "I'm here to prove it"
        );
        _;
    }

    /// @dev Access user1's quote.
    modifier user1Quote() {
        // Write as user1.
        vm.prank(user1);

        // Access user1's quote.
        ModularQuoteVault.Quote memory quote = modularQuoteVault.getMyQuote(0);

        // Assert Both are Equal.
        assertEq(quote.author, "Michealking BuildsWithKing");
        assertEq(quote.description, "Consistency builds mastery");
        assertEq(quote.category, "Self");
        assertEq(quote.source, "Mindset");
        assertEq(quote.personalNote, "I'm here to prove it");
        _;
    }

    // -------------------------------------------- SetUp function -------------------------------------

    /// @notice This function runs before every other function.
    function setUp() external {
        // Create new instance of ModularQuoteVault.
        modularQuoteVault = new ModularQuoteVault();

        // Create new instance of utils.
        utils = new Utils();

        // Label owner, zero, user1 and user2.
        vm.label(owner, "Owner");
        vm.label(zero, "Zero");
        vm.label(user1, "User1");
        vm.label(user2, "User2");

        // Fund user1 with starting balance.
        vm.deal(user2, STARTING_BALANCE);
    }

    // ---------------------------------------- Test Function for Registry Contract ----------------------

    /// @notice Test for register and get my data.
    function testUserCanRegisterAndRetrieve() external registerUser1 user1Data {}

    /// @notice Test to ensure users can't register with age above 120.
    function testUserCantRegisterWithAgeAbove120() external {
        // Revert with message "Above120".
        vm.expectRevert(Utils.Above120.selector);
        vm.prank(user1);

        // Register user1.
        modularQuoteVault.register(
            "Michealking BuildsWithKing", 250, Types.Gender.Male, "buildswithking@gmail.com", "Solidity Developer"
        );
    }

    /// @notice Test to validate user's input.
    function testValidateUser() external {
        // Write as user1.
        vm.startPrank(user1);

        // Revert with message "EmptyName".
        vm.expectRevert(Utils.EmptyName.selector);
        modularQuoteVault.register("", 23, Types.Gender.Male, "buildswithking@gmail.com", "Solidity Developer");

        // Revert with message "ZeroAge".
        vm.expectRevert(Utils.ZeroAge.selector);
        modularQuoteVault.register(
            "Michealking BuildsWithKing", 0, Types.Gender.Male, "buildswithking@gmail.com", "Solidity Developer"
        );

        // Revert with message "UnsetGender".
        vm.expectRevert(Utils.UnsetGender.selector);
        modularQuoteVault.register(
            "Michealking BuildsWithKing", 23, Types.Gender.Unset, "buildswithking@gmail.com", "Solidity Developer"
        );

        // Revert with message "EmptyEmail".
        vm.expectRevert(Utils.EmptyEmail.selector);
        modularQuoteVault.register("Michealking BuildsWithKing", 23, Types.Gender.Male, "", "Solidity Developer");

        // Revert with message "EmptySkill".
        vm.expectRevert(Utils.EmptySkill.selector);
        modularQuoteVault.register("Michealking BuildsWithKing", 23, Types.Gender.Male, "buildswithking@gmail.com", "");
    }

    /// @notice Test to ensure users can register only once.
    function testUserCanOnlyRegisterOnce() external registerUser1 {
        // Revert with message "AlreadyRegistered".
        vm.expectRevert(Utils.AlreadyRegistered.selector);
        vm.prank(user1);
        modularQuoteVault.register(
            "Michealking BuildsWithKing", 23, Types.Gender.Male, "buildswithking@gmail.com", "Solidity Developer"
        );
    }

    /// @notice Test to ensure users can't update with empty data.
    function testUserCantUpdateEmptyData() external registerUser1 {
        // Write as user1.
        vm.startPrank(user1);

        // Revert with message "EmptyName".
        vm.expectRevert(Utils.EmptyName.selector);
        modularQuoteVault.updateMyFullName("");

        // Revert with message "ZeroAge".
        vm.expectRevert(Utils.ZeroAge.selector);
        modularQuoteVault.updateMyAge(0);

        // Revert with message "UnsetGender".
        vm.expectRevert(Utils.UnsetGender.selector);
        modularQuoteVault.updateMyGender(Types.Gender.Unset);

        // Revert with message "EmptyEmail.
        vm.expectRevert(Utils.EmptyEmail.selector);
        modularQuoteVault.updateMyEmail("");

        // Revert with message "EmptySkill".
        vm.expectRevert(Utils.EmptySkill.selector);
        modularQuoteVault.updateMySkill("");

        // Stop prank.
        vm.stopPrank();
    }

    /// @notice Test to ensure users can't update with same data.
    function testUserCantUpdateWithSameData() external registerUser1 {
        // Write as user1.
        vm.startPrank(user1);

        // Revert with message "SameName".
        vm.expectRevert(Utils.SameName.selector);
        modularQuoteVault.updateMyFullName("Michealking BuildsWithKing");

        // Revert with message "SameAge".
        vm.expectRevert(Utils.SameAge.selector);
        modularQuoteVault.updateMyAge(23);

        // Revert with message "SameGender".
        vm.expectRevert(Utils.SameGender.selector);
        modularQuoteVault.updateMyGender(Types.Gender.Male);

        // Revert with message "SameEmail".
        vm.expectRevert(Utils.SameEmail.selector);
        modularQuoteVault.updateMyEmail("buildswithking@gmail.com");

        // Revert with message "SameSkill".
        vm.expectRevert(Utils.SameSkill.selector);
        modularQuoteVault.updateMySkill("Solidity Developer");

        // Stop prank.
        vm.stopPrank();
    }

    /// @notice Test to ensure users can't update with age above 120.
    function testUserCantUpdateWithAgeAboveMaxAge() external registerUser1 {
        // Revert with message "Above120".
        vm.expectRevert(Utils.Above120.selector);
        vm.prank(user1);
        modularQuoteVault.updateMyAge(255);
    }

    /// @notice Test to ensure users can update their data.
    function testUpdateMyData() external registerUser1 {
        // Write as user1.
        vm.startPrank(user1);
        vm.expectEmit(true, true, false, false);
        emit Utils.FullNameUpdated(user1, "BuildsWithKing Michealking");
        modularQuoteVault.updateMyFullName("BuildsWithKing Michealking");

        // Emit AgeUpdated.
        vm.expectEmit(true, true, false, false);
        emit Utils.AgeUpdated(user1, 25);
        modularQuoteVault.updateMyAge(25);

        // Emit GenderUpdated.
        vm.expectEmit(true, true, false, false);
        emit Utils.GenderUpdated(user1, Types.Gender.Female);
        modularQuoteVault.updateMyGender(Types.Gender.Female);

        // Emit EmailUpdated.
        vm.expectEmit(true, true, false, false);
        emit Utils.EmailUpdated(user1, "solidityking@gmail.com");
        modularQuoteVault.updateMyEmail("solidityking@gmail.com");

        // Emit SkillUpdated.
        vm.expectEmit(true, true, false, false);
        emit Utils.SkillUpdated(user1, "Solidity Engineer");
        modularQuoteVault.updateMySkill("Solidity Engineer");

        // Access user1 data.
        ModularQuoteVault.Data memory data = modularQuoteVault.getMyData();

        // Stop writing as user1.
        vm.stopPrank();

        // Assert Both are Equal.
        assertEq(data.fullName, "BuildsWithKing Michealking");
        assertEq(data.age, 25);
        assertEq(uint8(data.gender), uint8(Types.Gender.Female));
        assertEq(data.email, "solidityking@gmail.com");
        assertEq(data.skill, "Solidity Engineer");
    }

    /// @notice Test Unregistered Users cant update data.
    function testNonregisteredUserCantUpdateData() external {
        // Write as User2.
        vm.expectRevert(Utils.NotRegistered.selector);
        vm.prank(user2);
        modularQuoteVault.updateMyFullName("Solidity King");
    }

    /// @notice Test to ensure users can delete their data.
    function testDeleteMyData() external registerUser1 {
        // Write as user1.
        vm.startPrank(user1);
        modularQuoteVault.deleteMyData();

        // Revert with message "NotRegistered".
        vm.expectRevert(Utils.NotRegistered.selector);
        modularQuoteVault.getMyData();

        // Return active users count.
        uint256 count = modularQuoteVault.getActiveUserCount();

        // Stop writing as user1.
        vm.stopPrank();

        // Assert count is equal zero.
        assertEq(count, 0);
    }

    /// @notice Test Array updates once a user deletes their data.
    function testArrayUpdateOnceAUserDeletesData() external registerUser1 registerUser2 registerUser3 {
        // Write as user2.
        vm.startPrank(user2);
        modularQuoteVault.deleteMyData();
        vm.stopPrank();

        vm.prank(owner);
        address[] memory users = modularQuoteVault.getRegisteredUsersAddress(0, 3);

        // Assert both are equal.
        assertEq(users[0], user1);
        assertEq(users[1], user3);
    }

    /// @notice Test for get my skill.
    function testGetMySkill() external registerUser1 {
        // Write as user1.
        vm.prank(user1);
        string memory skill = modularQuoteVault.getMySkill();

        // Assert Both are same.
        assertEq(skill, "Solidity Developer");
    }

    /// @notice Test for get my gender.
    function testGetMyGender() external registerUser1 {
        // Write as user1.
        vm.prank(user1);
        string memory gender = modularQuoteVault.getMyGender();

        // Assert Both are same.
        assertEq(gender, "Male");
    }

    /// @notice Test for getMyGender female.
    function testGetMyGenderFemale() external registerUser2 {
        // Access User2's gender.
        string memory gender = modularQuoteVault.getMyGender();

        // Stop prank.
        vm.stopPrank();

        // Assert Gender is female.
        assertEq(gender, "Female");
    }

    /// @notice Test getMyGender returns Unset.
    function testGetMyGenderReturnsUnset() external {
        //Write as owner.
        vm.prank(owner);
        string memory gender = modularQuoteVault.getMyGender();

        // Assert both are same.
        assertEq(gender, "Unset");
    }

    /// @notice Test for check my registration status.
    function testForCheckMyRegistrationStatus() external registerUser1 {
        // Write as user1.
        vm.prank(user1);
        bool status = modularQuoteVault.checkMyRegistrationStatus();

        // Assert Both are same.
        assertEq(status, true);
    }

    /// @notice Test for check if registered.
    function testIfUserIsRegistered() external registerUser1 {
        // Write as user1.
        vm.prank(user1);
        bool status = modularQuoteVault.checkIfRegistered(user2);

        // Assert Both are same.
        assertEq(status, false);
    }

    /// @notice Test for get all registered user.
    function testGetAllRegisteredUser() external registerUser1 {
        // Write as user1.
        vm.prank(user1);
        uint256 users = modularQuoteVault.getTotalRegisteredUsers();

        // Assert Users is equal one.
        assertEq(users, 1);
    }

    /// @notice Test for get active users count.
    function testGetActiveUserCount() external registerUser1 {
        // Write as user1.
        vm.prank(user1);
        modularQuoteVault.deleteMyData();
        uint256 activeUsers = modularQuoteVault.getActiveUserCount();

        // Assert active users is equal zero.
        assertEq(activeUsers, 0);
    }

    /// @notice Test for get owner.
    function testGetOwner() external {
        // Write as user2.
        vm.prank(user2);
        address contractOwner = modularQuoteVault.getOwner();

        // Assert Both are same.
        assertEq(owner, contractOwner);
    }

    // ------------------------------------------- Test Function For QuoteHub ------------------------------------

    /// @notice Test to ensure registered users can store quote.
    function testRegisteredUserCanStoreQuote() external registerUser1 storeUser1Quote user1Quote {}

    /// @notice Test to ensure only registered user's can store quote.
    function testNonregisteredUserCantStoreQuote() external {
        // Revert with message "NotRegistered".
        vm.expectRevert(Utils.NotRegistered.selector);
        vm.prank(user2);
        modularQuoteVault.storeQuote(
            "Michealking BuildsWithKing",
            "Even slow steps still climb mountains",
            "Self",
            "Mindset",
            "Progress is progress, I'm not stopping now"
        );
    }

    /// @notice Test to ensure users can't store empty quote.
    function testValidateQuoteInput() external registerUser1 {
        // Revert with message "EmptyAuthor".
        vm.expectRevert(Utils.EmptyAuthor.selector);
        vm.startPrank(user1);
        modularQuoteVault.storeQuote("", "Consistency builds mastery", "Self", "Mindset", "I'm here to prove it");

        // Revert with message "EmptyDescription".
        vm.expectRevert(Utils.EmptyDescription.selector);
        modularQuoteVault.storeQuote("Michealking BuildsWithKing", "", "Self", "Mindset", "I'm here to prove it");

        // Revert with message "EmptyCategory".
        vm.expectRevert(Utils.EmptyCategory.selector);
        modularQuoteVault.storeQuote(
            "Michealking BuildsWithKing", "Consistency builds mastery", "", "Mindset", "I'm here to prove it"
        );

        // Revert with message "EmptySource".
        vm.expectRevert(Utils.EmptySource.selector);
        modularQuoteVault.storeQuote(
            "Michealking BuildsWithKing", "Consistency builds mastery", "Self", "", "I'm here to prove it"
        );

        // Revert with message "EmptyNote".
        vm.expectRevert(Utils.EmptyNote.selector);
        modularQuoteVault.storeQuote("Michealking BuildsWithKing", "Consistency builds mastery", "Self", "Mindset", "");

        // Stop prank.
        vm.stopPrank();
    }

    /// @notice Test to ensure users can't update quote with same date.
    function testUpdateQuoteWithSameData() external registerUser1 storeUser1Quote {
        // Write as user1.
        vm.startPrank(user1);

        // Revert with message "SameAuthor".
        vm.expectRevert(Utils.SameAuthor.selector);
        modularQuoteVault.updateQuoteAuthor(0, "Michealking BuildsWithKing");

        // Revert with message "SameQuote".
        vm.expectRevert(Utils.SameQuote.selector);
        modularQuoteVault.updateQuoteDescription(0, "Consistency builds mastery");

        // Revert with message "SameCategory".
        vm.expectRevert(Utils.SameCategory.selector);
        modularQuoteVault.updateQuoteCategory(0, "Self");

        // Revert with message "SameSource".
        vm.expectRevert(Utils.SameSource.selector);
        modularQuoteVault.updateQuoteSource(0, "Mindset");

        // Revert with message "SameNote".
        vm.expectRevert(Utils.SameNote.selector);
        modularQuoteVault.updateQuoteNote(0, "I'm here to prove it");

        // Stop prank.
        vm.stopPrank();
    }

    /// @notice Test to ensure users cant empty quote with empty data.
    function testUserCantUpdateEmptyQuoteData() external registerUser1 storeUser1Quote {
        // Write as user1.
        vm.startPrank(user1);

        // Revert with message "EmptyAuthor".
        vm.expectRevert(Utils.EmptyAuthor.selector);
        modularQuoteVault.updateQuoteAuthor(0, "");

        // Revert with message "EmptyDescription".
        vm.expectRevert(Utils.EmptyDescription.selector);
        modularQuoteVault.updateQuoteDescription(0, "");

        // Revert with message "EmptyCategory".
        vm.expectRevert(Utils.EmptyCategory.selector);
        modularQuoteVault.updateQuoteCategory(0, "");

        // Revert with message "EmptySource".
        vm.expectRevert(Utils.EmptySource.selector);
        modularQuoteVault.updateQuoteSource(0, "");

        // Revert with message "EmptyNote".
        vm.expectRevert(Utils.EmptyNote.selector);
        modularQuoteVault.updateQuoteNote(0, "");

        // Stop prank.
        vm.stopPrank();
    }

    /// @notice Test to ensure user's can update their quotes.
    function testUpdateMyQuote() external registerUser1 storeUser1Quote {
        // Write as user1.
        vm.startPrank(user1);

        // Emit AuthorUpdated.
        vm.expectEmit(true, true, true, false);
        emit Utils.AuthorUpdated(user1, 0, "BuildswithKing Michealking");
        // Update user1's quote author at index 0.
        modularQuoteVault.updateQuoteAuthor(0, "BuildsWithKing Michealking");

        // Emit DescriptionUpdated.
        vm.expectEmit(true, true, true, false);
        emit Utils.DescriptionUpdated(user1, 0, "God First, Code Second");
        // Update user1's quote description at index 0.
        modularQuoteVault.updateQuoteDescription(0, "God First, Code Second");

        // Emit CategoryUpdated.
        vm.expectEmit(true, true, true, false);
        emit Utils.CategoryUpdated(user1, 0, "Personal");
        // Update user1's quote category at index 0.
        modularQuoteVault.updateQuoteCategory(0, "Personal");

        // Emit SourceUpdated.
        vm.expectEmit(true, true, true, false);
        emit Utils.SourceUpdated(user1, 0, "Mind");
        // Update user1's quote source at index 0.
        modularQuoteVault.updateQuoteSource(0, "Mind");

        // Emit UserNoteUpdated.
        vm.expectEmit(true, true, true, false);
        emit Utils.UserNoteUpdated(user1, 0, "I just need to be consistent.");
        // Update user1's quote personalnote at index 0.
        modularQuoteVault.updateQuoteNote(0, "I just need to be consistent.");

        // Access user1's quote.
        ModularQuoteVault.Quote memory quote = modularQuoteVault.getMyQuote(0);

        // Stop prank.
        vm.stopPrank();

        // Assert Both are same.
        assertEq(quote.author, "BuildsWithKing Michealking");
        assertEq(quote.description, "God First, Code Second");
        assertEq(quote.category, "Personal");
        assertEq(quote.source, "Mind");
        assertEq(quote.personalNote, "I just need to be consistent.");
    }

    /// @notice Test to ensure user's can delete their quote.
    function testDeleteMyQuote() external registerUser1 storeUser1Quote {
        // Write as user1.
        vm.startPrank(user1);

        // Emit "NewQuoteAdded".
        vm.expectEmit(true, true, true, true);
        emit Utils.NewQuoteAdded(user1, "BuildsWithKing Michealking", "God First, Code Second", "Personal", "Mind");

        // Store user1's quote.
        modularQuoteVault.storeQuote(
            "BuildsWithKing Michealking", "God First, Code Second", "Personal", "Mind", "I just need to be consistent."
        );

        // Delete user1's quote at index zero.
        modularQuoteVault.deleteMyQuote(0);

        // Stop prank.
        vm.stopPrank();
    }

    /// @notice Test for get all my quotes.
    function testGetAllMyQuotes() external registerUser1 storeUser1Quote {
        // Write as user1.
        vm.prank(user1);
        ModularQuoteVault.Quote[] memory result = modularQuoteVault.getAllMyQuotes(0, 1);

        // Assert result at index 0 is Equal.
        assertEq(result[0].author, "Michealking BuildsWithKing");
        assertEq(result[0].description, "Consistency builds mastery");
        assertEq(result[0].category, "Self");
        assertEq(result[0].source, "Mindset");
        assertEq(result[0].personalNote, "I'm here to prove it");
    }

    /// @notice Test to ensure users quote limit can't be greater than their stored total quotes.
    function testUserLimitCantBeGreaterThanTheirTotalQuotes() external registerUser1 storeUser1Quote {
        // Write as user1.
        vm.prank(user1);
        ModularQuoteVault.Quote[] memory result = modularQuoteVault.getAllMyQuotes(0, 2);

        // Assert result at index 0 is Equal.
        assertEq(result[0].author, "Michealking BuildsWithKing");
        assertEq(result[0].description, "Consistency builds mastery");
        assertEq(result[0].category, "Self");
        assertEq(result[0].source, "Mindset");
        assertEq(result[0].personalNote, "I'm here to prove it");
    }

    /// @notice Test to ensure an empty array is returned when offset is greater than user's total quotes.
    function testReturnsEmptyArray() external registerUser1 storeUser1Quote {
        //Write as user1.
        vm.prank(user1);
        ModularQuoteVault.Quote[] memory result = modularQuoteVault.getAllMyQuotes(100, 10);

        // Assert result length is zero.
        assertEq(result.length, 0);
    }

    /// @notice Test for get total quotes.
    function testGetTotalQuotes() external registerUser1 storeUser1Quote {
        // Write as user1.
        vm.prank(user1);
        uint256 quotes = modularQuoteVault.getTotalQuotes();

        // Assert both are same.
        assertEq(quotes, 1);
    }

    /// @notice Test for get active quote count.
    function testGetActiveQuoteCount() external registerUser1 storeUser1Quote {
        // Write as user1.
        vm.prank(user1);
        uint256 quotes = modularQuoteVault.getActiveQuoteCount();

        // Assert both are same.
        assertEq(quotes, 1);
    }

    // ---------------------------- External Write and Read Functions for Owner only --------------------------

    /// @notice Test owner can delete users data.
    function testOwnerCanDeleteUserData() external registerUser1 {
        // Write as Owner.
        vm.prank(owner);
        modularQuoteVault.deleteUserData(user1);

        // Revert with message "NotRegistered".
        vm.expectRevert(Utils.NotRegistered.selector);
        vm.prank(user1);
        modularQuoteVault.getMyData();
    }

    /// @notice Test to ensure only owner can delete user data.
    function testOnlyOwnerIsAllowedToDeleteUserData() external registerUser1 {
        // Revert with message "Unathorized".
        vm.expectRevert(Utils.Unauthorized.selector);
        vm.prank(user2);
        modularQuoteVault.deleteUserData(user1);
    }

    /// @notice Test to ensure owner can delete users quote.
    function testOwnerCanDeleteUserQuote() external registerUser1 storeUser1Quote {
        // Write as owner.
        vm.prank(owner);
        modularQuoteVault.deleteUserQuote(0, user1);

        // Revert with message "OutOfBounds".
        vm.expectRevert(Utils.OutOfBounds.selector);
        vm.prank(user1);
        modularQuoteVault.getMyQuote(0);
    }

    /// @notice Test to ensure only owner can delete users quotes.
    function testonlyOwnerCanDeleteUserQuote() external registerUser1 storeUser1Quote {
        // Revert with message Unauthorized.
        vm.expectRevert(Utils.Unauthorized.selector);

        // Write as user2.
        vm.prank(user2);
        modularQuoteVault.deleteUserQuote(0, user1);
    }

    /// @notice Test Array updates once owner deletes users data.
    function testArrayUpdateOnceOwnerDeletesUsersData() external registerUser1 registerUser2 registerUser3 {
        // Write as owner.
        vm.startPrank(owner);
        modularQuoteVault.deleteUserData(user2);

        address[] memory users = modularQuoteVault.getRegisteredUsersAddress(0, 3);

        // Stop prank.
        vm.stopPrank();

        // Assert both are equal.
        assertEq(users[0], user1);
        assertEq(users[1], user3);
    }

    // -------------------------------------- External Read Function for Owner Only -----------------------

    /// @notice Test to ensure owner can access users data.
    function testOwnerCanGetUserData() external registerUser1 {
        // Write as Owner.
        vm.prank(owner);
        ModularQuoteVault.Data memory data = modularQuoteVault.getUserData(user1);

        // Assert Both are Equal.
        assertEq(data.fullName, "Michealking BuildsWithKing");
        assertEq(data.age, 23);
        assertEq(uint8(data.gender), uint8(Types.Gender.Male));
        assertEq(data.email, "buildswithking@gmail.com");
        assertEq(data.skill, "Solidity Developer");
    }

    /// @notice Test to ensure owner can access registered users address.
    function testOwnerCanGetRegisteredUsersAddress() external registerUser1 {
        // Write as Owner.
        vm.prank(owner);
        address[] memory result = modularQuoteVault.getRegisteredUsersAddress(0, 1);

        // Assert Both are same.
        assertEq(result[0], user1);
    }

    /// @notice Test to ensure empty array is returned to owner.
    function testReturnEmptyArrayOfRegisteredAddress() external {
        // Write as Owner.
        vm.prank(owner);
        address[] memory result = modularQuoteVault.getRegisteredUsersAddress(100, 10);

        // Assert result length is equal to zero.
        assertEq(result.length, 0);
    }

    /// @notice Test owner cant return addresses greater than registered user.
    function testOwnerCantReturnAddressesGreaterThanRegisteredUser() external registerUser1 {
        // Write as owner.
        vm.prank(owner);
        address[] memory result = modularQuoteVault.getRegisteredUsersAddress(0, 10);

        // Assert Both are same.
        assertEq(result[0], user1);
    }

    /// @notice Test to ensure owner can get user quote at an index.
    function testOwnerCanGetUserQuoteAtIndex() external registerUser1 storeUser1Quote {
        // Write as owner.
        vm.prank(owner);
        ModularQuoteVault.Quote memory result = modularQuoteVault.getUserQuoteAtIndex(0, user1);

        // Assert result at index 0 is Equal to.
        assertEq(result.author, "Michealking BuildsWithKing");
        assertEq(result.description, "Consistency builds mastery");
        assertEq(result.category, "Self");
        assertEq(result.source, "Mindset");
        assertEq(result.personalNote, "I'm here to prove it");
    }

    /// @notice Test to ensure result returns empty array to owner once offset is greater than total quotes.
    function testResultReturnsEmptyArrayToOwner() external registerUser1 storeUser1Quote {
        // Write as owner.
        vm.prank(owner);
        ModularQuoteVault.Quote[] memory result = modularQuoteVault.getUserQuotes(user1, 100, 10);

        // Assert array length is equal to zero.
        assertEq(result.length, 0);
    }

    /// @notice Test to ensure owner can get user quotes.
    function testOwnerCanGetUserQuotes() external registerUser1 storeUser1Quote {
        // Write as owner.
        vm.prank(owner);
        ModularQuoteVault.Quote[] memory result = modularQuoteVault.getUserQuotes(user1, 0, 1);

        // Assert result at index 0 is Equal to.
        assertEq(result[0].author, "Michealking BuildsWithKing");
        assertEq(result[0].description, "Consistency builds mastery");
        assertEq(result[0].category, "Self");
        assertEq(result[0].source, "Mindset");
        assertEq(result[0].personalNote, "I'm here to prove it");
    }

    /// @notice Test to ensure owner can't return quotes greater than user's stored quotes.
    function testOwnerCantReturnQuotesGreaterThanUserTotalQuotes() external registerUser1 storeUser1Quote {
        // Write as owner.
        vm.prank(owner);
        ModularQuoteVault.Quote[] memory result = modularQuoteVault.getUserQuotes(user1, 0, 20);

        // Assert result at index 0 is Equal.
        assertEq(result[0].author, "Michealking BuildsWithKing");
        assertEq(result[0].description, "Consistency builds mastery");
        assertEq(result[0].category, "Self");
        assertEq(result[0].source, "Mindset");
        assertEq(result[0].personalNote, "I'm here to prove it");
    }
}
