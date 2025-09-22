// SPDX-License-Identifier: MIT

/// @title FlexiWhitelistFuzzTest (FuzzTest for FlexiWhitelist contract).
/// @author Michealking (@BuildsWithKing).
/// @notice Created on the 20th of Sept, 2025.

pragma solidity ^0.8.30;

/// @notice Imports BaseTest and Utils contract.
import {BaseTest} from "../UnitTest/BaseTest.t.sol";
import {Utils} from "../../src/Utils.sol";

contract FlexiWhitelistFuzzTest is BaseTest {
    // ------------------------------------------- Private helper function. --------------------------------------
    /// @notice Private helper function that assumes and prank as different users.
    function _assumeAndPrank(address _userAddress) private {
        // Assume _userAddress passes all conditions below.
        vm.assume(
            _userAddress != address(this) && _userAddress != address(0) && _userAddress != address(flexiWhitelist)
                && _userAddress != king && _userAddress != address(0xdead)
        );

        // Prank as different users.
        vm.prank(_userAddress);
        flexiWhitelist.registerForWhitelist();
    }

    // ---------------------------------------------------------- Fuzz test for users write functions -----------------------------

    /// @notice Fuzz test to ensure multiple users can register and unregister successfully.
    /// @param _userAddress The user's address.
    function testFuzz_RegisterAndUnregister(address _userAddress) external {
        // Call private _assumeAndPrank helper function.
        _assumeAndPrank(_userAddress);

        // Prank as different users.
        vm.prank(_userAddress);
        flexiWhitelist.unregisterForWhitelist();
    }

    /// @notice Fuzz test to ensure multiple users can fund contract and withdraw back their ETH.
    /// @param _userAddress The user's address.
    function testFuzz_WithdrawMistakenETH(address _userAddress) external {
        // Call private _assumeAndPrank helper function.
        _assumeAndPrank(_userAddress);

        // Fund 10 ETH to _userAddress.
        vm.deal(_userAddress, STARTING_BALANCE);

        // Prank and deposit as _userAddress.
        vm.startPrank(_userAddress);
        (bool success,) = payable(address(flexiWhitelist)).call{value: ETH_AMOUNT}("");
        assertTrue(success);

        // Assign balance before.
        uint256 balanceBefore = address(flexiWhitelist).balance;

        // Withdraw as _userAddress.
        flexiWhitelist.withdrawMistakenETH();

        // Stop prank.
        vm.stopPrank();

        // Assign balance after.
        uint256 balanceAfter = address(flexiWhitelist).balance;

        // Assert balance before is greater than balance after.
        assertGt(balanceBefore, balanceAfter);

        // Assert users balance is greater than starting balance subtracted by eth amount.
        assertGt(_userAddress.balance, STARTING_BALANCE - ETH_AMOUNT);
    }

    /// @notice Fuzz test to ensure multiple users with zero balance can't withdraw ETH.
    /// @param _userAddress The user's address.
    function testFuzz_WithdrawMistakenETH_RevertsInsufficientFunds(address _userAddress) external {
        // Call private _assumeAndPrank helper function.
        _assumeAndPrank(_userAddress);

        // Revert `InsufficientFunds`.
        vm.expectRevert(Utils.InsufficientFunds.selector);
        vm.prank(_userAddress);
        flexiWhitelist.withdrawMistakenETH();
    }

    // -------------------------------------------------------- King's write function --------------------------------

    /// @notice Fuzz test to ensure _end resets to total registered users count.
    /// @param _userAddress The user's address.
    /// @param _offset The starting index.
    /// @param _limit The maximum numbers of users.
    function testFuzz_GetRegisteredUsers_EndBound(address _userAddress, uint256 _offset, uint256 _limit) external {
        // Call private _assumeAndPrank helper function.
        _assumeAndPrank(_userAddress);

        // Bound _offset minimum as 0, maximum as 0.
        _offset = uint256(bound(_offset, 0, 0));

        // Bound _limit minimum as 1, maximum as 100.
        _limit = uint256(bound(_limit, 1, 100));

        // Prank and get registered users as king.
        vm.prank(king);
        address[] memory userAddresses = flexiWhitelist.getRegisteredUsers(_offset, _limit);

        // Assert _userAddress is at index zero in the array.
        assertEq(userAddresses[0], _userAddress);
    }

    /// @notice Fuzz test to ensure _end resets to total whitelisted users address.
    /// @param _userAddress The user's address.
    /// @param _offset The starting index.
    /// @param _limit The maximum numbers of users.
    function testFuzz_GetWhitelistedUsers_EndBound(address _userAddress, uint256 _offset, uint256 _limit) external {
        // Call internal _assumeAndPrank helper function.
        _assumeAndPrank(_userAddress);

        // Bound _offset minimum as 0, maximum as 0.
        _offset = uint256(bound(_offset, 0, 0));

        // Bound _limit minimum as 1, maximum as 100.
        _limit = uint256(bound(_limit, 1, 100));

        // Prank and whitelist users as king.
        vm.prank(king);
        flexiWhitelist.whitelistUserAddress(_userAddress);

        // Prank and get whitelisted users as king.
        vm.prank(king);
        address[] memory whitelistedUser = flexiWhitelist.getWhitelistedUsers(_offset, _limit);

        // Assert _userAddress is at index zero in the array.
        assertEq(whitelistedUser[0], _userAddress);
    }
}
