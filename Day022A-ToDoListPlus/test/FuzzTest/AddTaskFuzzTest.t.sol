// SPDX-License-Identifier: MIT

/// @title ToDoListPlus (AddTask Fuzz Test Contract).
/// @author Michealking (@BuildsWithKing).
/**
 * @notice Created on the 12th of Sept, 2025.
 *
 *     This contract contains all addTask function fuzz tests.
 */
pragma solidity ^0.8.30;

/// @notice Imports BaseTest, Types, and ToDoListPlus contract.
import {BaseTest} from "../UnitTest/BaseTest.t.sol";
import {Types} from "../../src/Types.sol";
import {ToDoListPlus} from "../../src/ToDoListPlus.sol";

contract AddTaskFuzzTest is BaseTest {
    // ------------------------- Fuzz test for addMyTask, & getMyTask function -------------------------------

    /// @notice Fuzz test for adding a task with arbitary title, description, priority & category.
    /// @param _title The task's title.
    /// @param _description The task's description.
    /// @param _priorityUint The task's priority in uint8.
    /// @param _categoryUint The task's category in uint8.
    function testFuzzAddTask(
        string memory _title,
        string memory _description,
        uint8 _priorityUint,
        uint8 _categoryUint,
        uint8 taskCount
    ) external {
        // Bound enums to valid ranges.
        _priorityUint = uint8(bound(_priorityUint, 1, 1)); // Low.
        _categoryUint = uint8(bound(_categoryUint, 1, 2)); // Work, Personal.

        // Fallback for empty strings.
        if (bytes(_title).length == 0) _title = "DefaultTitle";
        if (bytes(_description).length == 0) _description = "DefaultDescription";

        // Assign priority and category.
        Types.TaskPriority priority = Types.TaskPriority(_priorityUint);
        Types.TaskCategory category = Types.TaskCategory(_categoryUint);

        // Start writing as user1.
        vm.startPrank(user1);

        // Assign taskInput.
        uint8 taskInput = taskCount = 20;

        // Loop through and add user1's task.
        for (uint8 i; i < taskInput; i++) {
            toDoListPlus.addMyTask(_title, _description, priority, category, block.timestamp + TWO_DAYS);
        }

        // Assign user1's task.
        ToDoListPlus.Task memory task = toDoListPlus.getMyTaskAtIndex(0);

        // Stop writing as user1.
        vm.stopPrank();

        // Assert both are same.
        assertEq(task.title, _title);
        assertEq(task.description, _description);
        assertEq(uint8(task.priority), _priorityUint);
        assertEq(uint8(task.category), _categoryUint);
    }
}
