// SPDX-License-Identifier: MIT

/// @title KingUtilsTest (King and Utils Test contract for FlexiWhitelist).
/// @author Michealking (@BuildsWithKing).
/// @notice Created on the 20th of Sept, 2025.

pragma solidity ^0.8.30;

/// @notice Imports BaseTest, Types, Utils and FlexiWhitelist contract.
import {BaseTest} from "./BaseTest.t.sol";
import {Types} from "../../src/Types.sol";
import {Utils} from "../../src/Utils.sol";
import {FlexiWhitelist} from "../../src/FlexiWhitelist.sol";

contract KingUtilsTest is BaseTest {
    // -------------------------------------------------------- Test for king's write functions ------------------------------
    /// @notice Test to ensure king can whitelist users.
    function testWhitelistUserAddress_Succeeds() external {
        // Call _registerUser1 internal function.
        _registerUser1();

        // Call _whitelistUser1 internal function.
        _whitelistUser1();

        // Prank as king.
        vm.prank(king);
        // Assign status.
        Types.WhitelistStatus status = flexiWhitelist.checkIfWhitelisted(user1);

        // Assert user1's whitelist status is 1 (Whitelisted).
        assertEq(uint8(status), 1);
    }

    /// @notice Test to ensure king can't whitelist users more than once.
    function testWhitelistUserAddress_RevertsAlreadyWhitelisted() external {
        // Call _registerUser1 internal function.
        _registerUser1();

        // Call _whitelistUser1 internal function.
        _whitelistUser1();

        // Revert `AlreadyWhitelisted`.
        vm.expectRevert(Utils.AlreadyWhitelisted.selector);
        vm.prank(king);
        flexiWhitelist.whitelistUserAddress(user1);
    }

    /// @notice Test to ensure king can revoke users whitelist.
    function testRevokeUserWhitelist_Succeeds() external {
        // Call _registerUser1 internal function.
        _registerUser1();

        // Call _whitelistUser1 internal function.
        _whitelistUser1();

        // Prank as king.
        vm.startPrank(king);
        vm.expectEmit(true, true, false, false);
        emit Utils.WhitelistRevoked(king, user1);
        flexiWhitelist.revokeUserWhitelist(user1);

        // Assign status.
        Types.WhitelistStatus status = flexiWhitelist.checkIfWhitelisted(user1);

        // Stop prank.
        vm.stopPrank();

        // Assert user1's whitelist status is 0 (NotWhitelisted).
        assertEq(uint8(status), 0);
    }

    /// @notice Test to ensure king can't revoke users whitelist more than once.
    function testRevokeUserWhitelist_RevertsAlreadyNotWhitelisted() external {
        // Call _registerUser1 internal function.
        _registerUser1();

        // Call _whitelistUser1 internal function.
        _whitelistUser1();

        // Prank as king.
        vm.prank(king);
        vm.expectEmit(true, true, false, false);
        emit Utils.WhitelistRevoked(king, user1);
        flexiWhitelist.revokeUserWhitelist(user1);

        // Revert `AlreadyNotWhitelisted`.
        vm.expectRevert(Utils.AlreadyNotWhitelisted.selector);
        vm.prank(king);
        flexiWhitelist.revokeUserWhitelist(user1);
    }

    /// @notice Test to ensure king can't activate contract once it's active.
    function testActivateContract_RevertsAlreadyActive() external {
        // Revert `AlreadyActive`.
        vm.expectRevert(Utils.AlreadyActive.selector);
        vm.prank(king);
        flexiWhitelist.activateContract();
    }

    /// @notice Test to ensure king can pause and activate contract.
    function testPause_ActivateContract_Succeeds() external {
        // Prank as king.
        vm.prank(king);
        vm.expectEmit(true, false, false, false);
        emit Utils.ContractPaused(king);
        flexiWhitelist.pauseContract();

        // Prank as king.
        vm.prank(king);
        vm.expectEmit(true, false, false, false);
        emit Utils.ContractActivated(king);
        flexiWhitelist.activateContract();
    }

    /// @notice Test to ensure king can't pause contract once it's paused.
    function testPauseContract_RevertsAlreadyPaused() external {
        // Prank as king.
        vm.prank(king);
        vm.expectEmit(true, false, false, false);
        emit Utils.ContractPaused(king);
        flexiWhitelist.pauseContract();

        vm.expectRevert(Utils.AlreadyPaused.selector);
        vm.prank(king);
        flexiWhitelist.pauseContract();
    }

    // ---------------------------------------------------- Test for king's read functions --------------------------------------------------
    /// @notice Test to ensure king can get registered users.
    function testGetRegisteredUsers_Returns() external {
        // Call _registerUser1 internal function.
        _registerUser1();

        // Call _registerUser2 internal function.
        _registerUser2();

        // Prank as king.
        vm.prank(king);
        // Assign userAddresses.
        address[] memory userAddresses = flexiWhitelist.getRegisteredUsers(0, 2);

        // Assert user1's address is at index zero.
        assertEq(userAddresses[0], user1);

        // Assert user2's address is at index one.
        assertEq(userAddresses[1], user2);
    }

    /// @notice Test to ensure king can't input high offset on getRegisteredUsers.
    function testGetRegisteredUsers_RevertsHighOffset() external {
        // Revert `HighOffset`.
        vm.expectRevert(Utils.HighOffset.selector);
        vm.prank(king);
        flexiWhitelist.getRegisteredUsers(100, 2);
    }

    /// @notice Test to ensure king can get whitelisted users.
    function testGetWhitelistedUsers_Returns() external {
        // Call _registerUser1 internal function.
        _registerUser1();

        // Call _registerUser2 internal function.
        _registerUser2();

        // Call _whitelistUser1 internal function.
        _whitelistUser1();

        // Prank as king.
        vm.prank(king);
        // Assign whitelistedUsers.
        address[] memory whitelistedUsers = flexiWhitelist.getWhitelistedUsers(0, 1);

        // Assert user1 is at index zero of whitelisted users.
        assertEq(whitelistedUsers[0], user1);
    }

    /// @notice Test to ensure king can't input high offset on getWhitelistedUsers.
    function testGetWhitelistedUsers_RevertsHighOffset() external {
        // Call _registerUser1 internal function.
        _registerUser1();

        // Call _registerUser2 internal function.
        _registerUser2();

        // Call _whitelistUser1 internal function.
        _whitelistUser1();

        // Revert `HighOffset`.
        vm.expectRevert(Utils.HighOffset.selector);
        vm.prank(king);
        flexiWhitelist.getWhitelistedUsers(100, 2);
    }

    /// @notice Test to ensure get whitelisted users returns empty array.
    function testGetWhitelistedUsers_ReturnsEmptyArray() external {
        // Prank as king.
        vm.prank(king);
        address[] memory whitelistedUsers = flexiWhitelist.getWhitelistedUsers(10, 50);

        // Assert whitelisted users length is equal to zero.
        assertEq(whitelistedUsers.length, 0);
    }

    // ---------------------------------------------------- Test for receive and fallback function. ---------------------------------

    /// @notice Test to ensure users can't deposit zero ETH.
    function testReceive_Reverts() external {
        // Revert `AmountTooLow`.
        vm.expectRevert(Utils.AmountTooLow.selector);
        // Prank as user1.
        vm.startPrank(user1);
        (bool success,) = payable(address(flexiWhitelist)).call{value: 0}("");

        // Assert contract balance is equal to zero.
        assertEq(flexiWhitelist.checkContractBalance(), 0);
    }

    /// @notice Test to ensure users can deposit ETH with call data.
    function testFallback_Succeeds() external {
        // Assign balanceBefore.
        uint256 balanceBefore = address(flexiWhitelist).balance;

        // Prank as user2.
        vm.startPrank(user2);
        vm.expectEmit(true, true, false, false);
        emit Utils.EthDeposited(user2, ETH_AMOUNT);
        (bool success,) = payable(address(flexiWhitelist)).call{value: ETH_AMOUNT}(
            hex"55241077000000000000000000000000000000000000000000000000000000000000007b"
        );
        assertTrue(success);

        // Stop prank.
        vm.stopPrank();

        // Assign balanceAfter.
        uint256 balanceAfter = address(flexiWhitelist).balance;

        // Assert balance after is greater than balance before.
        assertGt(balanceAfter, balanceBefore);
    }
}
