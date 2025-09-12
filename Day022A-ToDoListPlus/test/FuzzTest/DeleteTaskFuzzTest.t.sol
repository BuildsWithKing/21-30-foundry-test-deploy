// SPDX-License-Identifier: MIT

/// @title ToDoListPlus (DeleteTask Fuzz Test Contract).
/// @author Michealking (@BuildsWithKing).
/**
 * @notice Created on the 12th of Sept, 2025.
 *
 *     This contract contains all deleteTask function fuzz tests.
 */
pragma solidity ^0.8.30;

/// @notice Imports BaseTest, Types, and ToDoListPlus contract.
import {BaseTest} from "../UnitTest/BaseTest.t.sol";
import {Types} from "../../src/Types.sol";
import {ToDoListPlus} from "../../src/ToDoListPlus.sol";

contract UpdateTaskFuzzTest is BaseTest {
    // ---------------------------------- Fuzz test for delete function. --------------------------

    /// @notice Fuzz test for deleting arbitary task index.
    /// @param _taskIndex The task's index.
    function testFuzzDeleteTask(uint256 _taskIndex) external writeUser1TaskZero writeUser1TaskOne writeUser1TaskTwo {
        // Bound _taskIndex to valid range.
        _taskIndex = uint256(bound(_taskIndex, 0, 2));

        // Start writing as user1.
        vm.startPrank(user1);
        toDoListPlus.deleteMyTask(_taskIndex);

        // Assign existing task.
        uint256 existingTask = toDoListPlus.getExistingTasks();

        // Assert existing task is less than 3.
        assertLt(existingTask, 3);
    }
}
