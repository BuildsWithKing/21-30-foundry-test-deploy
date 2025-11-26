// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title Utils (Utility contract for ModularVoterVault).
/// @author Michealking (@BuildsWithKing).
/**
 * @notice Created on the 18th of Nov, 2025.
 *
 *     This contract handles custom errors, modifier, and accepts mistaken ETH transfers.
 */

/// @notice Imports Types and KingClaimMistakenETH contract.
import {Types} from "./Types.sol";
import {KingClaimMistakenETH} from "buildswithking-security/access/guards/KingClaimMistakenETH.sol";

abstract contract Utils is KingClaimMistakenETH, Types {
    // ------------------------------------------------------- Custom Errors ------------------------------------------------
    /// @notice Thrown for an already registered voter.
    /// @dev Thrown when a voter tries reregistering.
    error AlreadyRegistered();

    /// @notice Thrown for the same data input.
    /// @dev Thrown when a voter tries updating their data with same old data.
    error SameData();

    /// @notice Thrown when a non-registered address attempts an operation reserved for registered voters.
    /// @dev Thrown when a non-registered voter tries unregistering or updating their data hash.
    error NotRegistered();

    /// @notice Thrown when a voter has already voted.
    /// @dev Thrown when a voter has already voted.
    error AlreadyVoted();

    /// @notice Thrown for an already deleted proposal.
    /// @dev Thrown when a voter tries voting on an already deleted proposal.
    /// @param _id The deleted proposal's id.
    error DeletedProposal(uint64 _id);

    /// @notice Thrown when a voter haven't voted.
    /// @dev Thrown when a voter haven't voted but tries revoking a vote.
    error NotVoted();

    /// @notice Thrown for an invalid startId or endId.
    /// @dev Thrown when the king or admin inputs an endId which is less than or equal to the startId.
    error InvalidRange();

    /// @notice Thrown for huge endId.
    /// @dev Thrown when the king or admin inputs an endId greater than five hundred.
    error HugeEndId();

    /// @notice Thrown for invalid proposal id.
    /// @dev Thrown when the king or admin inputs an incorrect proposal id.
    /// @param _id The invalid proposal id.
    error InvalidProposalId(uint64 _id);

    /// @notice Thrown for zero registered voter.
    /// @dev Thrown when the king or admin tries returning the registered voters, while there's none.
    error NoRegisteredVoter();

    /// @notice Thrown for failed token transfer and withdrawal.
    /// @dev Thrown when a voter's token transfer fails or when the king's token withdrawal fails.
    error TransferFailed();

    // -------------------------------------------------------- Modifiers ----------------------------------------------------
    /// @notice Restricts access to only registered voters.
    /// @dev Ensures only registered voters can perform the operation.
    modifier onlyRegistered() {
        // Revert if the voter isn't registered.
        if (!s_voterData[msg.sender].isRegistered) {
            revert NotRegistered();
        }
        _;
    }

    /// @notice Ensures only valid proposal's Id.
    /// @dev Reverts on invalid proposal id inputs.
    /// @param _proposalId The proposal's Id.
    modifier onlyValidId(uint64 _proposalId) {
        // Revert if the proposalId is zero or is greater than proposals count.
        if (_proposalId == 0 || _proposalId > s_proposalsCount) {
            revert InvalidProposalId(_proposalId);
        }
        _;
    }

    // ------------------------------------------------------- Internal Helper Function -------------------------------------
    /// @notice Validates Id range.
    /// @param _startId The start Id.
    /// @param _endId The end Id.
    function _validateRange(uint64 _startId, uint64 _endId) internal view {
        /* Revert if _startId is equal to zero.
        Or if _startId is greater than _endId. 
        Or if _startId is greater than lifetime voters. 
        Or if _endId is less than _startId. 
       */
        if (_startId == 0 || _startId > _endId || _startId > s_lifetimeVoters || _endId < _startId) {
            revert InvalidRange();
        }
    }
}
