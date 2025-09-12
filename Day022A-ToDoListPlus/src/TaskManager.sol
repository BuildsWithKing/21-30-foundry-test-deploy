// SPDX-License-Identifier: MIT

/// @title TaskManager
/// @author Michealking (@BuildsWithKing)
/**
 * @notice Created on 4th of Sept, 2025.
 *
 *     This contract allows users add, view, mark as done, update, and delete their personal tasks.
 *     Each task contains a title, description, priority, category, etc.
 *     Also timestamps for when tasks were completed, cancelled, or scheduled etc.
 */
pragma solidity ^0.8.30;

/// @notice Imports Utils and Types contract.
import {Utils} from "./Utils.sol";
import {Types} from "./Types.sol";

contract TaskManager is Types, Utils {
    // ------------------------------------------ Users internal write functions -------------------------------------------------

    /// @notice Adds users tasks.
    /// @param _title The task's title.
    /// @param _description The task's description.
    /// @param _priority The task's priority.
    /// @param _category The task's category.
    /// @param _dueDate The task's expiring date.
    function addTask(
        string calldata _title,
        string calldata _description,
        TaskPriority _priority,
        TaskCategory _category,
        uint256 _dueDate
    ) internal validateInput(_title, _description, _priority, _category, _dueDate) isActive {
        // Call and assign internal helper function.
        Task memory task = _buildTask(_title, _description, _priority, _category, _dueDate);

        // Increment taskCount and totalTasks by 1.
        unchecked {
            taskCount++;
            totalTasks++;
        }

        // Store task on user's array.
        userTasks[msg.sender].push(task);

        // Emit event NewTaskAdded.
        emit NewTaskAdded(taskCount, msg.sender);
    }

    /// @notice Updates users task's title.
    /// @param _taskIndex The task's index.
    function updateTaskTitle(uint256 _taskIndex, string calldata _newTitle)
        internal
        validateIndex(_taskIndex, msg.sender)
        isActive
    {
        // Revert with "SameTitle" if title exists at task index.
        if (keccak256(bytes(userTasks[msg.sender][_taskIndex].title)) == (keccak256(bytes(_newTitle)))) {
            revert SameTitle();
        }

        // Update user's task title.
        userTasks[msg.sender][_taskIndex].title = _newTitle;

        // Emit event TitleUpdated.
        emit TitleUpdated(msg.sender, _taskIndex, _newTitle);
    }

    /// @notice Updates users task's Description.
    /// @param _taskIndex The task's index.
    function updateTaskDescription(uint256 _taskIndex, string calldata _newDescription)
        internal
        validateIndex(_taskIndex, msg.sender)
        isActive
    {
        // Revert with "SameDescription" if description exists at task index.
        if (keccak256(bytes(userTasks[msg.sender][_taskIndex].description)) == keccak256(bytes(_newDescription))) {
            revert SameDescription();
        }

        // Update user's task description.
        userTasks[msg.sender][_taskIndex].description = _newDescription;

        // Emit event DescriptionUpdated.
        emit DescriptionUpdated(msg.sender, _taskIndex, _newDescription);
    }

    /// @notice Updates tasks priority.
    /// @param _taskIndex The task's index.
    /// @param _newPriority The task's new priority.
    function updateTaskPriority(uint256 _taskIndex, TaskPriority _newPriority)
        internal
        validateIndex(_taskIndex, msg.sender)
        isActive
    {
        // Revert with "SamePriority" if _newPriority is same as existing.
        if (userTasks[msg.sender][_taskIndex].priority == _newPriority) {
            revert SamePriority();
        }

        // Revert with "UnsetPriority" if user tries resetting priority to zero.
        if (_newPriority == TaskPriority.Unset) revert UnsetPriority();

        // Update user's task priority.
        userTasks[msg.sender][_taskIndex].priority = _newPriority;

        // Emit event PriorityUpdated.
        emit PriorityUpdated(msg.sender, _taskIndex, _newPriority);
    }

    /// @notice Updates tasks category.
    /// @param _taskIndex The task's index.
    /// @param _newCategory The task's new category.
    function updateTaskCategory(uint256 _taskIndex, TaskCategory _newCategory)
        internal
        validateIndex(_taskIndex, msg.sender)
        isActive
    {
        // Revert with "SameCategory" if _newCategory is same as existing.
        if (userTasks[msg.sender][_taskIndex].category == _newCategory) {
            revert SameCategory();
        }

        // Revert with "UnsetCategory" if user tries resetting category to zero.
        if (_newCategory == TaskCategory.Unset) revert UnsetCategory();

        // Update user's task category.
        userTasks[msg.sender][_taskIndex].category = _newCategory;

        // Emit event CategoryUpdated.
        emit CategoryUpdated(msg.sender, _taskIndex, _newCategory);
    }

    /// @notice Marks task as completed.
    /// @param _taskIndex The task's index.
    function markAsCompleted(uint256 _taskIndex) internal validateIndex(_taskIndex, msg.sender) isActive {
        // Revert with "AlreadyCompleted" if task has already been completed.
        if (userTasks[msg.sender][_taskIndex].status == TaskStatus.Completed) {
            revert AlreadyCompleted();
        }

        // Update the user's completedAt with current timestamp.
        userTasks[msg.sender][_taskIndex].completedAt = block.timestamp;

        // Set user's task status to completed.
        userTasks[msg.sender][_taskIndex].status = TaskStatus.Completed;

        // Emit event TaskCompleted.
        emit TaskCompleted(msg.sender, _taskIndex);
    }

    /// @notice Marks task as cancelled.
    /// @param _taskIndex The task's index.
    function markAsCancelled(uint256 _taskIndex) internal validateIndex(_taskIndex, msg.sender) isActive {
        // Revert with "AlreadyCancelled" if task has already been cancelled.
        if (userTasks[msg.sender][_taskIndex].status == TaskStatus.Cancelled) {
            revert AlreadyCancelled();
        }

        // Update the user's cancelledAt with current timestamp.
        userTasks[msg.sender][_taskIndex].cancelledAt = block.timestamp;

        // Set user's task status to cancelled.
        userTasks[msg.sender][_taskIndex].status = TaskStatus.Cancelled;

        // Emit event TaskCancelled.
        emit TaskCancelled(msg.sender, _taskIndex);
    }

    /// @notice Reschedules user's task.
    /// @param _taskIndex The task's index.
    function rescheduleTask(uint256 _taskIndex, uint256 _scheduledTo)
        internal
        validateIndex(_taskIndex, msg.sender)
        isActive
    {
        // Revert with "InvalidTimestamp" if any of this condition is met.
        if (
            _scheduledTo < TIMESTAMP_MAX_LENGTH || _scheduledTo <= block.timestamp
                || _scheduledTo >= block.timestamp + ONE_YEAR
        ) {
            revert InvalidTimestamp();
        }

        // Revert with "AlreadyScheduled" if task has already been rescheduled.
        if (userTasks[msg.sender][_taskIndex].status == TaskStatus.Scheduled) {
            revert AlreadyScheduled();
        }

        // Update the user's task schedule time.
        userTasks[msg.sender][_taskIndex].scheduledAt = _scheduledTo;

        // Set user's task status to scheduled.
        userTasks[msg.sender][_taskIndex].status = TaskStatus.Scheduled;

        // Emit event TaskScheduled.
        emit TaskScheduled(msg.sender, _taskIndex);
    }

    /// @notice Recurs user's task.
    /// @param _taskIndex The task's index.
    function recurTask(uint256 _taskIndex) internal validateIndex(_taskIndex, msg.sender) isActive {
        // Revert with "AlreadyRecurred" if task has already been set to recurring.
        if (userTasks[msg.sender][_taskIndex].status == TaskStatus.Recurring) {
            revert AlreadyRecurred();
        }

        // Set user's task status to recurring.
        userTasks[msg.sender][_taskIndex].status = TaskStatus.Recurring;

        // Emit event TaskRecurred.
        emit TaskRecurred(msg.sender, _taskIndex);
    }

    /// @notice Marks task as deferred (Paused/Postponed).
    /// @param _taskIndex The task's index.
    /// @param _newDueDate The task's expiring date.
    function deferTask(uint256 _taskIndex, uint256 _newDueDate)
        internal
        validateIndex(_taskIndex, msg.sender)
        isActive
    {
        // Revert with "InvalidTimeStamp" if any of this condition is met.
        if (
            _newDueDate < TIMESTAMP_MAX_LENGTH || _newDueDate == 0 || _newDueDate == block.timestamp
                || _newDueDate >= block.timestamp + ONE_YEAR
        ) {
            revert InvalidTimestamp();
        }

        // Revert with "AlreadyDeferred" if task has already been deferred.
        if (userTasks[msg.sender][_taskIndex].status == TaskStatus.Deferred) {
            revert AlreadyDeferred();
        }

        // Update the user's task due date.
        userTasks[msg.sender][_taskIndex].dueDate = _newDueDate;

        // Set user's task status to deferred.
        userTasks[msg.sender][_taskIndex].status = TaskStatus.Deferred;

        // Emit event TaskDeferred.
        emit TaskDeferred(msg.sender, _taskIndex);
    }

    /// @notice Deletes users task.
    /// @param _taskIndex The task's index.
    function deleteTask(uint256 _taskIndex) internal validateIndex(_taskIndex, msg.sender) isActive {
        // Get last index on user's task array.
        uint256 lastIndex = userTasks[msg.sender].length - 1;

        // Swap lastIndex and update index.
        if (_taskIndex != lastIndex) {
            userTasks[msg.sender][_taskIndex] = userTasks[msg.sender][lastIndex];
        }

        // Remove array's last element.
        userTasks[msg.sender].pop();

        // Decrement taskCount.
        unchecked {
            taskCount--;
        }

        // Emit event TaskDeleted.
        emit TaskDeleted(msg.sender, _taskIndex);
    }

    /// @notice Deletes all user's Tasks
    function deleteAllTasks() internal isActive {
        // Assign tasks(user's task length).
        uint256 tasks = userTasks[msg.sender].length;

        // Revert with "NoTask" if user with no task tries deleting.
        if (tasks == 0) {
            revert NoTask();
        } else {
            // Clear user's tasks array.
            delete userTasks[msg.sender];
        }

        unchecked {
            if (taskCount >= tasks) {
                taskCount -= tasks;
            } else {
                // Safely reset to 0.
                taskCount = 0;
            }
        }

        // Emit event DeletedAllTask.
        emit DeletedAllTask(msg.sender);
    }

    // ------------------------------------------------- Users internal read functions ---------------------------------------------

    /// @notice Returns User's task at an index.
    /// @return User's task's information.
    function getTaskAtIndex(uint256 _taskIndex)
        internal
        view
        validateIndex(_taskIndex, msg.sender)
        returns (Task memory)
    {
        return userTasks[msg.sender][_taskIndex];
    }

    /// @notice Returns user's stored task.
    /// @param _offset First task's index.
    /// @param _limit Last task's index.
    /// @return _tasks User's stored tasks.
    function getTasks(uint256 _offset, uint256 _limit) internal view returns (Task[] memory _tasks) {
        // Assign tasks(user's task length).
        uint256 tasks = userTasks[msg.sender].length;

        // Revert "HighOffset" if offset is greater than user's task length.
        if (_offset > tasks) {
            revert HighOffset();
        }

        // Calculate end point.
        uint256 end = _offset + _limit;

        // Reset end to user's maximum tasks.
        if (end > tasks) {
            end = tasks;
        }

        // Compute number of return tasks.
        uint256 len = end - _offset;

        // Allocate a new array for the return tasks.
        _tasks = new Task[](len);

        // Loop through len.
        for (uint256 i = 0; i < len; i++) {
            // Copy tasks from user's array to new _tasks array.
            _tasks[i] = userTasks[msg.sender][_offset + i];
        }
    }

    /// @notice Returns User's task status as string.
    /// @return Task's status as strings
    function getTaskStatus(uint256 _taskIndex)
        internal
        view
        validateIndex(_taskIndex, msg.sender)
        returns (string memory)
    {
        // Assign user taskindex status.
        TaskStatus status = userTasks[msg.sender][_taskIndex].status;

        // Return user task's status.
        return STATUS_NAMES[uint8(status)];
    }

    /// @notice Returns User's task priority as string.
    /// @return Task's priority as strings
    function getTaskPriority(uint256 _taskIndex)
        internal
        view
        validateIndex(_taskIndex, msg.sender)
        returns (string memory)
    {
        // Assign user taskindex priority.
        TaskPriority priority = userTasks[msg.sender][_taskIndex].priority;

        // Return user task's priority.
        return PRIORITY_NAMES[uint8(priority)];
    }

    /// @notice Returns User's task category as string.
    /// @return Task's category as strings.
    function getTaskCategory(uint256 _taskIndex)
        internal
        view
        validateIndex(_taskIndex, msg.sender)
        returns (string memory)
    {
        // Assign user taskindex category.
        TaskCategory category = userTasks[msg.sender][_taskIndex].category;

        // Return user task's category.
        return CATEGORY_NAMES[uint8(category)];
    }
}
