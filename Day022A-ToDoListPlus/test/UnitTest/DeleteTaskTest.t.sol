// SPDX-License-Identifier: MIT

/// @title ToDoListPlus (DeleteTask Unit Test Contract).
/// @author Michealking (@BuildsWithKing).
/* @notice Created on the 9th of Sept, 2025.

    This contract contains all delete task function tests. 
*/

pragma solidity ^0.8.30;

/// @notice Imports BaseTest, ToDoListPlus, Utils and Types contract.
import {BaseTest} from "./BaseTest.t.sol";
import {ToDoListPlus} from "../../src/ToDoListPlus.sol";
import {Utils} from "../../src/Utils.sol";
import {Types} from "../../src/Types.sol";

contract DeleteTaskTest is BaseTest {
    // --------------------------- Test for deleteMyTask function. ---------------------------

    /// @notice Test to ensure users can delete their task.
    function testUserCanDeleteTask() external writeUser1TaskZero {
        // Write as user1.
        vm.startPrank(user1);
        vm.expectEmit(true, true, false, false);
        emit Utils.TaskDeleted(user1, 0);
        toDoListPlus.deleteMyTask(0);

        // Revert with "OutOfBounds".
        vm.expectRevert(Utils.OutOfBounds.selector);
        toDoListPlus.getMyTaskAtIndex(0);

        // Stop writing as user1.
        vm.stopPrank();
    }

    /// @notice Test to ensure deleteMyData swaps and pops.
    function testDeleteMyDataSwapsAndPops() external writeUser1TaskZero {
        // Write as user1.
        vm.startPrank(user1);
        toDoListPlus.addMyTask(
            "Day022 ToDoListPlus",
            "Spend Minimum of 3 hours daily on Day022 project A",
            Types.TaskPriority.High,
            Types.TaskCategory.Personal,
            block.timestamp + TWO_DAYS
        );

        // Add user1's task.
        toDoListPlus.addMyTask(
            "Day022B WhiteListDapp",
            "Spend Minimum of 4 hours daily on Day022 project B",
            Types.TaskPriority.High,
            Types.TaskCategory.Personal,
            block.timestamp + FIVE_DAYS
        );

        // Emit TaskDeleted.
        vm.expectEmit(true, true, false, false);
        emit Utils.TaskDeleted(user1, 1);
        toDoListPlus.deleteMyTask(1);

        // Stop writing as user1.
        vm.stopPrank();
    }

    // --------------------------- Test for deleteAllMyTasks function. ----------------------------

    /// @notice Test to ensure users can delete all their tasks.
    function testUserCanDeleteAllTheirTask() external writeUser1TaskZero writeUser1TaskOne writeUser1TaskTwo {
        // Write as user1.
        vm.startPrank(user1);

        // Assign getExistingTasks before deletion.
        uint256 existingTasksBeforeDeletion = toDoListPlus.getExistingTasks();

        // Emit DeletedAllTask.
        vm.expectEmit(true, false, false, false);
        emit Utils.DeletedAllTask(user1);
        toDoListPlus.deleteAllMyTasks();

        // Assign getExistingTasks after deletion.
        uint256 existingTasksAfterDeletion = toDoListPlus.getExistingTasks();

        // Stop writing as user1.
        vm.stopPrank();

        // Assert Existing tasks before deletion is greater than after deletion.
        assertGt(existingTasksBeforeDeletion, existingTasksAfterDeletion);
    }

    /// @notice Test to ensure users with no task can't delete tasks.
    function testUserWithNoTaskCantDelete() external {
        // Revert with "NoTask".
        vm.expectRevert(Utils.NoTask.selector);
        vm.prank(user2);
        toDoListPlus.deleteAllMyTasks();
    }

    /// @notice Test to ensure tasksCount safely resets to zero.
    function testTasksCountResetSafelyToZero() external writeUser1TaskZero writeUser1TaskOne writeUser1TaskTwo {
        // Write as user1.
        vm.startPrank(user1);

        // Emit DeletedAllTask.
        vm.expectEmit(true, false, false, false);
        emit Utils.DeletedAllTask(user1);
        toDoListPlus.deleteAllMyTasks();

        // Assign taskCount.
        uint256 existingTask = toDoListPlus.getExistingTasks();

        // Assert existingTask is equal zero.
        assertEq(existingTask, 0);
    }

    // ---------------------------------- Test For getMyTasks function. ---------------------------------------

    /// @notice Test to ensure users can get their tasks.
    function testUserCanGetTasks() external writeUser1TaskZero writeUser1TaskOne writeUser1TaskTwo {
        // Write as user1.
        vm.prank(user1);
        ToDoListPlus.Task[] memory tasks = toDoListPlus.getMyTasks(0, 3);

        // Assert both are same.
        assertEq(tasks[0].title, "Day022 ToDoListPlus");
        assertEq(tasks[0].description, "Spend Minimum of 6 hours daily on Day022 project A");
        assertEq(tasks[1].title, "Day022 ToDoListPlus");
        assertEq(tasks[1].description, "Spend Minimum of 3 hours daily on Day022 project A");
        assertEq(tasks[2].title, "Day022B WhiteListDapp");
        assertEq(tasks[2].description, "Spend Minimum of 4 hours daily on Day022 project B");
    }

    /// @notice Test to ensure users high offset input reverts.
    function testHighOffSetReverts() external writeUser1TaskZero {
        // Revert with HighOffset.
        vm.expectRevert(Utils.HighOffset.selector);
        vm.prank(user1);
        toDoListPlus.getMyTasks(1000, 30);
    }

    /// @notice Test end resets to users maximum tasks.
    function testEndResetsToUserMaximumTasks() external writeUser1TaskZero writeUser1TaskOne writeUser1TaskTwo {
        // Write as user1.
        vm.prank(user1);
        toDoListPlus.getMyTasks(1, 30);
    }

    /// @notice Test users can get their task priority.
    function testGetMyTaskPriority() external writeUser1TaskZero {
        // Write as user1.
        vm.startPrank(user1);
        string memory priority = toDoListPlus.getMyTaskPriority(0);

        vm.stopPrank();

        // Assert Both are same.
        assertEq(priority, "High");
    }

    /// @notice Test users can get their task category.
    function testGetMyTaskCategory() external writeUser1TaskZero {
        // Write as user1.
        vm.prank(user1);
        string memory category = toDoListPlus.getMyTaskCategory(0);

        // Assert Both are same.
        assertEq(category, "Personal");
    }

    /// @notice Test to ensure users can get their task count.
    function testUserCanGetTaskCount() external writeUser1TaskZero writeUser1TaskOne writeUser1TaskTwo {
        // write as user1.
        vm.prank(user1);
        uint256 myTasks = toDoListPlus.getMyTaskCount();

        // Assert totalTasks is equal 3.
        assertEq(myTasks, 3);
    }

    /// @notice Test to ensure users can get total tasks ever stored.
    function testUsersCanGetTotalTasks() external writeUser1TaskZero writeUser1TaskOne writeUser1TaskTwo {
        // write as user2.
        vm.prank(user2);
        uint256 totalTasks = toDoListPlus.getTotalTasks();

        // Assert totalTasks is equal 3.
        assertEq(totalTasks, 3);
    }

    /// @notice Test to ensure users can get only existing tasks.
    function testUsersCanGetExistingTasks() external writeUser1TaskZero writeUser1TaskOne writeUser1TaskTwo {
        // Assign existing tasks before deletion.
        uint256 existingTaskBeforeDeletion = toDoListPlus.getExistingTasks();

        // Write as user1.
        vm.prank(user1);
        toDoListPlus.deleteMyTask(1);

        // Assign existing tasks after deletion.
        vm.prank(user2);
        uint256 existingTaskAfterDeletion = toDoListPlus.getExistingTasks();

        assertLt(existingTaskAfterDeletion, existingTaskBeforeDeletion);
    }

    /// @notice Test to ensure users can get owner's addres.
    function testGetOwner() external {
        // Write as user2.
        vm.prank(user2);
        address contractOwner = toDoListPlus.getOwner();

        // Assert both are same.
        assertEq(owner, contractOwner);
    }

    /// @notice Test users can get contract state.
    function testIsContractActive() external {
        // Write as owner.
        vm.prank(owner);
        bool state = toDoListPlus.isContractActive();

        // Assert Both are same.
        assertEq(state, true);
    }
}
