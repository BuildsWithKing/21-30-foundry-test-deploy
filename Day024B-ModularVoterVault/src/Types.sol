// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title Types (Types contract for ModularVoterVault).
/// @author Michealking (@BuildsWithKing).
/**
 * @notice Created on the 18th of Nov, 2025.
 *
 *  @dev  This contract handles state variables, structs, mappings and events.
 */
abstract contract Types {
    // ------------------------------------------------------- State Variables --------------------------------------------
    /// @notice Records the existing registered voters.
    uint64 public s_votersCount;

    /// @notice Tracks the total number of voters that has ever registered (lifetime count, including unregistered).
    uint64 public s_lifetimeVoters;

    /// @notice Records the existing proposals.
    uint64 public s_proposalsCount;

    /// @notice Records the admin's address.
    address public s_admin;

    /// @notice Records the admin's role.
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    /// @notice Records the vote fee.
    uint256 public immutable i_voteFee;

    // -------------------------------------------------------- Structs --------------------------------------------------
    /// @notice Groups voter's data.
    struct Voter {
        uint64 id;
        bool isRegistered;
        bytes32 dataHash;
        uint256 registeredAt;
    }

    /// @notice Groups proposal's data.
    struct Proposal {
        uint64 id;
        bool isDeleted;
        bytes32 dataHash;
        uint256 addedAt;
    }

    // ------------------------------------------------------- Mappings -------------------------------------------------
    /// @notice Maps an identity number to voter's address.
    /// @dev Maps voterId => voter.
    mapping(uint64 => address) internal s_voterAddresses;

    /// @notice Maps voters address to their data.
    /// @dev Maps voter's address => data.
    mapping(address => Voter) internal s_voterData;

    /// @notice Maps proposal's Id to their data.
    /// @dev maps proposalId => Proposal.
    mapping(uint64 => Proposal) internal s_proposalData;

    /// @notice Maps voters address to their voted proposals.
    /// @dev Maps voter => (proposalId => hasVoted).
    mapping(address => mapping(uint64 => bool)) internal s_hasVoted;

    /// @notice Maps proposal's Id to their total votes.
    /// @dev Maps proposalId => votes.
    mapping(uint64 => uint64) public s_proposalVotes;

    /// @notice Maps proposal's Id to their vote fees.
    /// @dev Maps proposalId => vote fee.
    mapping(uint64 => uint256) public s_proposalTokenBalance;

    // -------------------------------------------------------- Events --------------------------------------------------
    /// @notice Emitted once a voter registers.
    /// @param voterId The voter's id.
    /// @param voter The voter's address.
    /// @param dataHash The voter's off-chain data hash.
    event VoterRegistered(uint64 indexed voterId, address indexed voter, bytes32 indexed dataHash);

    /// @notice Emitted once a voter updates their data.
    /// @param voterId The voter's id.
    /// @param voter The voter's address.
    /// @param dataHash The voter's off-chain data hash.
    event VoterDataUpdated(uint64 indexed voterId, address indexed voter, bytes32 indexed dataHash);

    /// @notice Emitted once a voter unregisters.
    /// @param voterId The voter's id.
    /// @param voter The voter's address.
    event VoterUnregistered(uint64 indexed voterId, address indexed voter);

    /// @notice Emitted once a voter votes on a proposal.
    /// @param voterId The voter's Id.
    /// @param proposalId The proposal's Id.
    /// @param voter The voter's address.
    event Voted(uint64 indexed voterId, uint64 indexed proposalId, address indexed voter);

    /// @notice Emitted once a voter pays the voting fee.
    /// @param voter The voter's address.
    /// @param proposalId The proposal's Id.
    /// @param amount The vote fee paid.
    event VoteFeePaid(address indexed voter, uint64 indexed proposalId, uint256 amount);

    /// @notice Emitted once a voter revokes a vote on a proposal.
    /// @param voterId The voter's Id.
    /// @param proposalId The proposal's Id.
    /// @param voter The voter's address.
    event VoteRevoked(uint64 indexed voterId, uint64 indexed proposalId, address indexed voter);

    /// @notice Emitted once the king or admin creates a proposal.
    /// @param proposalId The proposal's Id.
    /// @param dataHash The proposal's off-chain data hash.
    /// @param creator The king or admin's address.
    event ProposalCreated(uint64 indexed proposalId, bytes32 indexed dataHash, address indexed creator);

    /// @notice Emitted once the king or admin deletes a proposal.
    /// @param proposalId The proposal's Id.
    /// @param deletor The king or admin's address.
    event ProposalDeleted(uint64 indexed proposalId, address indexed deletor);

    /// @notice Emitted once the king withdraws token.
    /// @param king The king's address.
    /// @param to The receiver's address.
    /// @param amount The amount of token withdrawn.
    event TokenWithdrawn(address indexed king, address indexed to, uint256 amount);
}
