// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title BasicKycV2UnitTest.
/// @author Michealking (@BuildsWithKing).
/// @notice Created on the 29th of Oct, 2025.

/// @notice Imports Types, Utils, BasicKycV2, and BaseTest contract.
import {Types} from "../../src/Types.sol";
import {Utils} from "../../src/Utils.sol";
import {BasicKycV2} from "../../src/BasicKycV2.sol";
import {BaseTest} from "../BaseTest.t.sol";

contract BasicKycV2UnitTest is BaseTest {
    // -------------------------------------- Unit Test: Users Write Functions ---------------------------
    /// @notice Test to ensure users can successfully register their data.
    function testRegisterMyData_Succeeds() public {
        // Call the internal `_registerUser1` function.
        _registerUser1();

        // Assert user1's registration status is equal to true.
        assertEq(basicKycV2.userRegistrationStatus(USER1), true);
    }

    /// @notice Test to ensure users can register only once.
    function testRegisterMyData_RevertsAlreadyRegistered() public {
        // Call the internal `_registerUser1` function.
        _registerUser1();

        // Revert since user1 is already registered.
        vm.expectRevert(Utils.AlreadyRegistered.selector);
        vm.prank(USER1);
        basicKycV2.registerMyData(USER1_HASH);

        // Assert user1's registration status is equal to true.
        assertEq(basicKycV2.userRegistrationStatus(USER1), true);
    }

    /// @notice Test to ensure users can successfully update their data.
    function testUpdateMyData_Succeeds() public {
        // Call the internal `_registerUser1` function.
        _registerUser1();

        // Emit the event "UserDataUpdated", prank and update data as User1.
        vm.expectEmit(true, true, true, false);
        emit Types.UserDataUpdated(
            basicKycV2.userId(USER1), USER1, 0x8f9e8d7c6b5a493827161514131211100f0e0d0c0b0a09080706050403020100
        );
        vm.startPrank(USER1);
        basicKycV2.updateMyData(0x8f9e8d7c6b5a493827161514131211100f0e0d0c0b0a09080706050403020100);

        // Assign user1's data.
        Types.User memory userData = basicKycV2.myData();

        // Assert user1's data is equal to the new data.
        assertEq(userData.dataHash, 0x8f9e8d7c6b5a493827161514131211100f0e0d0c0b0a09080706050403020100);

        // Stop the prank.
        vm.stopPrank();
    }

    /// @notice Test to ensure users can't update with the same data.
    function testUpdateMyData_RevertsSameData() public {
        // Call the internal `_registerUser1` function.
        _registerUser1();

        // Call the internal `_registerUser2` function.
        _registerUser2();

        // Revert since the data is the same as the previous data.
        vm.expectRevert(Utils.SameData.selector);
        vm.prank(USER2);
        basicKycV2.updateMyData(USER2_HASH);
    }

    /// @notice Test to ensure only registered users can update their data.
    function testUpdateMyData_RevertsNotRegistered() public {
        // Revert since user3 isn't registered.
        vm.expectRevert(Utils.NotRegistered.selector);
        vm.prank(USER3);
        basicKycV2.updateMyData(0x9a8b7c6d5e4f3a2b1c0d0e0f1a2b3c4d5e6f7081928374655647382910a0b0c0);
    }

    /// @notice Test to ensure users can successfully unregister.
    function testUnregisterMyData_Succeeds() public {
        // Call the internal `_registerUser1` function.
        _registerUser1();

        // Call the internal `_registerUser2` function.
        _registerUser2();

        // Prank and verify user2 as the admin.
        vm.prank(ADMIN);
        basicKycV2.verifyUser(USER2);

        // Emit the event "UserUnregistered", prank and unregister as user2.
        vm.expectEmit(true, true, false, false);
        emit Types.UserUnregistered(basicKycV2.userId(USER2), USER2);
        vm.prank(USER2);
        basicKycV2.unregisterMyData();

        // Assert user2's registration status is equal to false.
        assertEq(basicKycV2.userRegistrationStatus(USER2), false);
    }

    /// @notice Test to ensure the contract rejects ETH.
    function testContract_RejectsETH() public {
        // Revert since the contract rejects ETH.
        vm.expectRevert();
        vm.prank(USER3);
        payable(address(basicKycV2)).call{value: ETH_AMOUNT}("");
    }

    // ---------------------------------------------- Unit Test: Users Read Functions ------------------------------
    /// @notice Test to ensure users can view their data.
    function testMyData_Returns() public {
        // Call the internal `_registerUser1` function.
        _registerUser1();

        // Call the internal `_registerUser2` function.
        _registerUser2();

        // Prank and return data as user2.
        vm.prank(USER2);
        Types.User memory userData = basicKycV2.myData();

        // Assert both are the same.
        assertEq(userData.id, 2);
        assertEq(userData.isRegistered, true);
        assertEq(userData.isVerified, false);
        assertEq(userData.dataHash, USER2_HASH);
        assertEq(userData.registeredAt, block.timestamp);
        assertEq(userData.verifiedAt, 0);
    }

    /// @notice Test to ensure users can view their registration status.
    function testMyRegistrationStatus_Returns() public {
        // Prank and return registration status as user3.
        vm.prank(USER3);
        bool status = basicKycV2.myRegistrationStatus();

        // Assert user3's registration status is equal to false.
        assertEq(status, false);
    }

    /// @notice Test to ensure users can view other users registration status.
    function testUserRegistrationStatus_Returns() public {
        // Call the internal `_registerUser1` function.
        _registerUser1();

        // Prank and return user registration status as user2.
        vm.prank(USER2);
        bool status = basicKycV2.userRegistrationStatus(USER1);

        // Assert user1's registration status is equal to true.
        assertEq(status, true);
    }

    /// @notice Test to ensure users can view their registration time.
    function testMyRegistrationTimestamp_Returns() public {
        // Call the internal `_registerUser1` function.
        _registerUser1();

        // Prank and return registration time as user1.
        vm.prank(USER1);
        uint256 time = basicKycV2.myRegistrationTimestamp();

        // Assert user1's registration time is equal to the current time.
        assertEq(time, block.timestamp);
    }

    /// @notice Test to ensure users can view other users registration time.
    function testUserRegistrationTimestamp_Returns() public {
        // Call the internal `_registerUser1` function.
        _registerUser1();

        // Prank and return user registration time as user3.
        vm.prank(USER3);
        uint256 time = basicKycV2.userRegistrationTimestamp(USER1);

        // Assert user1's registration time is equal to the current time.
        assertEq(time, block.timestamp);
    }

    /// @notice Test to ensure users can view their verification status.
    function testMyVerificationStatus_Returns() public {
        // Prank and return verification status as user3.
        vm.prank(USER3);
        bool status = basicKycV2.myVerificationStatus();

        // Assert user3's verification status is equal to false.
        assertEq(status, false);
    }

    /// @notice Test to ensure users can view other users verification status.
    function testUserVerificationStatus_Returns() public {
        // Call the internal `_registerUser1` function.
        _registerUser1();

        // Prank and return user verification status as user3.
        vm.prank(USER3);
        bool status = basicKycV2.userVerificationStatus(USER1);

        // Assert user1's verification status is equal to false.
        assertEq(status, false);
    }

    /// @notice Test to ensure users can view their verification timestamp.
    function testMyVerificationTimestamp_Returns() public {
        // Call the internal `_registerUser1` function.
        _registerUser1();

        // Call the internal `_verifyUser1` function.
        _verifyUser1();

        // Prank and return verification time as user1.
        vm.prank(USER1);
        uint256 time = basicKycV2.myVerificationTimestamp();

        // Assert user1's verification time is equal to the current time.
        assertEq(time, block.timestamp);
    }

    /// @notice Test to ensure users can view other users verification time.
    function testUserVerificationTimestamp_Returns() public {
        // Call the internal `_registerUser1` function.
        _registerUser1();

        // Call the internal `_verifyUser1` function.
        _verifyUser1();

        // Prank and return user verification time as user3.
        vm.prank(USER3);
        uint256 time = basicKycV2.userVerificationTimestamp(USER1);

        // Assert user1's verification time is equal to the current time.
        assertEq(time, block.timestamp);
    }

    /// @notice Test to ensure users can view their id.
    function testMyId_Returns() public {
        // Call the internal `_registerUser1` function.
        _registerUser1();

        // Prank and return id as user1.
        vm.prank(USER1);
        uint64 id = basicKycV2.myId();

        // Assert user1's Id is equal to 1.
        assertEq(id, 1);
    }

    /// @notice Test to ensure users can view other users id.
    function testUserId_Returns() public {
        // Call the internal `_registerUser1` function.
        _registerUser1();

        // Call the internal `_registerUser2` function.
        _registerUser2();

        // Prank and return user id as user1.
        vm.prank(USER1);
        uint64 id = basicKycV2.userId(USER2);

        // Assert user2's Id is equal to 2.
        assertEq(id, 2);
    }
}
