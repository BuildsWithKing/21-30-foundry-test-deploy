// SPDX-License-Identifier: MIT

/// @title KingUtilsTest (King's read and utility test contract for SimpleBankX).
/// @author Michealking (@BuildsWithKing).
/// @notice Created on the 1st of Oct, 2025.

pragma solidity ^0.8.30;

/// @notice Imports BaseTest, and Utils contract.
import {BaseTest} from "../BaseTest.t.sol";
import {Utils} from "../../src/Utils.sol";

contract KingUtilsTest is BaseTest {
    // ------------------------------------------------- Test for King's read function ---------------------------------
    /// @notice Test to ensure king can get registered users address.
    function testGetRegisteredUsers_Returns() public {
        // Call internal `_registerUser1` helper function.
        _registerUser1();

        // Call internal `_registerUser2` helper function.
        _registerUser2();

        // Call internal `_registerUser3` helper function.
        _registerUser3();

        // Prank and getRegisteredUsers as KING.
        vm.prank(KING);
        address[] memory userAddresses = simpleBankX.getRegisteredUsers(0, 3);

        // Assert USER1, USER2 and USER3 index on userAddresses array.
        assertEq(userAddresses[0], USER1);
        assertEq(userAddresses[1], USER2);
        assertEq(userAddresses[2], USER3);
    }

    /// @notice Test to ensure `getRegisteredUser` returns empty array.
    function testGetRegisteredUsers_ReturnsEmptyArray() public {
        // Prank and getRegisteredUsers as KING.
        vm.prank(KING);
        address[] memory userAddresses = simpleBankX.getRegisteredUsers(5, 3);

        // Assert array length is equal to zero.
        assertEq(userAddresses.length, 0);
    }

    /// @notice Test to ensure `HighOffset` reverts.
    function testGetRegisteredUsers_RevertsHighOffset() public {
        // Call internal `_registerUser1` helper function.
        _registerUser1();

        // Revert HighOffset, since registered users are less than 50.
        vm.expectRevert(Utils.HighOffset.selector);
        // Prank and getRegisteredUsers as KING.
        vm.prank(KING);
        simpleBankX.getRegisteredUsers(50, 3);
    }

    /// @notice Test to ensure `HighLimit` reverts.
    function testGetRegisteredUsers_RevertsHighLimit() public {
        // Call internal `_registerUser1` helper function.
        _registerUser1();

        // Revert HighLimit, since registered users are less than 1010.
        vm.expectRevert(Utils.HighLimit.selector);
        // Prank and getRegisteredUsers as KING.
        vm.prank(KING);
        simpleBankX.getRegisteredUsers(0, 1010);
    }

    // ------------------------------------------------- Test for receive and fallback function ---------------------------------------
    /// @notice Test to ensure receive handles ETH without calldata.
    function testReceive_Succeeds() public {
        // Call internal `_registerUser1` helper function.
        _registerUser1();

        // Prank and deposit as USER1.
        vm.prank(USER1);
        (bool success,) = address(simpleBankX).call{value: ETH_AMOUNT}("");
        assertTrue(success);

        // Assert USER1's balance increases.
        assertEq(simpleBankX.checkUserBalance(USER1), ETH_AMOUNT);
    }

    /// @notice Test to ensure users can't deposit zero ETH via Receive.
    function testReceive_RevertsAmountTooLow() public {
        // Call internal `_registerUser1` helper function.
        _registerUser1();

        // Revert AmountTooLow, if USER1 tries depositing zero ETH.
        vm.expectRevert(Utils.AmountTooLow.selector);
        vm.prank(USER1);
        (bool success,) = address(simpleBankX).call{value: 0}("");
        assertTrue(success);
    }

    /// @notice Test to ensure only registered users can deposit ETH via receive.
    function testReceive_RevertsNotRegistered() public {
        // Revert NotRegistered, since USER2 haven't registered.
        vm.expectRevert(Utils.NotRegistered.selector);
        vm.prank(USER2);
        (bool success,) = address(simpleBankX).call{value: ETH_AMOUNT}("");
        assertTrue(success);
    }

    /// @notice Test to ensure fallback handles ETH with calldata.
    function testFallback_Succeeds() public {
        // Call internal `_registerUser1` helper function.
        _registerUser1();

        // Prank and deposit as USER1.
        vm.prank(USER1);
        (bool success,) = address(simpleBankX).call{value: ETH_AMOUNT}(
            hex"77641345000000000000000000000000000000000000000000000000000000000000008d"
        );
        assertTrue(success);

        // Assert USER1's balance increases.
        assertEq(simpleBankX.checkUserBalance(USER1), ETH_AMOUNT);
    }

    /// @notice Test to ensure users can't deposit zero ETH via fallback.
    function testFallback_RevertsAmountTooLow() public {
        // Call internal `_registerUser1` helper function.
        _registerUser1();

        // Revert AmountTooLow, if USER1 tries depositing zero ETH.
        vm.expectRevert(Utils.AmountTooLow.selector);
        vm.prank(USER1);
        (bool success,) = address(simpleBankX).call{value: 0}(
            hex"77641345000000000000000000000000000000000000000000000000000000000000008d"
        );
        assertTrue(success);
    }

    /// @notice Test to ensure only registered users can deposit ETH via fallback.
    function testFallback_RevertsNotRegistered() public {
        // Revert NotRegistered, since USER2 haven't registered.
        vm.expectRevert(Utils.NotRegistered.selector);
        vm.prank(USER2);
        (bool success,) = address(simpleBankX).call{value: ETH_AMOUNT}(
            hex"77641345000000000000000000000000000000000000000000000000000000000000008d"
        );
        assertTrue(success);
    }
}
