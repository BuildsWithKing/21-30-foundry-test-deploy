// SPDX-License-Identifier: MIT

/// @title ToDoListPlus (AddTask Unit Test Contract).
/// @author Michealking (@BuildsWithKing).
/**
 * @notice Created on the 9th of Sept, 2025.
 *
 *     This contract contains all addTask function unit tests.
 */
pragma solidity ^0.8.30;

/// @notice Imports BaseTest, Types, and Utils contract.
import {BaseTest} from "./BaseTest.t.sol";
import {Types} from "../../src/Types.sol";
import {Utils} from "../../src/Utils.sol";

contract AddTaskTest is BaseTest {
    // ------------------------- Test for addMyTask & getMyTask function. -------------------------------

    /// @notice Test to ensure users can addTask and get their task.
    function testUserCanAddTaskAndGetTask() external writeUser1TaskZero readUser1Task {}

    /// @notice Test to validate user input.
    function testValidateInput() external {
        // Write as user1.
        vm.startPrank(user1);

        // Revert with "EmptyTitle".
        vm.expectRevert(Utils.EmptyTitle.selector);
        toDoListPlus.addMyTask(
            "",
            "Start Day022 project B once Project A has been shipped",
            Types.TaskPriority.High,
            Types.TaskCategory.Personal,
            block.timestamp + THREE_DAYS
        );

        // Revert with "EmptyDescription".
        vm.expectRevert(Utils.EmptyDescription.selector);
        toDoListPlus.addMyTask(
            "Day022 Project B", "", Types.TaskPriority.High, Types.TaskCategory.Personal, block.timestamp + THREE_DAYS
        );

        // Revert with "InvalidTimestamp".
        vm.expectRevert(Utils.InvalidTimestamp.selector);
        toDoListPlus.addMyTask(
            "Day022 Project B",
            "Start Day022 project B once Project A has been shipped",
            Types.TaskPriority.High,
            Types.TaskCategory.Personal,
            block.timestamp
        );

        // Revert with "InvalidTimestamp".
        vm.expectRevert(Utils.InvalidTimestamp.selector);
        toDoListPlus.addMyTask(
            "Day022 Project B",
            "Start Day022 project B once Project A has been shipped",
            Types.TaskPriority.High,
            Types.TaskCategory.Personal,
            0
        );

        // Revert with "InvalidTimestamp".
        vm.expectRevert(Utils.InvalidTimestamp.selector);
        toDoListPlus.addMyTask(
            "Day022 Project B",
            "Start Day022 project B once Project A has been shipped",
            Types.TaskPriority.High,
            Types.TaskCategory.Personal,
            block.timestamp + ONE_YEAR
        );

        // Stop writing as user1.
        vm.stopPrank();
    }

    /// @notice Test to ensure users must set priority before adding task.
    function testUnsetPriorityRevert() external {
        // write as user1.
        vm.prank(user1);
        // Revert with "UnsetPriority".
        vm.expectRevert(Utils.UnsetPriority.selector);
        toDoListPlus.addMyTask(
            "Day022 Project B",
            "Start Day022 project B once Project A has been shipped",
            Types.TaskPriority.Unset,
            Types.TaskCategory.Personal,
            block.timestamp + THREE_DAYS
        );
    }

    /// @notice Test to ensure users must set category before adding task.
    function testUnsetCategoryRevert() external {
        // write as user1.
        vm.prank(user1);
        // Revert with "UnsetCategory".
        vm.expectRevert(Utils.UnsetCategory.selector);
        toDoListPlus.addMyTask(
            "Day022 Project B",
            "Start Day022 project B once Project A has been shipped",
            Types.TaskPriority.High,
            Types.TaskCategory.Unset,
            block.timestamp + THREE_DAYS
        );
    }
}
