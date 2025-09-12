// SPDX-License-Identifier: MIT

/// @title ToDoListPlus (UpdateTask Unit Test Contract).
/// @author Michealking (@BuildsWithKing).
/**
 * @notice Created on the 9th of Sept, 2025.
 *
 *    This contract contains all updateTask function tests.
 */
pragma solidity ^0.8.30;

/// @notice Imports BaseTest, ToDoListPlus, Utils and Types contract.
import {BaseTest} from "./BaseTest.t.sol";
import {ToDoListPlus} from "../../src/ToDoListPlus.sol";
import {Utils} from "../../src/Utils.sol";
import {Types} from "../../src/Types.sol";

contract UpdateTaskTest is BaseTest {
    // ---------------------------------- Test for all update function. --------------------------

    /// @notice Test to ensure users can update task title.
    function testUserCanUpdateTaskTitle() external writeUser1TaskZero {
        // Write as user1.
        vm.startPrank(user1);
        vm.expectEmit(true, true, true, false);
        emit Utils.TitleUpdated(user1, 0, "ToDoListPro");
        toDoListPlus.updateMyTaskTitle(0, "ToDoListPro");

        // Assign user1's task.
        ToDoListPlus.Task memory task = toDoListPlus.getMyTaskAtIndex(0);

        // Stop writing as user1.
        vm.stopPrank();

        // Assert both are same.
        assertEq(task.title, "ToDoListPro");
    }

    /// @notice Test to ensure users can update task description.
    function testUserCanUpdateTaskDescription() external writeUser1TaskZero {
        // Write as user1.
        vm.startPrank(user1);
        vm.expectEmit(true, true, true, false);
        emit Utils.DescriptionUpdated(user1, 0, "Remember to take breaks while working on Day22 project A");
        toDoListPlus.updateMyTaskDescription(0, "Remember to take breaks while working on Day22 project A");

        // Assign user1's task.
        ToDoListPlus.Task memory task = toDoListPlus.getMyTaskAtIndex(0);

        // Stop writing as user1.
        vm.stopPrank();

        // Assert both are same.
        assertEq(task.description, "Remember to take breaks while working on Day22 project A");
    }

    /// @notice Test to ensure users can update their task priority.
    function testUserCanUpdatePriority() external writeUser1TaskZero {
        // Write as user1.
        vm.startPrank(user1);
        vm.expectEmit(true, true, true, false);
        emit Utils.PriorityUpdated(user1, 0, Types.TaskPriority.Medium);
        toDoListPlus.updateMyTaskPriority(0, Types.TaskPriority.Medium);

        // Assign user1's task.
        ToDoListPlus.Task memory task = toDoListPlus.getMyTaskAtIndex(0);

        // Stop writing as user1.
        vm.stopPrank();

        // Assert Both are same.
        assertEq(uint8(task.priority), uint8(Types.TaskPriority.Medium));
    }

    /// @notice Test to ensure users can update their task category.
    function testUserCanUpdateCategory() external writeUser1TaskZero {
        // Write as user1.
        vm.startPrank(user1);
        vm.expectEmit(true, true, true, false);
        emit Utils.CategoryUpdated(user1, 0, Types.TaskCategory.Work);
        toDoListPlus.updateMyTaskCategory(0, Types.TaskCategory.Work);

        // Assign user1's task.
        ToDoListPlus.Task memory task = toDoListPlus.getMyTaskAtIndex(0);

        // Stop writing as user1.
        vm.stopPrank();

        // Assert Both are same.
        assertEq(uint8(task.category), uint8(Types.TaskCategory.Work));
    }

    /// @notice Test to ensure users can't update with same data.
    function testUsersCantUpdateWithSameData() external writeUser1TaskZero {
        // Write as user1.
        vm.startPrank(user1);

        // Revert with "SameTitle".
        vm.expectRevert(Utils.SameTitle.selector);
        toDoListPlus.updateMyTaskTitle(0, "Day022 ToDoListPlus");

        // Revert with "SameDescription".
        vm.expectRevert(Utils.SameDescription.selector);
        toDoListPlus.updateMyTaskDescription(0, "Spend Minimum of 6 hours daily on Day022 project A");

        // Revert with "SamePriority".
        vm.expectRevert(Utils.SamePriority.selector);
        toDoListPlus.updateMyTaskPriority(0, Types.TaskPriority.High);

        // Revert with "SameCategory".
        vm.expectRevert(Utils.SameCategory.selector);
        toDoListPlus.updateMyTaskCategory(0, Types.TaskCategory.Personal);

        // Stop writing as user1.
        vm.stopPrank();
    }

    /// @notice Test to ensure users can't unset category or priority while updating.
    function testUserCantUnsetCategoryOrPriorityWhileUpdating() external writeUser1TaskZero {
        // Write as user1.
        vm.startPrank(user1);

        // Revert with "UnsetPriority".
        vm.expectRevert(Utils.UnsetPriority.selector);
        toDoListPlus.updateMyTaskPriority(0, Types.TaskPriority.Unset);

        // Revert with "UnsetCategory".
        vm.expectRevert(Utils.UnsetCategory.selector);
        toDoListPlus.updateMyTaskCategory(0, Types.TaskCategory.Unset);

        // Stop writing as user1.
        vm.stopPrank();
    }
}
