// SPDX-License-Identifier: MIT

/// @title ToDoListPlus (UpdateTask Fuzz Test Contract).
/// @author Michealking (@BuildsWithKing).
/**
 * @notice Created on the 12th of Sept, 2025.
 *
 *     This contract contains all updateTask function fuzz tests.
 */
pragma solidity ^0.8.30;

/// @notice Imports BaseTest, Types, and ToDoListPlus contract.
import {BaseTest} from "../UnitTest/BaseTest.t.sol";
import {Types} from "../../src/Types.sol";
import {ToDoListPlus} from "../../src/ToDoListPlus.sol";

contract UpdateTaskFuzzTest is BaseTest {
    // ---------------------------------- Fuzz test for all update function. --------------------------

    /// @notice Fuzz test for updating title & description.
    /// @param _newTitle The task's new title.
    /// @param _newDescription The task's new description.
    function testFuzzUpdateTask(string memory _newTitle, string memory _newDescription) external writeUser1TaskZero {
        // Constrain input length.
        vm.assume(bytes(_newTitle).length > 0 && bytes(_newTitle).length <= 20);
        vm.assume(bytes(_newDescription).length >= 50);

        // Start writing as user1.
        vm.startPrank(user1);
        toDoListPlus.updateMyTaskTitle(0, _newTitle);
        toDoListPlus.updateMyTaskDescription(0, _newDescription);

        // Assign task.
        ToDoListPlus.Task memory task = toDoListPlus.getMyTaskAtIndex(0);

        // Stop writing as user1.
        vm.stopPrank();

        // Assert both are same.
        assertEq(task.title, _newTitle);
        assertEq(task.description, _newDescription);
    }

    /// @notice Fuzz test for updating priority & category.
    /// @param _newPriority The task's new priority.
    /// @param _newCategory The task's new category.
    function testFuzzUpdatePriorityAndCategory(uint8 _newPriority, uint8 _newCategory) external writeUser1TaskZero {
        _newPriority = uint8(bound(_newPriority, 2, 2)); // Medium.
        _newCategory = uint8(bound(_newCategory, 3, 5)); //  Study, Urgent, Others.

        // Assign priority and category.
        Types.TaskPriority priority = Types.TaskPriority(_newPriority);
        Types.TaskCategory category = Types.TaskCategory(_newCategory);

        // Start writing as user1.
        vm.startPrank(user1);

        // Update user1's zero index task priority and category.
        toDoListPlus.updateMyTaskPriority(0, priority);
        toDoListPlus.updateMyTaskCategory(0, category);

        // Assign task.
        ToDoListPlus.Task memory task = toDoListPlus.getMyTaskAtIndex(0);

        // Assert both are same.
        assertEq(uint8(task.priority), _newPriority);
        assertEq(uint8(task.category), _newCategory);
    }
}
