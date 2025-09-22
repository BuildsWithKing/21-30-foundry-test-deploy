// SPDX-License-Identifier: MIT

/// @title BaseTest (BaseTest contract for FlexiWhitelist).
/// @author Michealking (@BuildsWithKing).
/// @notice Created on the 19th of Sept, 2025.

pragma solidity ^0.8.18;

/// @notice Imports Test from forge standard library, Types, Utils, WhitelistManager, Flexiwhitelist and RejectETHTest contract.
import {Test} from "forge-std/Test.sol";
import {Types} from "../../src/Types.sol";
import {Utils} from "../../src/Utils.sol";
import {WhitelistManager} from "../../src/WhitelistManager.sol";
import {FlexiWhitelist} from "../../src/FlexiWhitelist.sol";
import {RejectETHTest} from "./RejectETHTest.t.sol";

contract BaseTest is Test {
    // -------------------------------------------------- State variables ---------------------------------
    /// @notice Assigns flexiWhitelist & rejector.
    FlexiWhitelist flexiWhitelist;
    RejectETHTest rejector;

    /// @notice Assigns king, user1 and user2.
    address internal king = address(0x10);
    address internal user1 = address(0x1);
    address internal user2 = address(0x2);

    /// @notice Assigns STARTING_BALANCE & ETH_AMOUNT
    uint256 internal constant STARTING_BALANCE = 10 ether;
    uint256 internal constant ETH_AMOUNT = 1 ether;

    // --------------------------------------------------- Setup function -----------------------------------
    /// @notice This function runs before every other function.
    function setUp() external {
        // Create new instance of FlexiWhitelist.
        flexiWhitelist = new FlexiWhitelist(king);

        // Label king, user1 & user2.
        vm.label(king, "KING");
        vm.label(user1, "USER1");
        vm.label(user2, "USER2");

        // Fund 10 ETH to user2.
        vm.deal(user2, STARTING_BALANCE);
    }

    // ---------------------------------------------------- Constructor -----------------------------------------

    /// @notice Test to ensure constructor sets king at deployment.
    function testConstructorSetsKing_AtDeployment() external view {
        // Assert current king is equal to king.
        assertEq(flexiWhitelist.currentKing(), king);
    }

    // ------------------------------------------------------ Internal helper functions ---------------------------
    /// @notice Registers user1.
    function _registerUser1() internal {
        // Prank as user1.
        vm.prank(user1);
        vm.expectEmit(true, true, false, false);
        emit Utils.Registered(1, user1);
        flexiWhitelist.registerForWhitelist();
    }

    /// @notice Registers user2.
    function _registerUser2() internal {
        // Prank as user2.
        vm.prank(user2);
        vm.expectEmit(true, true, false, false);
        emit Utils.Registered(2, user2);
        flexiWhitelist.registerForWhitelist();
    }

    /// @notice Whitelists user1. Callable by the king.
    function _whitelistUser1() internal {
        // Prank as king.
        vm.prank(king);
        vm.expectEmit(true, false, false, false);
        emit Utils.Whitelisted(user1);
        flexiWhitelist.whitelistUserAddress(user1);
    }

    // ----------------------------------------------------- Test for users write functions --------------------------------

    /// @notice Test to ensure users can successfully register for whitelist.
    function testRegisterForWhitelist_Succeeds() external {
        // Call internal helper function.
        _registerUser1();

        // Prank as user1.
        vm.prank(user1);
        // Assign user1's status
        bool status = flexiWhitelist.checkMyRegistrationStatus();

        // Assert both are equal.
        assertEq(status, true);
    }

    /// @notice Test to ensure users can register only once.
    function testRegisterForWhitelist_RevertsAlreadyRegistered() external {
        // Call internal helper function.
        _registerUser1();

        // Revert `AlreadyRegistered`.
        vm.expectRevert(Utils.AlreadyRegistered.selector);
        vm.prank(user1);
        flexiWhitelist.registerForWhitelist();
    }

    /// @notice Test users can successfully unregister.
    function testUnregisterForWhitelist_Succeeds() external {
        // Call internal helper function.
        _registerUser1();

        // Prank as user1.
        vm.startPrank(user1);
        vm.expectEmit(true, false, false, false);
        emit Utils.Unregistered(user1);
        flexiWhitelist.unregisterForWhitelist();

        // Assign user1's status.
        bool status = flexiWhitelist.checkMyRegistrationStatus();

        // Stop prank.
        vm.stopPrank();

        // Assert both are equal.
        assertEq(status, false);
    }

    /// @notice Test to ensure once a user unregisters, index swaps correctly.
    function testUnregisterForWhitelist_SwapsCorrectly() external {
        // Assign user3.
        address user3 = address(0x3);

        // Call internal _registerUser1 function.
        _registerUser1();

        // Call internal _registerUser2 function.
        _registerUser2();

        // Prank as user3.
        vm.prank(user3);
        flexiWhitelist.registerForWhitelist();

        // Prank as user2.
        vm.prank(user2);
        flexiWhitelist.unregisterForWhitelist();

        // Assign userCount.
        uint256 userCount = flexiWhitelist.getExistingUsersCount();

        // Prank and get registered users as king.
        vm.prank(king);
        address[] memory userAddresses = flexiWhitelist.getRegisteredUsers(0, 3);

        // Assert both are same.
        assertEq(userCount, 2);
        assertEq(userAddresses[0], user1);
        assertEq(userAddresses[1], user3);
    }

    /// @notice Test only registered users can unregister.
    function testUnregisterForWhitelist_RevertsNotRegistered() external {
        /*  Prank as user2. 
            Revert `NotRegistered`. */
        vm.expectRevert(Utils.NotRegistered.selector);
        vm.prank(user2);
        flexiWhitelist.unregisterForWhitelist();
    }

    /// @notice Test to ensure users can't unregister when contract is paused.
    function testUnregisterForWhitelist_RevertsPausedContract() external {
        // Call _registerUser1 internal function.
        _registerUser1();

        // Prank and pause contract as king.
        vm.prank(king);
        flexiWhitelist.pauseContract();

        // Revert `PausedContract`.
        vm.expectRevert(Utils.PausedContract.selector);
        vm.prank(user1);
        flexiWhitelist.unregisterForWhitelist();
    }

    /// @notice Test to ensure users can claim ETH mistakenly sent.
    function testWithdrawMistakenETH_Succeeds() external {
        /*  Emit event `EthDeposited`
            Prank and deposit as user2. */
        vm.startPrank(user2);
        vm.expectEmit(true, true, false, false);
        emit Utils.EthDeposited(user2, ETH_AMOUNT);
        (bool success,) = payable(address(flexiWhitelist)).call{value: ETH_AMOUNT}("");
        assertTrue(success);

        // Assign balance before.
        uint256 balanceBefore = address(flexiWhitelist).balance;

        /*  Emit event `EthClaimed` 
            & Withdraw as user2. */
        vm.expectEmit(true, true, false, false);
        emit Utils.EthClaimed(user2, ETH_AMOUNT);
        flexiWhitelist.withdrawMistakenETH();

        // Stop prank.
        vm.stopPrank();

        // Assign balance after.
        uint256 balanceAfter = address(flexiWhitelist).balance;

        // Assert balance after is less than balance before.
        assertLt(balanceAfter, balanceBefore);
    }

    /// @notice Test to ensure users with zero balance can't withdraw.
    function testWithdrawMistakenETH_RevertsInsufficientFunds() external {
        /* Prank as user1. 
            & Revert `InsufficientFunds`. */
        vm.prank(user1);
        vm.expectRevert(Utils.InsufficientFunds.selector);
        flexiWhitelist.withdrawMistakenETH();
    }

    /// @notice Test to ensure `ClaimFailed` reverts for failed ETH claim.
    function testWithdrawMistakenETH_RevertsClaimFailed() external {
        // Create new instance of RejectETHTest.
        rejector = new RejectETHTest();

        // Fund rejector 10 ETH.
        vm.deal(address(rejector), STARTING_BALANCE);

        // Prank and deposit as rejector.
        vm.startPrank(address(rejector));
        (bool success,) = payable(address(flexiWhitelist)).call{value: ETH_AMOUNT}("");
        assertTrue(success);

        // Assign balance before.
        uint256 balanceBefore = address(flexiWhitelist).balance;

        /* Withdraw as rejector.
            Revert `ClaimFailed` */
        vm.expectRevert(Utils.ClaimFailed.selector);
        flexiWhitelist.withdrawMistakenETH();

        // Stop prank.
        vm.stopPrank();

        // Assign balance after.
        uint256 balanceAfter = address(flexiWhitelist).balance;

        // Assert balance after is equal to balance before.
        assertEq(balanceAfter, balanceBefore);
    }
}
