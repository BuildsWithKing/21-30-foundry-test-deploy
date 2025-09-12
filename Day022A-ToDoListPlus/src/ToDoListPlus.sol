// SPDX-License-Identifier: MIT

/// @title ToDoListPlus
/// @author Michealking (@BuildsWithKing)
/**
 * @notice Created on 4th of Sept, 2025.
 *
 *     This contract allows users add, view, mark as done, update, and delete their personal tasks.
 *     Each task contains a title, description, priority, category, etc.
 *     Also timestamps for when tasks were completed, cancelled, or scheduled etc.
 */
pragma solidity ^0.8.30;

/// @notice Imports TaskManager contract.
import {TaskManager} from "./TaskManager.sol";

contract ToDoListPlus is TaskManager {
    // ---------------------------------------------------- Users external write functions ----------------------------------

    /// @notice Adds users tasks.
    /// @param _title The task's title.
    /// @param _description The task's description.
    /// @param _priority The task's priority.
    /// @param _category The task's category.
    /// @param _dueDate The task's expiring date.
    function addMyTask(
        string calldata _title,
        string calldata _description,
        TaskPriority _priority,
        TaskCategory _category,
        uint256 _dueDate
    ) external validateInput(_title, _description, _priority, _category, _dueDate) isActive {
        // Call internal function
        addTask(_title, _description, _priority, _category, _dueDate);
    }

    /// @notice Updates users task's title.
    /// @param _taskIndex The task's index.
    function updateMyTaskTitle(uint256 _taskIndex, string calldata _newTitle)
        external
        validateIndex(_taskIndex, msg.sender)
        isActive
    {
        // Call internal function.
        updateTaskTitle(_taskIndex, _newTitle);
    }

    /// @notice Updates users task's Description.
    /// @param _taskIndex The task's index.
    function updateMyTaskDescription(uint256 _taskIndex, string calldata _newDescription)
        external
        validateIndex(_taskIndex, msg.sender)
        isActive
    {
        // Call internal function.
        updateTaskDescription(_taskIndex, _newDescription);
    }

    /// @notice Updates tasks priority.
    /// @param _taskIndex The task's index.
    /// @param _newPriority The task's new priority.
    function updateMyTaskPriority(uint256 _taskIndex, TaskPriority _newPriority)
        external
        validateIndex(_taskIndex, msg.sender)
        isActive
    {
        // Call internal function.
        updateTaskPriority(_taskIndex, _newPriority);
    }

    /// @notice Updates tasks category.
    /// @param _taskIndex The task's index.
    /// @param _newCategory The task's new category.
    function updateMyTaskCategory(uint256 _taskIndex, TaskCategory _newCategory)
        external
        validateIndex(_taskIndex, msg.sender)
        isActive
    {
        // Call internal function.
        updateTaskCategory(_taskIndex, _newCategory);
    }

    /// @notice Marks user's task as completed.
    /// @param _taskIndex The task's index.
    function markMyTaskAsCompleted(uint256 _taskIndex) external validateIndex(_taskIndex, msg.sender) isActive {
        // Call internal function.
        markAsCompleted(_taskIndex);
    }

    /// @notice Marks task as cancelled.
    /// @param _taskIndex The task's index.
    function markMyTaskAsCancelled(uint256 _taskIndex) external validateIndex(_taskIndex, msg.sender) isActive {
        // Call internal function.
        markAsCancelled(_taskIndex);
    }

    /// @notice Reschedules user's task.
    /// @param _taskIndex The task's index.
    function rescheduleMyTask(uint256 _taskIndex, uint256 _scheduledTo)
        external
        validateIndex(_taskIndex, msg.sender)
        isActive
    {
        //Call internal function.
        rescheduleTask(_taskIndex, _scheduledTo);
    }

    /// @notice Recurs user's task.
    /// @param _taskIndex The task's index.
    function recurMyTask(uint256 _taskIndex) external validateIndex(_taskIndex, msg.sender) isActive {
        // Call internal function.
        recurTask(_taskIndex);
    }

    /// @notice Defers(Paused/Postponed) user's task.
    /// @param _taskIndex The task's index.
    /// @param _newDueDate The task's exipiring date.
    function deferMyTask(uint256 _taskIndex, uint256 _newDueDate)
        external
        validateIndex(_taskIndex, msg.sender)
        isActive
    {
        // Call internal function.
        deferTask(_taskIndex, _newDueDate);
    }

    /// @notice Deletes users task.
    /// @param _taskIndex The task's index.
    function deleteMyTask(uint256 _taskIndex) external validateIndex(_taskIndex, msg.sender) isActive {
        // Call internal function.
        deleteTask(_taskIndex);
    }

    /// @notice Deletes all user's Tasks
    function deleteAllMyTasks() external isActive {
        // Call internal function.
        deleteAllTasks();
    }

    // --------------------------------------------------- Users external read functions ------------------------------------------

    /// @notice Returns User's task at an index.
    /// @return User's task's information.
    function getMyTaskAtIndex(uint256 _taskIndex)
        external
        view
        validateIndex(_taskIndex, msg.sender)
        returns (Task memory)
    {
        // Return internal function.
        return getTaskAtIndex(_taskIndex);
    }

    /// @notice Returns user's stored task.
    /// @param _offset First task's index.
    /// @param _limit Last task's index.
    /// @return _tasks User's stored tasks.
    function getMyTasks(uint256 _offset, uint256 _limit) external view returns (Task[] memory _tasks) {
        // Return internal function.
        return getTasks(_offset, _limit);
    }

    /// @notice Returns User's task status as string.
    /// @return Task's status as strings
    function getMyTaskStatus(uint256 _taskIndex)
        external
        view
        validateIndex(_taskIndex, msg.sender)
        returns (string memory)
    {
        // Return internal function.
        return getTaskStatus(_taskIndex);
    }

    /// @notice Returns User's task priority as string.
    /// @return Task's priority as strings
    function getMyTaskPriority(uint256 _taskIndex)
        external
        view
        validateIndex(_taskIndex, msg.sender)
        returns (string memory)
    {
        // Return internal function.
        return getTaskPriority(_taskIndex);
    }

    /// @notice Returns User's task category as string.
    /// @return Task's category as strings.
    function getMyTaskCategory(uint256 _taskIndex)
        external
        view
        validateIndex(_taskIndex, msg.sender)
        returns (string memory)
    {
        // Return internal function.
        return getTaskCategory(_taskIndex);
    }

    /// @notice Returns user's tasks count
    /// @return User's task count.
    function getMyTaskCount() external view returns (uint256) {
        // Assign user's task count.
        uint256 taskCount = userTasks[msg.sender].length;

        // Return user's task count.
        return taskCount;
    }

    /// @notice Returns global tasks count.
    /// @return total tasks ever stored by users.
    function getTotalTasks() external view returns (uint256) {
        return totalTasks;
    }

    /// @notice Returns existing tasks count.
    /// @return total existing excluding deleted tasks.
    function getExistingTasks() external view returns (uint256) {
        return taskCount;
    }

    /// @notice Returns the contract deployer's address
    /// @return Owner's address.
    function getOwner() external view returns (address) {
        return owner;
    }

    /// @notice Returns Contract current state.
    /// @return True if contract is active, false otherwise.
    function isContractActive() external view returns (bool) {
        // Return True if contract is active, false otherwise.
        return state == ContractState.Active;
    }
}
