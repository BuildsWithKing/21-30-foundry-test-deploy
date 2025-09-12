// SPDX-License-Identifier: MIT

/// @title Utils (Utility contract for TodolistPlus).
/// @author Michealking (@BuildsWithKing).
/**
 * @notice Created on 4th of Sept, 2025.
 *
 *     This contract contains modifiers, events, handles contract state,
 *     ownership transfer & renouncement, with fallback and receive function.
 */
pragma solidity ^0.8.30;

/// @notice Imports Types and ReentrancyGuard contracts.
import {Types} from "./Types.sol";
import {ReentrancyGuard} from "lib/buildswithking-security/contracts/security/ReentrancyGuard.sol";

contract Utils is ReentrancyGuard, Types {
    // --------------------------------------------------- Custom errors ---------------------------------------------

    /// @dev Thrown for unauthorized access.
    error Unauthorized();

    /// @dev Thrown when users input wrong timestamp.
    error InvalidTimestamp();

    /// @dev Thrown for empty task title.
    error EmptyTitle();

    /// @dev Thrown for empty description.
    error EmptyDescription();

    /// @dev Thrown for unset priority.
    error UnsetPriority();

    /// @dev Thrown for unset category.
    error UnsetCategory();

    /// @dev Thrown when users inputs an existing title.
    error SameTitle();

    /// @dev Thrown when users inputs an existing description.
    error SameDescription();

    /// @dev Thrown when users inputs current priority.
    error SamePriority();

    /// @dev Thrown when users inputs current category.
    error SameCategory();

    /// @dev Thrown when users inputs invalid index.
    error OutOfBounds();

    /// @dev Reminds users task has already been completed.
    error AlreadyCompleted();

    /// @dev Reminds users task has already been cancelled.
    error AlreadyCancelled();

    /// @dev Reminds users task has already been recurred.
    error AlreadyRecurred();

    /// @dev Reminds users task has already been rescheduled.
    error AlreadyScheduled();

    /// @dev Reminds users task has already been deferred.
    error AlreadyDeferred();

    /// @dev Thrown when users with no task tries deleting.
    error NoTask();

    /// @dev Thrown when users input huge starting index.
    error HighOffset();

    /// @dev Thrown when contract is not active.
    error InactiveContract();

    /// @dev Thrown when contract deployer tries to activate already active contract.
    error AlreadyActive();

    /// @dev Thrown when contract deployer tries to deactivate inactive contract.
    error AlreadyInactive();

    /// @dev Thrown when owner tries to transfer ownership to contract address or zero address.
    error InvalidAddress();

    /// @dev Thrown when owner tries to transfer ownership to self.
    error SameOwner();

    /// @dev Thrown when users sends ETH to contract address.
    error ETHRejected();

    // ------------------------------------------------------ Events -----------------------------------------------

    /// @notice Emits NewTaskAdded.
    /// @param _taskId The task's Id.
    /// @param _userAddress The user's address.
    event NewTaskAdded(uint256 indexed _taskId, address indexed _userAddress);

    /// @notice Emits TitleUpdated.
    /// @param _userAddress The user's address.
    /// @param _taskIndex The task's index.
    /// @param _newTitle The task's new title.
    event TitleUpdated(address indexed _userAddress, uint256 indexed _taskIndex, string _newTitle);

    /// @notice Emits DescriptionUpdated.
    /// @param _userAddress The user's address.
    /// @param _taskIndex The task's index.
    /// @param _newDescription The task's new description.
    event DescriptionUpdated(address indexed _userAddress, uint256 indexed _taskIndex, string _newDescription);

    /// @notice Emits PriorityUpdated.
    /// @param _userAddress The user's address.
    /// @param _taskIndex The task's index.
    /// @param _newPriority The task's new priority.
    event PriorityUpdated(address indexed _userAddress, uint256 indexed _taskIndex, TaskPriority _newPriority);

    /// @notice Emits CategoryUpdated.
    /// @param _userAddress The user's address.
    /// @param _taskIndex The task's index.
    /// @param _newCategory The task's new category.
    event CategoryUpdated(address indexed _userAddress, uint256 indexed _taskIndex, TaskCategory _newCategory);

    /// @notice Emits TaskCompleted.
    /// @param _userAddress The user's address.
    /// @param _taskIndex The task's index.
    event TaskCompleted(address indexed _userAddress, uint256 indexed _taskIndex);

    /// @notice Emits TaskCancelled.
    /// @param _userAddress The user's address.
    /// @param _taskIndex The task's index.
    event TaskCancelled(address indexed _userAddress, uint256 indexed _taskIndex);

    /// @notice Emits TaskScheduled
    /// @param _userAddress The user's address.
    /// @param _taskIndex The task's index.
    event TaskScheduled(address indexed _userAddress, uint256 indexed _taskIndex);

    /// @notice Emits TaskRecurred.
    /// @param _userAddress The user's address.
    /// @param _taskIndex The task's index.
    event TaskRecurred(address indexed _userAddress, uint256 indexed _taskIndex);

    /// @notice Emits TaskDeferred.
    /// @param _userAddress The user's address.
    /// @param _taskIndex The task's index.
    event TaskDeferred(address indexed _userAddress, uint256 indexed _taskIndex);

    /// @notice Emits TaskDeleted.
    /// @param _userAddress The user's address.
    /// @param _taskIndex The task's index.
    event TaskDeleted(address indexed _userAddress, uint256 indexed _taskIndex);

    /// @notice Emit DeletedAllTask.
    /// @param _userAddress The user's address.
    event DeletedAllTask(address indexed _userAddress);

    /// @notice Emits OwnershipTransferred.
    /// @param oldOwnerAddress The old owner's address.
    /// @param newOwnerAddress The new owner's address.
    event OwnershipTransferred(address indexed oldOwnerAddress, address indexed newOwnerAddress);

    /// @notice Emits OwnershipRenounced.
    /// @param ownerAddress The owner's address.
    /// @param zeroAddress The zero address.
    event OwnershipRenounced(address indexed ownerAddress, address indexed zeroAddress);

    /// @notice Emits ContractActivated.
    /// @param ownerAddress The owner's address.
    event ContractActivated(address indexed ownerAddress);

    /// @notice Emits ContractDeactivated.
    /// @param ownerAddress The owner's address.
    event ContractDeactivated(address indexed ownerAddress);

    // ------------------------------------------------------ Constructor --------------------------------------------

    /// @notice Sets owner as contract deployer.
    constructor() {
        owner = msg.sender;

        // Set contract state to active on deployment.
        state = ContractState.Active;
    }

    // ------------------------------------------------------ Modifier --------------------------------------------------

    /// @dev Restricts access to owner only.
    modifier onlyOwner() {
        // Revert with message "Unauthorized" if not owner.
        if (msg.sender != owner) {
            revert Unauthorized();
        }
        _;
    }

    /// @dev Restrict Access once contract is not active.
    modifier isActive() {
        if (state == ContractState.NotActive) {
            revert InactiveContract();
        }
        _;
    }

    /// @dev Validates users input.
    modifier validateInput(
        string calldata _title,
        string calldata _description,
        TaskPriority _priority,
        TaskCategory _category,
        uint256 _dueDate
    ) {
        // Revert with message "EmptyTitle" if title is empty.
        if ((bytes(_title).length == 0)) revert EmptyTitle();

        // Revert with message "EmptyDescription" if description is empty.
        if ((bytes(_description).length == 0)) revert EmptyDescription();
        _;

        // Revert with "UnsetPriority" if user doesn't select priority.
        if (_priority == TaskPriority.Unset) {
            revert UnsetPriority();
        }

        // Revert with "UnsetCategory" if user doesn't select category.
        if (_category == TaskCategory.Unset) {
            revert UnsetCategory();
        }

        // Revert with "InvalidTimestamp" if any of this condition is met.
        if (
            _dueDate < TIMESTAMP_MAX_LENGTH || _dueDate == 0 || _dueDate == block.timestamp
                || _dueDate >= block.timestamp + ONE_YEAR
        ) {
            revert InvalidTimestamp();
        }
    }

    /// @dev Validates users task index.
    modifier validateIndex(uint256 _taskIndex, address _userAddress) {
        /* Revert with "OutOfBounds" if taskIndex 
        is greater or equal users task's length. */
        if (_taskIndex >= userTasks[_userAddress].length) {
            revert OutOfBounds();
        }
        _;
    }

    // ------------------------------ Internal helper functions. --------------------------------------------

    /// @notice Builds Task.
    /// @param _title The task's title.
    /// @param _description The task's description.
    /// @param _priority The task's priority.
    /// @param _category The task's category.
    /// @param _dueDate The task's expiring date.
    function _buildTask(
        string calldata _title,
        string calldata _description,
        TaskPriority _priority,
        TaskCategory _category,
        uint256 _dueDate
    ) internal view returns (Task memory task) {
        // Assign user's input.
        task.taskId = taskCount;
        task.title = _title;
        task.description = _description;
        task.priority = _priority;
        task.category = _category;
        task.status = TaskStatus.Pending;
        task.dueDate = _dueDate;
        task.completedAt = 0;
        task.cancelledAt = 0;
        task.scheduledAt = 0;
    }

    /// @notice Task's status internal lookup table.
    string[7] internal STATUS_NAMES =
        ["Pending", "Completed", "Cancelled", "Scheduled", "Recurring", "Deferred", "Deleted"];

    /// @notice Task's priority internal lookup table.
    string[4] internal PRIORITY_NAMES = ["Unset", "Low", "Medium", "High"];

    /// @notice Task's category internal lookup table.
    string[6] internal CATEGORY_NAMES = ["Unset", "Work", "Personal", "Study", "Urgent", "Others"];

    // -----------------------------  Owner's external write functions -------------------------------------

    /// @notice Only contract deployer can activate contract.
    function activateContract() external onlyOwner {
        // Revert with "AlreadyActive", if contract is already active.
        if (state == ContractState.Active) revert AlreadyActive();

        // Set contract state as Active.
        state = ContractState.Active;

        // Emit event ContractActivated.
        emit ContractActivated(owner);
    }

    /// @notice Only contract deployer can deactivate contract.
    function deactivateContract() external onlyOwner {
        // Revert with "AlreadyInactive", if contract is already inactive.
        if (state == ContractState.NotActive) revert AlreadyInactive();

        // Set contract state as NotActive.
        state = ContractState.NotActive;

        // Emit event ContractDeactivated.
        emit ContractDeactivated(owner);
    }

    /// @notice Transfers ownership.
    /// @param _newOwnerAddress The new owner's address.
    function transferOwnership(address _newOwnerAddress) external onlyOwner nonReentrant {
        // Revert "InvalidAddress" if new owner address is zero address or contract address.
        if (_newOwnerAddress == address(0) || (_newOwnerAddress == address(this))) {
            revert InvalidAddress();
        }

        // Revert "SameOwner" if newOwnerAddress is the current owner.
        if (owner == _newOwnerAddress) {
            revert SameOwner();
        }

        // Emit event OwnershipTransferred.
        emit OwnershipTransferred(owner, _newOwnerAddress);

        // Set newOwnerAddress as new owner.
        owner = _newOwnerAddress;
    }

    /// @notice Only owner can renounce ownership.
    function renounceOwnership() external onlyOwner isActive {
        // Emit event OwnershipRenounced.
        emit OwnershipRenounced(owner, address(0));

        // Assign zero address as new owner.
        owner = address(0);
    }

    // ---------------------------- Receive & fallback external functions -------------------------------

    /// @notice Rejects ETH transfer with no calldata.
    receive() external payable {
        revert ETHRejected();
    }

    /// @notice Rejects ETH transfer with calldata.
    fallback() external payable {
        revert ETHRejected();
    }
}
