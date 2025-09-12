// SPDX-License-Identifier: MIT

/// @title ToDoListPlus (StatusTask Unit Test Contract).
/// @author Michealking (@BuildsWithKing).
/**
 * @notice Created on the 9th of Sept, 2025.
 *
 *    This contract contains all status, priority and category function tests.
 */
pragma solidity ^0.8.30;

/// @notice Imports BaseTest, ToDoListPlus, Utils, Types contract.
import {BaseTest} from "./BaseTest.t.sol";
import {ToDoListPlus} from "../../src/ToDoListPlus.sol";
import {Utils} from "../../src/Utils.sol";
import {Types} from "../../src/Types.sol";

contract StatusTaskTest is BaseTest {
    // --------------------------- Test for markTaskAsCompleted function. ---------------------

    /// @notice Test to ensure users can mark task as completed.
    function testUserCanMarkTaskAsCompleted() external writeUser1TaskZero {
        // Write as user1.
        vm.startPrank(user1);
        toDoListPlus.markMyTaskAsCompleted(0);

        // Assign user1's task status.
        string memory status = toDoListPlus.getMyTaskStatus(0);

        // Stop writing as user1.
        vm.stopPrank();

        // Assert both are same.
        assertEq(status, "Completed");
    }

    /// @notice Test to ensure users can't mark task as completed twice.
    function testUserCantMarkTaskAsCompletedTwice() external writeUser1TaskZero {
        // Write as user1.
        vm.startPrank(user1);
        toDoListPlus.markMyTaskAsCompleted(0);

        // Revert with "AlreadyCompleted".
        vm.expectRevert(Utils.AlreadyCompleted.selector);
        toDoListPlus.markMyTaskAsCompleted(0);

        // Stop writing as user1.
        vm.stopPrank();
    }

    // --------------------------- Test for markTaskAsCancelled function. ----------------------

    /// @notice Test to ensure users can mark task as cancelled.
    function testUserCanMarkTaskAsCancelled() external writeUser1TaskZero {
        // Write as user1.
        vm.startPrank(user1);
        toDoListPlus.markMyTaskAsCancelled(0);

        // Assign user1's task status.
        string memory status = toDoListPlus.getMyTaskStatus(0);

        // Stop writing as user1.
        vm.stopPrank();

        // Assert both are same.
        assertEq(status, "Cancelled");
    }

    /// @notice Test to ensure users can't mark task as cancelled twice.
    function testUserCantMarkTaskAsCancelledTwice() external writeUser1TaskZero {
        // Write as user1.
        vm.startPrank(user1);
        toDoListPlus.markMyTaskAsCancelled(0);

        // Revert with "AlreadyCancelled".
        vm.expectRevert(Utils.AlreadyCancelled.selector);
        toDoListPlus.markMyTaskAsCancelled(0);

        // Stop writing as user1.
        vm.stopPrank();
    }

    // --------------------------- Test for rescheduleMyTask function. ---------------------

    /// @notice Test to ensure users can reschedule tasks.
    function testUserCanRescheduleTask() external writeUser1TaskZero {
        // Write as user1.
        vm.startPrank(user1);
        toDoListPlus.rescheduleMyTask(0, block.timestamp + TWO_DAYS);

        // Assign user1's task status.
        string memory status = toDoListPlus.getMyTaskStatus(0);

        // Stop writing as user1.
        vm.stopPrank();

        // Assert both are same.
        assertEq(status, "Scheduled");
    }

    /// @notice Test to ensure users cant schedule time lower than timestamp length while rescheduling.
    function testUserCantScheduleTimeLowerThanTimestampLength() external writeUser1TaskZero {
        // Revert with "InvalidTimestamp".
        vm.expectRevert(Utils.InvalidTimestamp.selector);
        vm.prank(user1);
        toDoListPlus.rescheduleMyTask(0, 0);
    }

    /// @notice Test to ensure users can't schedule task to current block time.
    function testUserCantScheduleTaskToCurrentTime() external writeUser1TaskZero {
        // Revert with "InvalidTimestamp".
        vm.expectRevert(Utils.InvalidTimestamp.selector);
        vm.prank(user1);
        toDoListPlus.rescheduleMyTask(0, block.timestamp);
    }

    /// @notice Test to ensure users cant schedule task to a year plus.
    function testUserCantScheduleTimeToMoreThanAYear() external writeUser1TaskZero {
        // Revert with "InvalidTimestamp".
        vm.expectRevert(Utils.InvalidTimestamp.selector);
        vm.prank(user1);
        toDoListPlus.rescheduleMyTask(0, block.timestamp + ONE_YEAR);
    }

    /// @notice Test to ensure users can't reschedule same task twice.
    function testUserCantRescheduleSameTaskTwice() external writeUser1TaskZero {
        // Write as user1.
        vm.startPrank(user1);
        toDoListPlus.rescheduleMyTask(0, block.timestamp + TWO_DAYS);

        // Revert with "AlreadyScheduled".
        vm.expectRevert(Utils.AlreadyScheduled.selector);
        toDoListPlus.rescheduleMyTask(0, block.timestamp + TWO_DAYS);

        // Stop writing as user1.
        vm.stopPrank();
    }

    // --------------------------- Test for recurMyTask function. ---------------------

    /// @notice Test to ensure users can recur tasks.
    function testUserCanRecurTask() external writeUser1TaskZero {
        // Write as user1.
        vm.startPrank(user1);
        toDoListPlus.recurMyTask(0);

        // Assign user1's task status.
        string memory status = toDoListPlus.getMyTaskStatus(0);

        // Stop writing as user1.
        vm.stopPrank();

        // Assert both are same.
        assertEq(status, "Recurring");
    }

    /// @notice Test to ensure users can't recur same task twice.
    function testUserCantRecurSameTaskTwice() external writeUser1TaskZero {
        // Write as user1.
        vm.startPrank(user1);
        toDoListPlus.recurMyTask(0);

        // Revert with "AlreadyRecurred".
        vm.expectRevert(Utils.AlreadyRecurred.selector);
        toDoListPlus.recurMyTask(0);

        // Stop writing as user1.
        vm.stopPrank();
    }

    // --------------------------- Test for deferMyTask function. -----------------------

    /// @notice Test to ensure users can defer tasks.
    function testUserCanDeferTask() external writeUser1TaskZero {
        // Write as user1.
        vm.startPrank(user1);
        toDoListPlus.deferMyTask(0, block.timestamp + FIVE_DAYS);

        // Assign user1's task status.
        string memory status = toDoListPlus.getMyTaskStatus(0);

        // Stop writing as user1.
        vm.stopPrank();

        // Assert both are same.
        assertEq(status, "Deferred");
    }

    /// @notice Test to ensure users cant defer time lower than timestamp length while deferring.
    function testUserCantDeferTimeLowerThanTimestampLength() external writeUser1TaskZero {
        // Revert with "InvalidTimestamp".
        vm.expectRevert(Utils.InvalidTimestamp.selector);
        vm.prank(user1);
        toDoListPlus.deferMyTask(0, 0);
    }

    /// @notice Test to ensure users can't defer task to current block time.
    function testUserCantDeferTaskToCurrentTime() external writeUser1TaskZero {
        // Revert with "InvalidTimestamp".
        vm.expectRevert(Utils.InvalidTimestamp.selector);
        vm.prank(user1);
        toDoListPlus.deferMyTask(0, block.timestamp);
    }

    /// @notice Test to ensure users cant defer task to a year plus.
    function testUserCantDeferTimeToMoreThanAYear() external writeUser1TaskZero {
        // Revert with "InvalidTimestamp".
        vm.expectRevert(Utils.InvalidTimestamp.selector);
        vm.prank(user1);
        toDoListPlus.deferMyTask(0, block.timestamp + ONE_YEAR);
    }

    /// @notice Test to ensure users can't defer same task twice.
    function testUserCantDeferSameTaskTwice() external writeUser1TaskZero {
        // Write as user1.
        vm.startPrank(user1);
        toDoListPlus.deferMyTask(0, block.timestamp + FIVE_DAYS);

        // Revert with "AlreadyDeferred".
        vm.expectRevert(Utils.AlreadyDeferred.selector);
        toDoListPlus.deferMyTask(0, block.timestamp + FIVE_DAYS);

        // Stop writing as user1.
        vm.stopPrank();
    }
}
