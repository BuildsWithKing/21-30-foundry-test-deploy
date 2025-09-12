// SPDX-License-Identifier: MIT

/// @title ToDoListPlus (UpdateTask Fuzz Test Contract).
/// @author Michealking (@BuildsWithKing).
/**
 * @notice Created on the 12th of Sept, 2025.
 *
 *     This contract contains all statusTask function fuzz tests.
 */
pragma solidity ^0.8.30;

/// @notice Imports BaseTest, Types, and ToDoListPlus contract.
import {BaseTest} from "../UnitTest/BaseTest.t.sol";
import {Types} from "../../src/Types.sol";
import {ToDoListPlus} from "../../src/ToDoListPlus.sol";

contract UpdateTaskFuzzTest is BaseTest {
    // ---------------------------------- Fuzz test for all update function. --------------------------

    /// @notice Fuzz test for rescheduling tasks with arbitrary timestamps.
    /// @param _newTimestamp The task's new timestamp.
    function testFuzzReschedule(uint256 _newTimestamp) external writeUser1TaskZero {
        // Bound _newTimestamp to valid range.
        _newTimestamp = uint256(bound(_newTimestamp, block.timestamp + FIVE_DAYS, block.timestamp + ONE_MONTH));

        // Start writing as user1.
        vm.startPrank(user1);
        toDoListPlus.rescheduleMyTask(0, _newTimestamp);

        // Assign task.
        ToDoListPlus.Task memory task = toDoListPlus.getMyTaskAtIndex(0);

        // Stop writing as user1.
        vm.stopPrank();

        // Assert both are same.
        assertEq(task.scheduledAt, _newTimestamp);
    }

    /// @notice Fuzz test for deferring tasks.
    /// @param _deferTimestamp The new expiring time.
    function testFuzzDefer(uint256 _deferTimestamp) external writeUser1TaskZero {
        // Bound _deferTimestamp to valid range.
        _deferTimestamp = uint256(bound(_deferTimestamp, block.timestamp + FIVE_DAYS, block.timestamp + ONE_MONTH));

        // Start writing as user1 and defer user1's task.
        vm.startPrank(user1);
        toDoListPlus.deferMyTask(0, _deferTimestamp);

        // Assign user1's task.
        ToDoListPlus.Task memory task = toDoListPlus.getMyTaskAtIndex(0);

        // Stop writing as user1.
        vm.stopPrank();

        // Assert both are same.
        assertEq(task.dueDate, _deferTimestamp);
    }
}
