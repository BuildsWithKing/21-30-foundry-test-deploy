// SPDX-License-Identifier: MIT

/// @title WhiteListTest (WhitelistTest contract for FlexiWhitelist).
/// @author Michealking (@BuildsWithKing).
/// @notice Created on the 20th of Sept, 2025.

pragma solidity ^0.8.30;

/// @notice Imports BaseTest, Types, Utils, and FlexiWhitelist contract.
import {BaseTest} from "./BaseTest.t.sol";
import {Types} from "../../src/Types.sol";
import {Utils} from "../../src/Utils.sol";
import {FlexiWhitelist} from "../../src/FlexiWhitelist.sol";

contract WhitelistTest is BaseTest {
    // ----------------------------------------------- Test for users read functions. -------------------------------------
    /// @notice Test to ensure users can check their registration status.
    function testCheckMyRegistrationStatus_Returns() external {
        // Prank as user2.
        vm.prank(user2);
        bool status = flexiWhitelist.checkMyRegistrationStatus();

        // Assert user2's registration status is equal to false.
        assertEq(status, false);
    }

    /// @notice Test to ensure users can check their whitelist status.
    function testCheckMyWhitelistStatus_Returns() external {
        // Call internal _registerUser1 function.
        _registerUser1();

        // Prank as user1.
        vm.prank(user1);
        Types.WhitelistStatus status = flexiWhitelist.checkMyWhitelistStatus();

        // Assert user1's status is equal to zero (NotWhitelisted).
        assertEq(uint8(status), 0);
    }

    /// @notice Test to ensure users can check the whitelist status of another.
    function testCheckIfWhitelisted_Returns() external {
        // Call internal _registerUser1 function.
        _registerUser1();

        // Prank as user2.
        vm.prank(user2);
        Types.WhitelistStatus status = flexiWhitelist.checkIfWhitelisted(user1);

        // Assert user1's status is equal to zero (NotWhitelisted).
        assertEq(uint8(status), 0);
    }

    /// @notice Test to ensure users can check their balance.
    function testCheckMyBalance_Returns() external {
        // prank as user2.
        vm.prank(user2);
        uint256 myBalance = flexiWhitelist.checkMyBalance();

        // Assert user2's balance is equal to zero.
        assertEq(myBalance, 0);
    }

    /// @notice Test to ensure users can check contract state.
    function testIsContractActive_Returns() external {
        //Prank as user1.
        vm.prank(user1);
        // Assign state.
        bool state = flexiWhitelist.isContractActive();

        // Assert contract state is active (true);
        assertEq(state, true);
    }

    /// @notice Test to ensure users can check contract balance.
    function testCheckContractBalance_Returns() external {
        // Prank as user2.
        vm.startPrank(user2);
        (bool success,) = payable(address(flexiWhitelist)).call{value: ETH_AMOUNT}("");
        assertTrue(success);

        // Assign contractBalance.
        uint256 contractBalance = flexiWhitelist.checkContractBalance();

        // Stop prank.
        vm.stopPrank();

        // Assert contract balance is equal to 1 ETH.
        assertEq(contractBalance, ETH_AMOUNT);
    }

    /// @notice Test to ensure users can get existing users count.
    function testGetExistingUserCount_Returns() external {
        // Call internal _registerUser1 function.
        _registerUser1();

        // Prank as user1.
        vm.prank(user1);
        flexiWhitelist.unregisterForWhitelist();

        // Prank as user 2.
        vm.startPrank(user2);
        flexiWhitelist.registerForWhitelist();

        // Assign existingUsers.
        uint256 existingUsers = flexiWhitelist.getExistingUsersCount();

        // Stop prank.
        vm.stopPrank();

        // Assert existing users is equal to 1.
        assertEq(existingUsers, 1);
    }

    /// @notice Test to ensure users can get life time users count.
    function testGetLifeTimeUsers_Returns() external {
        // Call internal _registerUser1 function.
        _registerUser1();

        // Prank as user1.
        vm.prank(user1);
        flexiWhitelist.unregisterForWhitelist();

        // Prank as user 2.
        vm.startPrank(user2);
        flexiWhitelist.registerForWhitelist();

        // Assign lifetimeUsers.
        uint256 lifetimeUsers = flexiWhitelist.getLifetimeUsers();

        // Stop prank.
        vm.stopPrank();

        // Assert lifetime users is equal to 2.
        assertEq(lifetimeUsers, 2);
    }
}
