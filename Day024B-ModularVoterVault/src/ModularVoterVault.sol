// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title ModularVoterVault.
/// @author MichealKing (@BuildsWithKing)
/**
 * @notice Created on the 19th of Nov, 2025.
 *
 *     This smart contract allows voters to register, unregister, vote on proposals with token, revoke vote,
 *     check their vote status, that of others, and prevents the king and admin from casting votes.
 *     Only the king and the admin can create and delete proposals.
 */

/// @notice Imports KingPausable, VoteManager contract and IERC20.
import {KingPausable} from "buildswithking-security/access/extensions/KingPausable.sol";
import {VoteManager} from "./VoteManager.sol";
import {IERC20} from "buildswithking-security/tokens/ERC20/interfaces/IERC20.sol";

contract ModularVoterVault is VoteManager, KingPausable {
    // ------------------------------------------------- State Variable -----------------------------------------------
    /// @notice Records the token's contract Address.
    IERC20 public immutable i_vvt;

    // ------------------------------------------------- Constructor ---------------------------------------------------
    /// @notice Sets the king and admin's address at deployment.
    /// @dev Assigns the king as the contract deployer. KingCheckAddressLib internally checks for zero admin's address.
    /// @param _king The king's address.
    /// @param _admin The admin's address.
    /// @param _token The token's contract address.
    /// @param _fee The vote fee.
    constructor(address _king, address _admin, address _token, uint256 _fee) KingPausable(_king) {
        // Revert if the token address is the zero address. Custom Error called from `KingClaimMistakenETH` contract.
        if (_token == address(0)) {
            revert InvalidAddress(_token);
        }

        // Assign the admin.
        s_admin = _admin;

        // Call KingAccessControlLite internal `_grantRole` function.
        _grantRole(ADMIN_ROLE, _admin);

        // Assign i_vvt.
        i_vvt = IERC20(_token);

        // Assign the vote fee.
        i_voteFee = _fee;
    }

    // ------------------------------------------------- Voters External Write Functions ---------------------------------
    /// @notice Registers the caller's data.
    /// @dev Voters Id start from 1.
    /// @param _dataHash The caller's off-chain data hash.
    function registerMyData(bytes32 _dataHash) external whenActive {
        // Call the internal `_register` function.
        _register(_dataHash);
    }

    /// @notice Updates the caller's data.
    /// @param _newDataHash The caller's new off-chain data hash.
    function updateMyData(bytes32 _newDataHash) external onlyRegistered whenActive {
        // Call the internal `_updateData` function.
        _updateData(_newDataHash);
    }

    /// @notice Unregisters the caller.
    function unregisterMyData() external onlyRegistered whenActive {
        // Call the internal `_unregister` function.
        _unregister();
    }

    /// @notice Votes on many proposals.
    /// @param _proposalsId The proposals Id.
    function voteOnMany(uint64[] memory _proposalsId) external whenActive onlyRegistered {
        // Return if caller is the king or the admin.
        if (msg.sender == s_admin || msg.sender == s_king) {
            return;
        }

        // Read the total numbers of proposals id (i.e length of the proposals array).
        uint256 len = _proposalsId.length;

        // Loop through all proposals id and vote.
        for (uint256 i; i < len;) {
            voteOnProposal(_proposalsId[i]);

            // Increment i by 1.
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Revokes votes on a proposal.
    /// @param _proposalId The proposal's Id.
    function revokeMyVote(uint64 _proposalId) external onlyRegistered nonReentrant whenActive {
        // Return if caller is the king or the admin.
        if (msg.sender == s_admin || msg.sender == s_king) {
            return;
        }

        // Call the internal `_revoke` function.
        _revokeVote(_proposalId);
    }

    /// @notice Revokes vote on many proposals.
    /// @param _proposalsId The proposals Id.
    function revokeOnMany(uint64[] memory _proposalsId) external onlyRegistered nonReentrant whenActive {
        // Return if caller is the king or the admin.
        if (msg.sender == s_admin || msg.sender == s_king) {
            return;
        }

        // Read the total numbers of proposals id (i.e length of the proposals array).
        uint256 len = _proposalsId.length;

        // Loop through all proposals id and revoke votes.
        for (uint256 i; i < len;) {
            _revokeVote(_proposalsId[i]);

            // Increment i by 1.
            unchecked {
                ++i;
            }
        }
    }

    // ------------------------------------------------- Voter's Public Write Function -------------------------------
    /// @notice Votes on a proposal.
    /// @param _proposalId The proposal's Id.
    function voteOnProposal(uint64 _proposalId) public onlyRegistered nonReentrant whenActive {
        // Return if caller is the king or the admin.
        if (msg.sender == s_admin || msg.sender == s_king) {
            return;
        }

        // Read the vote fee.
        uint256 fee = i_voteFee;

        // Charge the caller.
        i_vvt.transferFrom(msg.sender, address(this), fee);

        // Add the vote fee to the proposal's token balance.
        unchecked {
            s_proposalTokenBalance[_proposalId] += fee;
        }

        // Call the internal `_vote` function.
        _vote(_proposalId);

        // Emit the event VoteFeePaid.
        emit VoteFeePaid(msg.sender, _proposalId, i_voteFee);
    }

    // ------------------------------------------------- Voter's External Read Functions ------------------------------
    /// @notice Returns caller's data.
    /// @return The caller's stored data.
    function myData() external view returns (Voter memory) {
        return s_voterData[msg.sender];
    }

    /// @notice Returns the address's Id.
    /// @param _voter The voter's address.
    /// @return the address's Id.
    function voterId(address _voter) external view returns (uint64) {
        return s_voterData[_voter].id;
    }

    /// @notice Returns the Id proposal's Data.
    /// @param _proposalId The proposal's Id.
    /// @return The proposal's data.
    function proposalData(uint64 _proposalId) external view returns (Proposal memory) {
        return s_proposalData[_proposalId];
    }

    /// @notice Returns the voter's registration status.
    /// @param _voter The voter's address.
    /// @return The voter's registration status (true || false).
    function voterRegistrationStatus(address _voter) external view returns (bool) {
        return s_voterData[_voter].isRegistered;
    }

    /// @notice Returns the voter's registration time.
    /// @param _voter The voter's address.
    /// @return The voter's registration time.
    function voterRegistrationTimestamp(address _voter) external view returns (uint256) {
        return s_voterData[_voter].registeredAt;
    }

    /// @notice Returns voters vote status.
    /// @param voter The voter's address.
    /// @param _proposalId The proposal's Id.
    /// @return True if voter has voted, otherwise false.
    function voterStatus(address voter, uint64 _proposalId) external view returns (bool) {
        return s_hasVoted[voter][_proposalId];
    }

    /// @notice Returns the contract token's balance.
    /// @return The contract token's balance.
    function contractTokenBalance() external view returns (uint256) {
        return i_vvt.balanceOf(address(this));
    }

    // --------------------------------------------------- King's External Write Function ------------------------------
    /// @notice Assigns the admin's role. Callable only by the king.
    /// @dev KingCheckAddressLib internally checks for zero address.
    /// @param _admin The admin's address.
    function assignAdmin(address _admin) external onlyKing {
        // Return if the address is the current admin's address.
        if (s_admin == _admin) {
            return;
        }

        // Revoke the current admin's role.
        _revokeRole(ADMIN_ROLE, s_admin);

        // Assign the new admin.
        s_admin = _admin;

        // Call KingAccessControlLite internal `grantRole` function.
        _grantRole(ADMIN_ROLE, _admin);
    }

    /// @notice Withdraws token from the contract's balance. Callable only by the king.
    /// @param to The receiver's addresss.
    /// @param amount The amount of token to be withdrawn.
    function withdrawToken(address to, uint256 amount) external onlyKing nonReentrant {
        // Transfer the token, Revert if the transfer fails.
        i_vvt.transfer(to, amount);

        // Emit the event `TokenWithdrawn`.
        emit TokenWithdrawn(msg.sender, to, amount);
    }

    // ------------------------------------------------- King and Admin's External Write Functions ---------------------
    /// @notice Creates a proposal. Callable only by the king and the admin.
    /// @param _dataHash  The proposal's off-chain data hash.
    function createProposal(bytes32 _dataHash) external onlyRole(ADMIN_ROLE) {
        // Call the internal `_create` function.
        _create(_dataHash);
    }

    /// @notice Deletes a proposal. Callable only by the king and the admin.
    /// @param _proposalId The proposal's Id.
    function deleteProposal(uint64 _proposalId) external onlyRole(ADMIN_ROLE) {
        // Call the internal `_deleteProposal` function.
        _deleteProposal(_proposalId);
    }

    // -------------------------------------------------- King and Admin's External Read Functions -----------------------
    /// @notice Returns the voter's data. Callable only by the king and the admin.
    /// @param _voter The voter's address.
    /// @return The voter's stored data.
    function voterData(address _voter) external view onlyRole(ADMIN_ROLE) returns (Voter memory) {
        return s_voterData[_voter];
    }

    /// @notice Returns registered voters addresses. Callable only by the king and the admin.
    /// @param _startId The Id of the first voter.
    /// @param _endId The Id of the last voter.
    /// @return _result Addresses of the registered voters.
    function registeredVoters(uint64 _startId, uint64 _endId)
        external
        view
        onlyRole(ADMIN_ROLE)
        returns (address[] memory _result)
    {
        // Return the internal `registered` function.
        return _registered(_startId, _endId);
    }

    /// @notice Returns proposal's voters addresses. Callable only by the king and the admin.
    /// @param _proposalId The proposal's Id.
    /// @param _startId The Id of the first voter.
    /// @param _endId The Id of the last voter.
    /// @return _result Addresses of the proposal's voters.
    function votersAddresses(uint64 _proposalId, uint64 _startId, uint64 _endId)
        external
        view
        onlyValidId(_proposalId)
        onlyRole(ADMIN_ROLE)
        returns (address[] memory _result)
    {
        // Return the internal `voters` function.
        return _voters(_proposalId, _startId, _endId);
    }
}
