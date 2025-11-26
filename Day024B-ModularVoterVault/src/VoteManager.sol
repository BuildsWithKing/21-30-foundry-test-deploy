// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title VoteManager (VoteManager contract for ModularVoterVault).
/// @author MichealKing (@BuildsWithKing)
/**
 * @notice Created on the 18th of Nov, 2025
 *
 *     @dev This contract handles the voters, king and admin's internal logic.
 */

/// @notice Imports Utils contract.
import {Utils} from "./Utils.sol";

abstract contract VoteManager is Utils {
    // -------------------------------------------------- Voters Internal Write Functions ------------------------------------
    /// @notice Registers the caller's data.
    /// @dev Voters Id start from 1.
    /// @param _dataHash The caller's off-chain data hash.
    function _register(bytes32 _dataHash) internal {
        // Revert if the caller is already registered.
        if (s_voterData[msg.sender].isRegistered) {
            revert AlreadyRegistered();
        }

        // Increment votersCount and lifetimeVoters by 1.
        unchecked {
            ++s_votersCount;
            ++s_lifetimeVoters;
        }

        // Assign voter and register the caller's data.
        Voter memory voter =
            Voter({id: s_lifetimeVoters, dataHash: _dataHash, isRegistered: true, registeredAt: block.timestamp});

        // Store the caller's data.
        s_voterData[msg.sender] = voter;

        // Store the caller's address.
        s_voterAddresses[voter.id] = msg.sender;

        // Emit the event VoterRegistered.
        emit VoterRegistered(voter.id, msg.sender, _dataHash);
    }

    /// @notice Updates the caller's data.
    /// @param _newDataHash The caller's new off-chain data hash.
    function _updateData(bytes32 _newDataHash) internal onlyRegistered {
        // Read the caller's stored data.
        Voter storage voter = s_voterData[msg.sender];

        // Revert if the caller's new data is the same as the old data.
        if (_newDataHash == voter.dataHash) {
            revert SameData();
        }

        // Update the caller's data hash.
        voter.dataHash = _newDataHash;

        // Emit the event VoterDataUpdated.
        emit VoterDataUpdated(voter.id, msg.sender, _newDataHash);
    }

    /// @notice Unregisters the caller.
    function _unregister() internal onlyRegistered {
        // Read the caller's data.
        Voter memory voter = s_voterData[msg.sender];

        // Decrement votersCount by 1.
        unchecked {
            --s_votersCount;
        }

        // Loop through proposals count and set the caller's vote status to false.
        for (uint64 i = 1; i <= s_proposalsCount; ++i) {
            if (s_hasVoted[msg.sender][i]) {
                s_hasVoted[msg.sender][i] = false;
                unchecked {
                    --s_proposalVotes[i];
                }
            }
        }

        // Read the caller's id.
        uint64 voterId = voter.id;

        // Delete the caller's data.
        delete s_voterData[msg.sender];

        // Assign the caller's id to the zero address.
        s_voterAddresses[voterId] = address(0);

        // Emit the event VoterUnregistered.
        emit VoterUnregistered(voterId, msg.sender);
    }

    /// @notice Votes on a proposal.
    /// @param _proposalId The proposal Id.
    function _vote(uint64 _proposalId) internal onlyRegistered onlyValidId(_proposalId) {
        // Revert if the caller has already voted.
        if (s_hasVoted[msg.sender][_proposalId]) {
            revert AlreadyVoted();
        }

        // Revert if the caller tries voting on a deleted proposal.
        if (s_proposalData[_proposalId].isDeleted) {
            revert DeletedProposal(_proposalId);
        }

        // Increment the proposal votes of this proposal Id by 1.
        unchecked {
            ++s_proposalVotes[_proposalId];
        }

        // Set caller's vote status to true.
        s_hasVoted[msg.sender][_proposalId] = true;

        // Emit the event Voted.
        emit Voted(s_voterData[msg.sender].id, _proposalId, msg.sender);
    }

    /// @notice Revokes votes on a proposal.
    /// @param _proposalId The proposal Id.
    function _revokeVote(uint64 _proposalId) internal onlyRegistered onlyValidId(_proposalId) {
        // Revert if the caller haven't voted.
        if (!s_hasVoted[msg.sender][_proposalId]) {
            revert NotVoted();
        }

        // Decrement the proposal votes of this proposal Id by 1.
        unchecked {
            --s_proposalVotes[_proposalId];
        }

        // Set caller's vote status to false.
        s_hasVoted[msg.sender][_proposalId] = false;

        // Emit the event VoteRevoked.
        emit VoteRevoked(s_voterData[msg.sender].id, _proposalId, msg.sender);
    }

    // ------------------------------------------------------- King & Admin's Internal Write Functions -----------------------------------
    /// @notice Creates a proposal. Callable only by the king and the admin.
    /// @param _dataHash  The proposal's off-chain data hash.
    function _create(bytes32 _dataHash) internal {
        // Increment proposalsCount by 1.
        unchecked {
            ++s_proposalsCount;
        }

        // Read proposals count.
        uint64 newId = s_proposalsCount;

        // Store proposal's data.
        s_proposalData[newId] = Proposal({id: newId, isDeleted: false, dataHash: _dataHash, addedAt: block.timestamp});

        // Emit the event ProposalCreated.
        emit ProposalCreated(newId, _dataHash, msg.sender);
    }

    /// @notice Deletes a proposal. Callable only by the king and the admin.
    /// @param _proposalId The proposal's Id.
    function _deleteProposal(uint64 _proposalId) internal onlyValidId(_proposalId) {
        // Read the proposal's id data.
        Proposal storage proposal = s_proposalData[_proposalId];

        // Set proposal's deletion status to true, dataHash and timestamp to zero.
        proposal.isDeleted = true;
        proposal.dataHash = bytes32(0);
        proposal.addedAt = 0;

        // Set the proposal's Id total votes to zero.
        s_proposalVotes[_proposalId] = 0;

        // Emit the event ProposalDeleted.
        emit ProposalDeleted(_proposalId, msg.sender);
    }

    // --------------------------------------------------- King & Admin's Internal Read Function ---------------------------------------
    /// @notice Returns registered voters addresses. Callable only by the king and the admin.
    /// @param _startId The Id of the first voter.
    /// @param _endId The Id of the last voter.
    /// @return _result Addresses of the registered voters.
    function _registered(uint64 _startId, uint64 _endId) internal view returns (address[] memory _result) {
        // Revert if there's no registered voter.
        if (s_lifetimeVoters == 0) {
            revert NoRegisteredVoter();
        }

        // Call the internal `_validateRange` helper function.
        _validateRange(_startId, _endId);

        // Revert if _endId is greater than 500.
        if (_endId > 500) {
            revert HugeEndId();
        }

        // Reset _endId to lifetime voters.
        if (_endId > s_lifetimeVoters) {
            _endId = s_lifetimeVoters;
        }

        // Count the amount of active voters between start and end.
        uint64 active = 0;

        // Loop through voterAddresses, pick only the active registered voters.
        for (uint64 id = _startId; id <= _endId; ++id) {
            address voter = s_voterAddresses[id];
            if (voter != address(0) && s_voterData[voter].isRegistered) {
                unchecked {
                    ++active;
                }
            }
        }

        // Use a new array to store the registered voters.
        _result = new address[](active);

        // Assign idx.
        uint64 idx = 0;

        // Populate the _result array.
        for (uint64 id = _startId; id <= _endId; ++id) {
            address voter = s_voterAddresses[id];
            if (voter != address(0) && s_voterData[voter].isRegistered) {
                _result[idx++] = voter;
            }
        }

        // return the new array of registered voters.
        return _result;
    }

    /// @notice Returns proposal's voters addresses. Callable only by the king and the admin.
    /// @param _proposalId The proposal's Id.
    /// @param _startId The Id of the first voter.
    /// @param _endId The Id of the last voter.
    /// @return _result Addresses of the proposal's voters.
    function _voters(uint64 _proposalId, uint64 _startId, uint64 _endId)
        internal
        view
        onlyValidId(_proposalId)
        returns (address[] memory _result)
    {
        // Revert if there's no registered voter.
        if (s_lifetimeVoters == 0) {
            revert NoRegisteredVoter();
        }

        // Call the internal `_validateRange` helper function.
        _validateRange(_startId, _endId);

        // Revert if _endId is greater than 500.
        if (_endId > 500) {
            revert HugeEndId();
        }

        // Reset _endId to lifetime voters.
        if (_endId > s_lifetimeVoters) {
            _endId = s_lifetimeVoters;
        }

        // Count the amount of active voters between start and end.
        uint64 active = 0;

        // Loop through voterAddresses, pick only voters that has voted on the proposal.
        for (uint64 id = _startId; id <= _endId; ++id) {
            address voter = s_voterAddresses[id];
            if (voter != address(0) && s_hasVoted[voter][_proposalId]) {
                unchecked {
                    ++active;
                }
            }
        }

        // Use a new array to store the registered voters.
        _result = new address[](active);

        // Assign idx.
        uint64 idx = 0;

        // Populate the _result array.
        for (uint64 id = _startId; id <= _endId; ++id) {
            address voter = s_voterAddresses[id];
            if (voter != address(0) && s_hasVoted[voter][_proposalId]) {
                _result[idx++] = voter;
            }
        }

        // return the new array of registered voters.
        return _result;
    }
}
