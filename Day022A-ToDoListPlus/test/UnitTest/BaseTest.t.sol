// SPDX-License-Identifier: MIT

/// @title ToDoListPlus (Base Test Contract).
/// @author Michealking (@BuildsWithKing).
/**
 * @notice Created on the 11th of Sept, 2025.
 *
 *     This test contract contains, "Test" import from forge standard library, variable assignment,
 *     modifiers and setUp function.
 */
pragma solidity ^0.8.30;

/// @notice Imports Test, Types, Utils and ToDoListPlus contract.
import {Test} from "forge-std/Test.sol";
import {Types} from "../../src/Types.sol";
import {Utils} from "../../src/Utils.sol";
import {ToDoListPlus} from "../../src/ToDoListPlus.sol";

contract BaseTest is Test {
    // -------------------------------------------- Variable Assignment -----------------------------------
    /// @notice Assigns toDoListPlus and utils.
    ToDoListPlus toDoListPlus;
    Utils utils;

    /// @notice Assigns BASE_TIMESTAMP, THREE_DAYS, TWO_DAYS, FIVE_DAYS, ONE_YEAR & ETH_AMOUNT.
    uint256 private constant BASE_TIMESTAMP = 1757575526;
    uint256 internal constant THREE_DAYS = 3 days;
    uint256 internal constant TWO_DAYS = 2 days;
    uint256 internal constant FIVE_DAYS = 5 days;
    uint256 internal constant ONE_MONTH = 30 days;
    uint256 internal constant ONE_YEAR = 365 days;
    uint256 internal constant ETH_AMOUNT = 1 ether;

    /// @notice Assigns owner, zero, newOwner, user1 and user2.
    address internal owner = address(this);
    address internal zero = address(0);
    address internal newOwner = address(10);
    address internal user1 = address(0x1);
    address internal user2 = address(0x2);

    // --------------------------------------------- Modifiers ---------------------------------------

    /// @dev Writes user1's task zero.
    modifier writeUser1TaskZero() {
        // Assign futureDate.
        uint256 futureDate = block.timestamp + THREE_DAYS;

        // Write as user1.
        vm.prank(user1);
        vm.expectEmit(true, true, false, false);
        emit Utils.NewTaskAdded(1, user1);
        toDoListPlus.addMyTask(
            "Day022 ToDoListPlus",
            "Spend Minimum of 6 hours daily on Day022 project A",
            Types.TaskPriority.High,
            Types.TaskCategory.Personal,
            futureDate
        );
        _;
    }

    /// @dev Writes user1's task one.
    modifier writeUser1TaskOne() {
        // Assign futureDate.
        uint256 futureDate = block.timestamp + FIVE_DAYS;

        // Write as user1.
        vm.prank(user1);
        vm.expectEmit(true, true, false, false);
        emit Utils.NewTaskAdded(2, user1);
        toDoListPlus.addMyTask(
            "Day022 ToDoListPlus",
            "Spend Minimum of 3 hours daily on Day022 project A",
            Types.TaskPriority.High,
            Types.TaskCategory.Personal,
            futureDate
        );
        _;
    }

    /// @dev Writes user1's task two.
    modifier writeUser1TaskTwo() {
        // Assign futureDate.
        uint256 futureDate = block.timestamp + TWO_DAYS;

        // Write as user1.
        vm.prank(user1);
        vm.expectEmit(true, true, false, false);
        emit Utils.NewTaskAdded(3, user1);
        toDoListPlus.addMyTask(
            "Day022B WhiteListDapp",
            "Spend Minimum of 4 hours daily on Day022 project B",
            Types.TaskPriority.High,
            Types.TaskCategory.Personal,
            futureDate
        );
        _;
    }

    /// @dev Returns user1's task.
    modifier readUser1Task() {
        vm.prank(user1);
        ToDoListPlus.Task memory task = toDoListPlus.getMyTaskAtIndex(0);

        // Assert Both are same.
        assertEq(task.title, "Day022 ToDoListPlus");
        assertEq(task.description, "Spend Minimum of 6 hours daily on Day022 project A");
        assertEq(uint8(task.priority), uint8(Types.TaskPriority.High));
        assertEq(uint8(task.category), uint8(Types.TaskCategory.Personal));
        assertEq(task.dueDate, block.timestamp + THREE_DAYS);
        _;
    }

    // ---------------------------------------------- Setup function ----------------------------------
    /// @notice This function runs before every other test function.
    function setUp() external {
        // Create new instance of ToDoListPlus.
        toDoListPlus = new ToDoListPlus();

        // Create new instance of Utils.
        utils = new Utils();

        // Label owner, user1 & user2.
        vm.label(owner, "OWNER");
        vm.label(user1, "USER1");
        vm.label(user2, "USER2");

        // Fund 1 ether to user2.
        vm.deal(user2, ETH_AMOUNT);

        // Wrap once to a fixed base timestamp for all tests.
        vm.warp(BASE_TIMESTAMP);
    }
}
