// SPDX-License-Identifier: MIT

/// @title Types (TodolistPlus types contract)
/// @author Michealking (@BuildsWithKing)
/**
 * @notice Created on 4th of Sept, 2025.
 *
 *     This contract handles variable assignments, structs, mappings and enums.
 */
pragma solidity ^0.8.30;

abstract contract Types {
    // ------------------------------------------------- Variable Assignment ---------------------------------------

    /// @notice Assigns owner's address.
    address internal owner;

    /// @notice Records active task.
    uint256 internal taskCount;

    /// @notice Assigns 1e9 (Unix timestamp max length).
    uint256 internal constant TIMESTAMP_MAX_LENGTH = 1e9;

    /// @notice Assigns 365 days.
    uint256 internal constant ONE_YEAR = 365 days;

    /// @notice Records total tasks ever stored.
    uint256 internal totalTasks;

    /// @notice Assigns state.
    ContractState state;

    // -------------------------------------------------- Structs ---------------------------------------------------

    /// @notice Groups task data.
    struct Task {
        uint256 taskId; // 32 bytes
        uint256 createdAt; // 32 bytes
        uint256 completedAt; // 32 bytes
        uint256 cancelledAt; // 32 bytes
        uint256 scheduledAt; // 32 bytes
        uint256 dueDate; // 32 bytes
        TaskPriority priority; // 1 byte
        TaskCategory category; // 1 byte
        TaskStatus status; // 1 byte
        string title;
        string description;
    }

    // ----------------------------------------------------- Enums ----------------------------------------------------

    /// @notice Defines task status.
    enum TaskStatus {
        // Status ranges from 0 -> 6.
        Pending,
        Completed,
        Cancelled,
        Scheduled,
        Recurring,
        Deferred,
        Deleted
    }

    /// @notice Defines Task priority
    enum TaskPriority {
        // Priority ranges from 0 -> 3
        Unset,
        Low,
        Medium,
        High
    }

    /// @notice Defines Tasks category.
    enum TaskCategory {
        // Category ranges from 0 -> 5
        Unset,
        Work,
        Personal,
        Study,
        Urgent,
        Others
    }

    /// @notice Defines contract state.
    enum ContractState {
        // status ranges from 0 -> 1.
        NotActive,
        Active
    }

    // --------------------------------------------- Mappings -----------------------------------------------------

    /// @notice Maps user's address to their tasks.
    mapping(address => Task[]) internal userTasks;
}
