// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title KingAdminUnitTest.
/// @author Michealking (@BuildsWithKing).
/// @notice Created on the 29th of Oct, 2025.

/// @notice Imports Types, Utils and BasicKycV2UnitTest contract.
import {Types} from "../../src/Types.sol";
import {Utils} from "../../src/Utils.sol";
import {BasicKycV2UnitTest} from "./BasicKycV2UnitTest.t.sol";

contract KingAdminUnitTest is BasicKycV2UnitTest {
    // ------------------------------------------------- Unit Test: King's Write Function -----------------------
    /// @notice Test to ensure the king can assign admin.
    function testAssignAdmin_Succeeds() public {
        // Assign admin2
        address admin2 = address(50);

        // Emit the event "AdminAssigned", and Prank as the King.
        vm.expectEmit(true, false, false, false);
        emit Types.AdminAssigned(admin2);
        vm.prank(KING);
        basicKycV2.assignAdmin(admin2);

        // Assert admin2 is the current admin.
        assertEq(basicKycV2.s_admin(), admin2);
    }

    /// @notice Test to ensure the king can't assign the current admin as the new admin.
    function testAssignAdmin_RevertsSameAdmin() public {
        // Revert since the address is the current admin's address.
        vm.expectRevert(abi.encodeWithSelector(Utils.SameAdmin.selector, ADMIN));
        vm.prank(KING);
        basicKycV2.assignAdmin(ADMIN);
    }

    /// @notice Test to ensure the king can't assign the zero or this contract address as the admin.
    function testAssignAdmin_RevertsInvalidAddress() public {
        // Revert since the address is the zero address.
        vm.expectRevert(abi.encodeWithSelector(Utils.InvalidAddress.selector, ZERO));
        vm.prank(KING);
        basicKycV2.assignAdmin(ZERO);

        // Revert since the address is this contract address.
        vm.expectRevert(abi.encodeWithSelector(Utils.InvalidAddress.selector, address(basicKycV2)));
        vm.prank(KING);
        basicKycV2.assignAdmin(address(basicKycV2));
    }

    /// @notice Test to ensure only the king can assign admin.
    function testAssignAdmin_RevertsUnauthorized() public {
        // Revert since user3 isn't the king.
        vm.expectRevert();
        vm.prank(USER3);
        basicKycV2.assignAdmin(USER3);
    }

    // ---------------------------------------------- Unit Test: King & Admin's Write Functions ------------------------------
    /// @notice Test to ensure the admin can verify users.
    function testVerifyUser_Succeeds() public {
        // Call the internal `_registerUser1` function.
        _registerUser1();

        // Call the internal `_registerUser2` function.
        _registerUser2();

        // Emit the event "UserVerified", and Prank as the Admin.
        vm.expectEmit(true, true, true, false);
        emit Types.UserVerified(2, USER2, ADMIN);
        vm.prank(ADMIN);
        basicKycV2.verifyUser(USER2);

        // Assert user2's verification status is equal to true.
        assertEq(basicKycV2.userVerificationStatus(USER2), true);
    }

    /// @notice Test to ensure only registered users can be verified.
    function testVerifyUser_RevertsNotRegistered() public {
        // Revert since user3 isn't registered.
        vm.expectRevert(Utils.NotRegistered.selector);
        vm.prank(KING);
        basicKycV2.verifyUser(USER3);
    }

    /// @notice Test to ensure the admin and the king can verify users only once.
    function testVerifyUser_RevertsAlreadyVerified() public {
        // Call the internal `_registerUser1` function.
        _registerUser1();

        // Call the internal `_verifyUser1` function.
        _verifyUser1();

        // Revert since user1 is already verified.
        vm.expectRevert(Utils.AlreadyVerified.selector);
        vm.prank(ADMIN);
        basicKycV2.verifyUser(USER1);
    }

    /// @notice Test to ensure only the king and the admin can verify users.
    function testVerifyUser_RevertsAccessDenied() public {
        // Call the internal `_registerUser1` function.
        _registerUser1();

        // Call the internal `_registerUser2` function.
        _registerUser2();

        // Revert since user2 isn't the admin or the king.
        vm.expectRevert(Utils.AccessDenied.selector);
        vm.prank(USER2);
        basicKycV2.verifyUser(USER2);
    }

    /// @notice Test to ensure the king and the admin can verify many users.
    function testVerifyManyUsers_Succeeds() public {
        // Call the internal `_registerMultipleUsers` function.
        _registerMultipleUsers();

        // Assign users and create a new array for 3 users.
        address[] memory users = new address[](3);
        users[0] = USER1;
        users[1] = USER2;
        users[2] = USER3;

        // Prank and verify many users as the KING.
        vm.prank(KING);
        basicKycV2.verifyManyUsers(users);

        // Assert user1's, user2's and user3's verification status is equal to true.
        assertEq(basicKycV2.userVerificationStatus(USER1), true);
        assertEq(basicKycV2.userVerificationStatus(USER2), true);
        assertEq(basicKycV2.userVerificationStatus(USER3), true);
    }

    /// @notice Test to ensure the king and admin can successfully unverify users.
    function testUnverifyUser_Succeeds() public {
        // Call the internal `_registerUser1` function.
        _registerUser1();

        // Call the internal `_verifyUser1` function.
        _verifyUser1();

        // Emit the event "UserUnverified", and Prank as the Admin.
        vm.expectEmit(true, true, true, false);
        emit Types.UserUnverified(1, USER1, ADMIN);
        vm.prank(ADMIN);
        basicKycV2.unverifyUser(USER1);

        // Assert user1's verification status is equal to false.
        assertEq(basicKycV2.userVerificationStatus(USER1), false);
    }

    /// @notice Test to ensure the king and the admin can unverify a user only once.
    function testUnverifyUser_RevertsAlreadyUnverified() public {
        // Call the internal `_registerUser1` function.
        _registerUser1();

        // Call the internal `_verifyUser1` function.
        _verifyUser1();

        // Prank and unverify user1 as the admin.
        vm.prank(ADMIN);
        basicKycV2.unverifyUser(USER1);

        // Revert since user1 is already unverified.
        vm.expectRevert(Utils.AlreadyUnverified.selector);
        vm.prank(KING);
        basicKycV2.unverifyUser(USER1);

        // Assert user1's verification status is equal to false.
        assertEq(basicKycV2.userVerificationStatus(USER1), false);
    }

    /// @notice Test to ensure only the king and admin can unverify users.
    function testUnverifyUser_RevertsAccessDenied() public {
        // Call the internal `_registerUser1` function.
        _registerUser1();

        // Call the internal `_registerUser2` function.
        _registerUser2();

        // Call the internal `_verifyUser1` function.
        _verifyUser1();

        // Revert since user3 isn't the king or the admin.
        vm.expectRevert(Utils.AccessDenied.selector);
        vm.prank(USER3);
        basicKycV2.unverifyUser(USER1);
    }

    /// @notice Test to ensure the king and admin can unverify many users.
    function testUnverifyManyUsers_Succeeds() public {
        // Call the internal `_registerMultipleUsers` function.
        _registerMultipleUsers();

        // Assign users and create a new array for 3 users.
        address[] memory users = new address[](3);
        users[0] = USER1;
        users[1] = USER2;
        users[2] = USER3;

        // Prank and verify many users as the ADMIN.
        vm.prank(ADMIN);
        basicKycV2.verifyManyUsers(users);

        // Prank and unverify many users as the KING.
        vm.prank(KING);
        basicKycV2.unverifyManyUsers(users);

        // Assert user1's, user2's and user3's verification status is equal to false.
        assertEq(basicKycV2.userVerificationStatus(USER1), false);
        assertEq(basicKycV2.userVerificationStatus(USER2), false);
        assertEq(basicKycV2.userVerificationStatus(USER3), false);
    }

    // ---------------------------------------------- Unit Test: King & Admin's Read Functions ------------------------------
    /// @notice Test to ensure the king and admin can view users data.
    function testGetUserData_Returns() public {
        // Call the internal `_registerUser1` function.
        _registerUser1();

        // Call the internal `_registerUser2` function.
        _registerUser2();

        // Prank and return user data as the admin.
        vm.prank(ADMIN);
        Types.User memory userData = basicKycV2.getUserData(USER2);

        // Assert both are the same.
        assertEq(userData.id, 2);
        assertEq(userData.isRegistered, true);
        assertEq(userData.isVerified, false);
        assertEq(userData.dataHash, USER2_HASH);
        assertEq(userData.registeredAt, block.timestamp);
        assertEq(userData.verifiedAt, 0);
    }

    /// @notice Test to ensure the admin and the king can view registered users.
    function testGetRegisteredUsers_Returns() public {
        // Call the internal `_registerMultipleUsers` function.
        _registerMultipleUsers();

        // Prank and return registered users as the king.
        vm.prank(KING);
        address[] memory users = basicKycV2.getRegisteredUsers(1, 3);

        // Assert each registered user is at the respective index.
        assertEq(users[0], USER1);
        assertEq(users[1], USER2);
        assertEq(users[2], USER3);
    }

    /// @notice Test to ensure the king and the admin can't view any registered user, when no user is registered.
    function testGetRegisteredUsers_RevertsNoRegisteredUser() public {
        // Revert since no user is registered.
        vm.expectRevert(Utils.NoRegisteredUser.selector);
        vm.prank(ADMIN);
        basicKycV2.getRegisteredUsers(1, 3);
    }

    /// @notice Test to ensure the king and admin can't input zero as the start Id.
    function testGetRegisteredUsers_RevertsInvalidRange() public {
        // Call the internal `_registerUser1` function.
        _registerUser1();

        // Call the internal `_registerUser2` function.
        _registerUser2();

        // Revert since zero is not a valid id.
        vm.expectRevert(Utils.InvalidRange.selector);
        vm.prank(KING);
        basicKycV2.getRegisteredUsers(0, 3);
    }

    /// @notice Test to ensure the endId resets to lifetime users.
    function testGetRegisteredUsers_ResetsEndId() public {
        // Call the internal `_registerMultipleUsers` function.
        _registerMultipleUsers();

        // Prank and return registered users as the admin.
        vm.prank(ADMIN);
        address[] memory users = basicKycV2.getRegisteredUsers(1, 500);

        // Assert each registered user is at the respective index.
        assertEq(users[0], USER1);
        assertEq(users[1], USER2);
        assertEq(users[2], USER3);
    }

    /// @notice Test to ensure the king and the admin can't input an endId greater than 1000.
    function testGetRegisteredUsers_RevertsHugeEndId() public {
        // Call the internal `_registerUser1` function.
        _registerUser1();

        // Call the internal `_registerUser2` function.
        _registerUser2();

        // Revert since the endId is greater than 1000.
        vm.expectRevert(Utils.HugeEndId.selector);
        vm.prank(KING);
        basicKycV2.getRegisteredUsers(1, 5000);
    }

    /// @notice Test to ensure the admin and the king can view verified users.
    function testGetVerifiedUsers_Returns() public {
        // Call the internal `_registerUser1` function.
        _registerUser1();

        // Call the internal `_registerUser2` function.
        _registerUser2();

        // Call the internal `_verifyUser1` function.
        _verifyUser1();

        // Prank and verify user2 as the admin.
        vm.prank(ADMIN);
        basicKycV2.verifyUser(USER2);

        // Prank and return verified users as the king.
        vm.prank(KING);
        address[] memory users = basicKycV2.getVerifiedUsers(1, 2);

        // Assert each verified user is at the respective index.
        assertEq(users[0], USER1);
        assertEq(users[1], USER2);
    }

    /// @notice Test to ensure the king and the admin can't view any verified user, when no user is verified.
    function testGetVerifiedUsers_RevertsNoVerifiedUser() public {
        // Revert since no user is verified.
        vm.expectRevert(Utils.NoVerifiedUser.selector);
        vm.prank(ADMIN);
        basicKycV2.getVerifiedUsers(1, 3);
    }

    /// @notice Test to ensure the king and admin can't input zero as the start Id.
    function testGetVerifiedUsers_RevertsInvalidRange() public {
        // Call the internal `_registerUser1` function.
        _registerUser1();

        // Call the internal `_registerUser2` function.
        _registerUser2();

        // Call the internal `_verifyUser1` function.
        _verifyUser1();

        // Revert since zero is not a valid id.
        vm.expectRevert(Utils.InvalidRange.selector);
        vm.prank(KING);
        basicKycV2.getVerifiedUsers(0, 3);
    }

    /// @notice Test to ensure the endId resets to lifetime users.
    function testGetVerifiedUsers_ResetsEndId() public {
        // Call the internal `_registerUser1` function.
        _registerUser1();

        // Call the internal `_registerUser2` function.
        _registerUser2();

        // Call the internal `_verifyUser1` function.
        _verifyUser1();

        // Prank and verify user2 as the king.
        vm.prank(KING);
        basicKycV2.verifyUser(USER2);

        // Prank and return verified users as the admin.
        vm.prank(ADMIN);
        address[] memory users = basicKycV2.getVerifiedUsers(1, 500);

        // Assert each verified user is at the respective index.
        assertEq(users[0], USER1);
        assertEq(users[1], USER2);
    }

    /// @notice Test to ensure the king and the admin can't input an endId greater than 1000.
    function testGetVerifiedUsers_RevertsHugeEndId() public {
        // Call the internal `_registerUser1` function.
        _registerUser1();

        // Call the internal `_registerUser2` function.
        _registerUser2();

        // Call the internal `_verifyUser1` function.
        _verifyUser1();

        // Revert since the endId is greater than 1000.
        vm.expectRevert(Utils.HugeEndId.selector);
        vm.prank(KING);
        basicKycV2.getVerifiedUsers(1, 5000);
    }

    /// @notice Test to ensure only the king and the admin can view verified users.
    function testGetVerifiedUsers_RevertsAccessDenied() public {
        // Call the internal `_registerUser1` function.
        _registerUser1();

        // Call the internal `_registerUser2` function.
        _registerUser2();

        // Call the internal `_verifyUser1` function.
        _verifyUser1();

        // Revert since user3 isn't the king or the admin.
        vm.expectRevert(Utils.AccessDenied.selector);
        vm.prank(USER3);
        basicKycV2.getVerifiedUsers(1, 3);
    }
}
