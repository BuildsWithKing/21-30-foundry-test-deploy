// SPDX-License-Identifier: MIT

/// @author Michealking (BuildsWithKing)
/// @title AdvancedUserStorageTest
/// @notice Created on 15th of Aug, 2025. 

pragma solidity ^0.8.30;

/// @notice Imports Test, AdvancedUserStorage, Types and Utils.
import {Test} from "forge-std/Test.sol";
import {AdvancedUserStorage} from "../src/AdvancedUserStorage.sol";
import {Types} from "../src/Types.sol";
import {Utils} from "../src/Utils.sol";

contract AdvancedUserStorageTest is Test {

    Utils utils; 

    AdvancedUserStorage advancedUserStorage;

    /// @notice Owner's address.
    address internal owner = address(this);

    /// @notice User1's address.
    address user1 = address(0x1);

    /// @notice User2's address.
    address internal user2 = address(0x2);

    /// @notice Sets ETH amount as 0.1 ether. 
    uint256 constant ETH_AMOUNT = 0.1 ether;

    /// @notice Sets Starting as 10 ether. 
    uint256 startingBalance = 10 ether;

// ---------------------------------------- Modifiers -------------------------------------------------------
    
    /// @dev Registers user1. 
    modifier registerUser1() {

        // Write as User1. 
        vm.prank(user1);
        advancedUserStorage.store(
            "Michealking BuildsWithKing", 
            23, 
            Types.Gender.Male,
            "buildswithking@gmail.com", 
            "Solidity Developer"
        );
        _;
    }

    /// @dev Ensures data are same as stored. 
    modifier sameData() {
        
        // Read as user1. 
        vm.prank(user1);

        // Read User1 Data. 
        AdvancedUserStorage.Data memory data = 
        advancedUserStorage.getMyData();

        // Ensure user1 data are Equal. 
        assertEq(data.fullName, "Michealking BuildsWithKing");
        assertEq(data.age, 23);
        assertEq(uint8(data.gender), uint8(Types.Gender.Male));
        assertEq(data.email, "buildswithking@gmail.com");
        assertEq(data.skill, "Solidity Developer"); 

       _; 
    }

// ------------------------------------------ SetUp function -----------------------------------------------

    /// @notice This function runs before every other test. 
    function setUp() external {

        // Create new instance of AdvancedUserStorage. 
        advancedUserStorage = new AdvancedUserStorage();

        // Create new instance of Utils. 
        utils = new Utils();

        // Label owner, user1 and user2.
        vm.label(owner, "Owner");
        vm.label(user1, "User1");
        vm.label(user2, "User2");

        // Fund user2 with 10 ether. 
        vm.deal(user2, startingBalance);
    }

// ----------------------------------- Test for constructor and contract state ------------------------------

    /// @notice Test to ensure constructor sets owner and contract state. 
    function testConstructorSetsOwnerAndContractState() external {
        
        // Write as Owner. 
        vm.startPrank(owner);
        advancedUserStorage.getOwner();

        bool isActive = advancedUserStorage.isContractActive();

        vm.stopPrank();

        // Ensure deployer is same as owner. 
        assertEq(advancedUserStorage.getOwner(), owner);

        // Ensure both are same. 
       assertEq(isActive, true);
    } 

// ----------------------------- Test for store (edgecases) and getMyData -----------------------------------------

    /// @notice Test store and getMyData. 
    function testUserCanStoreandRetrieve() external registerUser1 sameData {

    }

    /// @notice Test for empty input. 
    function testForEmptyFullName() external {
        
        // Revert with custom error "EmptyName()". 
        vm.expectRevert(abi.encodeWithSignature("EmptyName()"));

        // Write as User 2. 
        vm.prank(user2);
        advancedUserStorage.store(
            "",
            23,
            Types.Gender.Male,
            "buildswithking@gmail.com",
            "Solidity Developer"
        );
    }

    /// @notice Test to ensure user can't register with zero age.
    function testForZeroAge() external {

        // Revert with custom error "ZeroAge()". 
        vm.expectRevert(abi.encodeWithSignature("ZeroAge()"));

        //Write as User 1.
        vm.prank(user1);
        advancedUserStorage.store(
            "Michealking BuildsWithKing", 
            0, 
            Types.Gender.Male,
            "buildswithking@gmail.com", 
            "Solidity Developer"
        );
    }

     /// @notice Test for users max age.
    function testUserMaxAge() external {
        
        // Revert with custom error "Above120()".
        vm.expectRevert(abi.encodeWithSignature("Above120()"));
       
        // Write as User2. 
        vm.prank(user2);
        advancedUserStorage.store(
            "SolidityQueen BuildsWithKing",
            125,
            Types.Gender.Female,
            "solidityQueen@gmail.com",
            "Solidity Developer"
        );
    }

    /// @notice Test for unset gender. 
    function testForUnsetGender() external {
        
        // Revert with custom error "UnsetGender()". 
        vm.expectRevert(abi.encodeWithSignature("UnsetGender()"));

        //Write as User 1.
        vm.prank(user1);
        advancedUserStorage.store(
            "Michealking BuildsWithKing", 
            23, 
            Types.Gender.Unset,
            "buildswithking@gmail.com", 
            "Solidity Developer"
        );
    }

    /// @notice Test for empty email. 
    function testForEmptyEmail() external {
       
        // Revert with custom error "EmptyEmail()". 
        vm.expectRevert(abi.encodeWithSignature("EmptyEmail()"));

        //Write as User 1.
        vm.prank(user1);
        advancedUserStorage.store(
            "Michealking BuildsWithKing", 
            23, 
            Types.Gender.Male,
            "", 
            "Solidity Developer"
        );
    }

    /// @notice Test for empty skill. 
    function testForEmptySkill() external {

        // Revert with custom error "EmptySkill()".
        vm.expectRevert(abi.encodeWithSignature("EmptySkill()"));

        //Write as User 1.
        vm.prank(user1);
        advancedUserStorage.store(
            "Michealking BuildsWithKing", 
            23, 
            Types.Gender.Male,
            "buildswithking@gmail.com", 
            ""
        );
    }

    /// @notice Test to ensure no duplicate registration. 
    function testRegisteredUserCantReRegister() external registerUser1 {
       
       // Revert with custom error "AlreadyRegistered()". 
        vm.expectRevert(abi.encodeWithSignature("AlreadyRegistered()"));

        // Write as user1. 
        vm.prank(user1);
        advancedUserStorage.store(
            "Michealking BuildsWithKing", 
            23, 
            Types.Gender.Male,
            "buildswithking@gmail.com", 
            "Solidity Developer"
        );
    }

// ---------------------------- Test for all update function. -----------------------------------------------


    /// @notice Test to ensure users can update details. 
    function testUserCanUpdateData() external registerUser1 {

        // Write as user 1.
        vm.startPrank(user1);
        advancedUserStorage.updateMyFullName("BuildsWithKing");
        advancedUserStorage.updateMyAge(25);
        advancedUserStorage.updateMyGender(Types.Gender.Female);
        advancedUserStorage.updateMyEmail("SolidityKing@gmail.com");
        advancedUserStorage.updateMySkill("Solidity Engineer");

        AdvancedUserStorage.Data memory data = advancedUserStorage.getMyData();

        // Stop prank.  
        vm.stopPrank();

        // Ensure both are same. 
        assertEq(data.fullName, "BuildsWithKing");
        assertEq(data.age, 25);
        assertEq(uint8(data.gender),uint8(Types.Gender.Female));
        assertEq(data.email, "SolidityKing@gmail.com");
        assertEq(data.skill, "Solidity Engineer");
    }

    /// @notice Test to ensure users can't update with empty or blank details. 
    function testUserCantUpdateWithBlankOrZero() external registerUser1 {
       
        // Revert with custom error "EmptyName()".
        vm.expectRevert(abi.encodeWithSignature("EmptyName()"));
        vm.startPrank(user1);
        advancedUserStorage.updateMyFullName("");

        // Revert with custom error "SameName()".
        vm.expectRevert(abi.encodeWithSignature("SameName()"));
        advancedUserStorage.updateMyFullName("Michealking BuildsWithKing");

        // Revert with custom error "ZeroAge()".
        vm.expectRevert(abi.encodeWithSignature("ZeroAge()"));
        advancedUserStorage.updateMyAge(0);

        // Revert with custom error "Above120()".
        vm.expectRevert(abi.encodeWithSignature("Above120()"));
        advancedUserStorage.updateMyAge(125);

        // Revert with custom error "SameAge()". 
        vm.expectRevert(abi.encodeWithSignature("SameAge()"));
        advancedUserStorage.updateMyAge(23);

        // Revert with custom error "UnsetGender()".
        vm.expectRevert(abi.encodeWithSignature("UnsetGender()"));
        advancedUserStorage.updateMyGender(Types.Gender.Unset);

        // Revert with custom error "SameGender()".
        vm.expectRevert(abi.encodeWithSignature("SameGender()"));
        advancedUserStorage.updateMyGender(Types.Gender.Male);

        // Revert with custom error "EmptyEmail()".
        vm.expectRevert(abi.encodeWithSignature("EmptyEmail()"));
        advancedUserStorage.updateMyEmail("");

        // Revert with custom error "SameEmail()".
        vm.expectRevert(abi.encodeWithSignature("SameEmail()"));
        advancedUserStorage.updateMyEmail("buildswithking@gmail.com");

        // Revert with custom error "EmptySkill()".
        vm.expectRevert(abi.encodeWithSignature("EmptySkill()"));
        advancedUserStorage.updateMySkill("");
        
        // Revert with custom error "SameSkill()".
        vm.expectRevert(abi.encodeWithSignature("SameSkill()"));
        advancedUserStorage.updateMySkill("Solidity Developer");

        vm.stopPrank();
    }

// -------------------------- Test for read functions(edgecases). ---------------------------------------

    /// @notice Test to ensure users can't access other user's data. 
    function testUserCantAccessAnotherUserData() external registerUser1 {

        // Revert with custom error "Unauthorized()", since user is not user1. 
        vm.expectRevert(abi.encodeWithSignature("Unauthorized()"));

        // Get User1 Data. 
        vm.prank(user2);
        advancedUserStorage.getUserData(user1);
    }

    /// @notice Test for getMySkill. 
    function testGetMySkill() external registerUser1 {

        // Read as user1. 
        vm.prank(user1);
        string memory skill = advancedUserStorage.getMySkill();

        // Ensure skill is same as Solidity developer. 
        assertEq(skill, "Solidity Developer");
    }

    /// @notice Test for getMyGender male. 
    function testGetMyGenderMale() external registerUser1 {

        // Read as User1. 
        vm.prank(user1);
        string memory gender = advancedUserStorage.getMyGender();

        // Ensure Gender is same as male. 
        assertEq(gender, "Male");
    }

    /// @notice Test for getMyGender female. 
    function testGetMyGenderFemale() external {

        // Write as user 2. 
        vm.startPrank(user2);
        advancedUserStorage.store(
            "SolidityQueen BuildsWithKing",
            25,
            Types.Gender.Female,
            "solidityQueen@gmail.com",
            "Solidity Developer"
        );

        // Read User1's gender. 
        string memory gender = advancedUserStorage.getMyGender();

        // Stop prank. 
        vm.stopPrank();

        // Ensure Gender is same as female. 
        assertEq(gender, "Female");
    }

    /// Test getMyGender unset. 
    function testGetMyGenderUnset() external {
       
        // Read as User2. 
        vm.prank(user2);
        string memory gender = advancedUserStorage.getMyGender();

        // Ensure Gender is same as unset. 
        assertEq(gender, "Unset");
    }

    /// @notice Test for getOwner. 
    function testGetOwner() external {

        // Read as user1. 
        vm.prank(user1);
        address contractOwner = advancedUserStorage.getOwner();

        // ensure both are same. 
        assertEq(contractOwner, owner);
    }

    /// @notice Test for checkMyRegistrationStatus. 
    function testCheckMyRegistrationStatus() external registerUser1 {

        // Read as user1. 
        vm.prank(user1);
        bool isRegistered = advancedUserStorage.checkMyRegistrationStatus();

        // Ensure isRegistered is equal true. 
        assertEq(isRegistered, true);
    }

    /// @notice Test for nonRegisteredUserStatus. 
    function testNonRegisteredUserStatus() external {

        // Return false since user2 is not registered. 
        vm.prank(user2);
        bool isRegistered = advancedUserStorage.checkMyRegistrationStatus();

        // Ensure isRegistered is equal false. 
        assertEq(isRegistered, false);
    }

    /// @notice Test for getTotalRegisteredUser. 
    function testGetTotalRegisteredUser() external registerUser1 {

        // Read usercount as user1. 
        vm.prank(user1);
        uint256 userCount = advancedUserStorage.getTotalRegisteredUsers();

        // Ensure Both are same. 
        assertEq(userCount, 1);
    }

// ------------------------------- Test for deleteMyData function & Edgecases. -----------------------------------------

     // Test for deleteMyData. 
    function testUserCanDeleteData() external registerUser1 {

        // Write as user1. 
        vm.prank(user1);

        // Delete user1's data. 
        advancedUserStorage.deleteMyData();
        
        // Get User1 Data. 
        AdvancedUserStorage.Data memory data = advancedUserStorage.getMyData();

        // Return empty values. 
        assertEq(data.fullName, "");
        assertEq(data.age, 0);
        assertEq(uint8(data.gender), uint8(Types.Gender.Unset));
        assertEq(data.email, "");
        assertEq(data.skill, ""); 

        // Read userCount. 
        uint256 userCount = advancedUserStorage.getTotalRegisteredUsers();

        // Ensure both are same.
        assertEq(userCount, 0);
    }
    
    /// @notice Test to ensure only active users can be deleted.
    function testUserDataIndexNotFoundCantBeDeleted() external registerUser1 {

        // Write as user1. 
        vm.prank(user1);

        // Delete user1's data. 
        advancedUserStorage.deleteMyData();

        // Revert with error, since user no longer exist. 
        vm.expectRevert(abi.encodeWithSignature("NotRegistered()"));
        vm.startPrank(owner);
        advancedUserStorage.deleteUserData(user1);
    }

    /// @notice Test to ensure only registered users can delete data. 
    function testToEnsureOnlyRegisteredUserCanDeleteData() external {
        
        // Revert with custom error. 
        vm.expectRevert(abi.encodeWithSignature("NotRegistered()"));

        vm.prank(user2);
        advancedUserStorage.deleteMyData();
    }

// --------------------------------------- Test for owner only functions ----------------------------------

    /// @notice Test for DeleteUserData. 
    function testOwnerCanDeleteUserData() external registerUser1 {

        // Act as owner. 
        vm.startPrank(owner);

         // Check user1's registration status. 
        bool isRegistered = advancedUserStorage.checkIfRegistered(user1);

        // Ensure isRegistered is equal true. 
        assertEq(isRegistered, true);

        // Delete user1's data. 
        advancedUserStorage.deleteUserData(user1);
        
        // Read userCount. 
        uint256 userCount = advancedUserStorage.getTotalRegisteredUsers();

        // Stop prank.
        vm.stopPrank();

        // Ensure Both are same. 
        assertEq(userCount, 0);
    }

    /// @notice Test for only owner can get registered users addresses.
    function testOnlyOwnerCanGetRegisteredUserAddress() external registerUser1 {

        // Revert with custom error "Unauthorized()". 
        vm.expectRevert(abi.encodeWithSignature("Unauthorized()"));

        // Write as user2. 
        vm.prank(user2);
        advancedUserStorage.getRegisteredUserAddresses(0,1);
    }


    /// @notice Test for getRegisteredUserAddresses. 
    function testGetRegisteredUserAddresses() external registerUser1 {

        // Retrieve address as owner. 
        vm.startPrank(owner);
        address[] memory result = advancedUserStorage.getRegisteredUserAddresses(0, 1);
        
        // Ensure result length is one. 
        assertEq(result.length, 1);

        // Ensure in result index one is user1. 
        assertEq(result[0], user1);

        // Delete user1. 
        advancedUserStorage.deleteUserData(user1);

        // Retrieve again with limit 1. 
        address[] memory afterDelete = advancedUserStorage.getRegisteredUserAddresses(0,1);

        // Assert that array is now empty. 
        assertEq(afterDelete.length, 0);

        // Stop prank. 
        vm.stopPrank();
    }

     /// @notice Test for getRegisteredUserAddressesWithNoRegisteredUser. 
    function testGetRegisteredUserAddressesWithNoRegistedUser() external {
        
        // Retrieve address as owner. 
        vm.startPrank(owner);
        advancedUserStorage.getRegisteredUserAddresses(10, 5);
    }

    /// @notice Test for GetUserData. 
   function testOwnerCanGetUserData() external registerUser1 {
        // Write as Owner. 
        vm.prank(owner);

        // Get User1 Data. 
        AdvancedUserStorage.Data memory data = advancedUserStorage.getUserData(user1);

        // Ensure both are same. 
        assertEq(data.fullName, "Michealking BuildsWithKing");
        assertEq(data.age, 23);
        assertEq(uint8(data.gender), uint8(Types.Gender.Male));
        assertEq(data.email, "buildswithking@gmail.com");
        assertEq(data.skill, "Solidity Developer"); 
    }

// -------------------------------- Receive function --------------------------------------------
   //// @notice Receives ETH. 
   receive() payable external {
   }
}