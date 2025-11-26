// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title ModularVoterVaultUnitTest.
/// @author Michealking (@BuildsWithKing).
/// @notice Created on the 25th of Nov, 2025.

/// @notice Imports Types, Utils, ModularVoterVault and BaseTest contract.
import {Types} from "../../src/Types.sol";
import {Utils} from "../../src/Utils.sol";
import {ModularVoterVault} from "../../src/ModularVoterVault.sol";
import {BaseTest} from "../BaseTest.t.sol";

contract ModularVoterVaultUnitTest is BaseTest {
    // -------------------------------------- Unit Test: Voters Write Functions ---------------------------
    /// @notice Test to ensure voters can successfully register their data.
    function testRegisterMyData_Succeeds() public {
        // Call the internal `_registerVoter1` function.
        _registerVoter1();

        // Assert voter1's registration status is equal to true.
        assertEq(modularVoterVault.voterRegistrationStatus(VOTER1), true);
    }

    /// @notice Test to ensure voters can register only once.
    function testRegisterMyData_RevertsAlreadyRegistered() public {
        // Call the internal `_registerVoter1` function.
        _registerVoter1();

        // Revert since voter1 is already registered.
        vm.expectRevert(Utils.AlreadyRegistered.selector);
        vm.prank(VOTER1);
        modularVoterVault.registerMyData(VOTER1_HASH);

        // Assert voter1's registration status is equal to true.
        assertEq(modularVoterVault.voterRegistrationStatus(VOTER1), true);
    }

    /// @notice Test to ensure voters can successfully update their data.
    function testUpdateMyData_Succeeds() public {
        // Assign voter2Hash2.
        bytes32 voter2Hash2 = 0x8f9e8d7c6b5a493827161514131211100f0e0d0c0b0a09080706050403020100;

        // Call the internal `_registerVoter1` function.
        _registerVoter1();

        // Call the internal `_registerVoter2` function.
        _registerVoter2();

        // Emit the event "VoterDataUpdated", prank and update data as Voter2.
        vm.expectEmit(true, true, true, false);
        emit Types.VoterDataUpdated(2, VOTER2, voter2Hash2);
        vm.startPrank(VOTER2);
        modularVoterVault.updateMyData(voter2Hash2);

        // Read voter1's data.
        Types.Voter memory voterData = modularVoterVault.myData();

        // Assert voter1's data is equal to the new data.
        assertEq(voterData.dataHash, 0x8f9e8d7c6b5a493827161514131211100f0e0d0c0b0a09080706050403020100);

        // Stop the prank.
        vm.stopPrank();
    }

    /// @notice Test to ensure voters can't update with the same data.
    function testUpdateMyData_RevertsSameData() public {
        // Call the internal `_registerVoter1` function.
        _registerVoter1();

        // Call the internal `_registerVoter2` function.
        _registerVoter2();

        // Revert since the data is the same as the previous data.
        vm.expectRevert(Utils.SameData.selector);
        vm.prank(VOTER2);
        modularVoterVault.updateMyData(VOTER2_HASH);
    }

    /// @notice Test to ensure only registered voters can update their data.
    function testUpdateMyData_RevertsNotRegistered() public {
        // Revert since voter3 isn't registered.
        vm.expectRevert(Utils.NotRegistered.selector);
        vm.prank(VOTER3);
        modularVoterVault.updateMyData(0x9a8b7c6d5e4f3a2b1c0d0e0f1a2b3c4d5e6f7081928374655647382910a0b0c0);
    }

    /// @notice Test to ensure voters can successfully unregister.
    function testUnregisterMyData_Succeeds() public {
        // Call the internal `_registerVoter1` function.
        _registerVoter1();

        // Call the internal `_registerVoter2` function.
        _registerVoter2();

        // Emit the event "VoterUnregistered", prank and unregister as voter2.
        vm.expectEmit(true, true, false, false);
        emit Types.VoterUnregistered(2, VOTER2);
        vm.prank(VOTER2);
        modularVoterVault.unregisterMyData();

        // Assert voter2's registration status is equal to false.
        assertEq(modularVoterVault.voterRegistrationStatus(VOTER2), false);
    }

    /// @notice Test to ensure only registered voters can successfully unregister.
    function testUnregisterMyData_RevertsNotRegistered() public {
        // Revert since voter2 isn't registered.
        vm.expectRevert(Utils.NotRegistered.selector);
        vm.prank(VOTER2);
        modularVoterVault.unregisterMyData();
    }

    /// @notice Test to ensure unregister resets the caller's vote status to false.
    function testUnregisterMyData_ResetsCallerVote() public {
        // Call the internal `_registerVoter1` function.
        _registerVoter1();

        // Call the internal `_registerVoter2` function.
        _registerVoter2();

        // Call the internal `_createProposal1` function.
        _createProposal1();

        // Prank and vote as voter2.
        vm.prank(VOTER2);
        modularVoterVault.voteOnProposal(1);

        // Assert voter2's voting status on proposal 1 is equal to true.
        assertEq(modularVoterVault.voterStatus(VOTER2, 1), true);

        // Emit the event "VoterUnregistered", prank and unregister as voter2.
        vm.expectEmit(true, true, false, false);
        emit Types.VoterUnregistered(2, VOTER2);
        vm.prank(VOTER2);
        modularVoterVault.unregisterMyData();

        // Assert voter2's voting status on proposal 1 is equal to false.
        assertEq(modularVoterVault.voterStatus(VOTER2, 1), false);

        // Assert voter2's registration status is equal to false.
        assertEq(modularVoterVault.voterRegistrationStatus(VOTER2), false);
    }

    /// @notice Test to ensure voters can vote on a proposal.
    function testVoteOnProposal_Succeeds() public {
        // Call the internal `_registerVoter1` function.
        _registerVoter1();

        // Call the internal `_createProposal1` function.
        _createProposal1();

        // Prank and vote as voter1.
        vm.prank(VOTER1);
        modularVoterVault.voteOnProposal(1);

        // Assert Voter1's voting status for proposal 1 is equal to true.
        assertEq(modularVoterVault.voterStatus(VOTER1, 1), true);

        // Assert voter1's token balance is equal to 950.
        assertEq(voterVaultToken.balanceOf(VOTER1), ONE_THOUSAND_VVT - VOTE_FEE);
    }

    /// @notice Test to ensure voters can vote on many proposals.
    function testVoteOnMany_Succeeds() public {
        // Call the internal `_registerVoter1` function.
        _registerVoter1();

        // Call the internal `_createMultipleProposals` function.
        _createMultipleProposals();

        // Create a new array and read the ids.
        uint64[] memory ids = new uint64[](2);
        ids[0] = 1;
        ids[1] = 2;

        // Emit the event `Voted` and `VoteFeePaid` Prank and vote on proposals as voter1.
        vm.expectEmit(true, true, true, false);
        emit Types.Voted(1, ids[0], VOTER1);
        emit Types.VoteFeePaid(VOTER1, 1, VOTE_FEE);
        vm.prank(VOTER1);
        modularVoterVault.voteOnMany(ids);

        // Assert Voter1's voting status for proposal 1 is equal to true.
        assertEq(modularVoterVault.voterStatus(VOTER1, 1), true);

        // Assert Voter1's voting status for proposal 2 is equal to true.
        assertEq(modularVoterVault.voterStatus(VOTER1, 2), true);

        // Assert voter1's token balance is equal to 900.
        assertEq(voterVaultToken.balanceOf(VOTER1), ONE_THOUSAND_VVT - (VOTE_FEE * 2));
    }

    /// @notice Test to ensure voters can vote only once on every proposal.
    function testVoteOnProposal_RevertsAlreadyVoted() public {
        // Call the internal `_registerVoter1` function.
        _registerVoter1();

        // Call the internal `_createProposal1` function.
        _createProposal1();

        // Prank and vote as voter1.
        vm.prank(VOTER1);
        modularVoterVault.voteOnProposal(1);

        // Revert since voter 1 has already voted on proposal 1.
        vm.expectRevert(Utils.AlreadyVoted.selector);
        vm.prank(VOTER1);
        modularVoterVault.voteOnProposal(1);
    }

    /// @notice Test to ensure only registered voters can vote.
    function testVoteOnProposal_RevertsNotRegistered() public {
        // Revert since Voter1 isn't registered.
        vm.expectRevert(Utils.NotRegistered.selector);
        vm.prank(VOTER1);
        modularVoterVault.voteOnProposal(1);
    }

    /// @notice Test to ensure voters can't vote on deleted proposals.
    function testVoteOnProposal_RevertsDeletedProposal() public {
        // Call the internal `_registerVoter1` function.
        _registerVoter1();

        // Call the internal `_createProposal1` function.
        _createProposal1();

        // Prank and delete proposal as the admin.
        vm.expectEmit(true, true, false, false);
        emit Types.ProposalDeleted(1, ADMIN);
        vm.prank(ADMIN);
        modularVoterVault.deleteProposal(1);

        // Assert proposals count is equal 1.
        assertEq(modularVoterVault.s_proposalsCount(), 1);

        // Revert since proposal 1 has been deleted.
        vm.expectRevert(abi.encodeWithSelector(Utils.DeletedProposal.selector, 1));
        vm.prank(VOTER1);
        modularVoterVault.voteOnProposal(1);
    }

    /// @notice Test to ensure voters can vote on only existing proposal Id.
    function testVoteOnProposal_RevertsInvalidProposalId() public {
        // Call the internal `_registerVoter1` function.
        _registerVoter1();

        // Revert since proposal 1 doesn't exist.
        vm.expectRevert(abi.encodeWithSelector(Utils.InvalidProposalId.selector, 1));
        vm.prank(VOTER1);
        modularVoterVault.voteOnProposal(1);
    }

    /// @notice Test to ensure voters can revoke vote on a proposal.
    function testRevokeMyVote_Succeeds() public {
        // Call the internal `_registerVoter1` function.
        _registerVoter1();

        // Call the internal `_createProposal1` function.
        _createProposal1();

        // Prank and vote as voter1.
        vm.prank(VOTER1);
        modularVoterVault.voteOnProposal(1);

        // Assert Voter1's voting status for proposal 1 is equal to true.
        assertEq(modularVoterVault.voterStatus(VOTER1, 1), true);

        // Prank and revoke vote as voter1.
        vm.prank(VOTER1);
        modularVoterVault.revokeMyVote(1);

        // Assert Voter1's voting status for proposal 1 is equal to false.
        assertEq(modularVoterVault.voterStatus(VOTER1, 1), false);
    }

    /// @notice Test to ensure voters can revoke vote on many proposals.
    function testRevokeOnMany_Succeeds() public {
        // Call the internal `_registerVoter1` function.
        _registerVoter1();

        // Call the internal `_createMultipleProposals` function.
        _createMultipleProposals();

        // Create a new array and read the ids.
        uint64[] memory ids = new uint64[](2);
        ids[0] = 1;
        ids[1] = 2;

        // Prank and vote on proposals as voter1.
        vm.prank(VOTER1);
        modularVoterVault.voteOnMany(ids);

        // Prank and revoke vote on proposals as voter1.
        vm.prank(VOTER1);
        modularVoterVault.revokeOnMany(ids);

        // Assert Voter1's voting status for proposal 1 is equal to false.
        assertEq(modularVoterVault.voterStatus(VOTER1, 1), false);

        // Assert Voter1's voting status for proposal 2 is equal to false.
        assertEq(modularVoterVault.voterStatus(VOTER1, 2), false);
    }

    /// @notice Test to ensure only registered voters can revoke vote.
    function testRevokeMyVote_RevertsNotRegistered() public {
        // Revert since Voter3 isn't registered.
        vm.expectRevert(Utils.NotRegistered.selector);
        vm.prank(VOTER3);
        modularVoterVault.revokeMyVote(1);
    }

    /// @notice Test to ensure only registered voters can revoke vote on many proposals.
    function testRevokeOnMany_RevertsNotRegistered() public {
        // Call the internal `_createMultipleProposals` function.
        _createMultipleProposals();

        // Create a new array and read the ids.
        uint64[] memory ids = new uint64[](2);
        ids[0] = 1;
        ids[1] = 2;

        // Revert since Voter2 isn't registered.
        vm.expectRevert(Utils.NotRegistered.selector);
        vm.prank(VOTER2);
        modularVoterVault.revokeOnMany(ids);
    }

    /// @notice Test to ensure only voters who has voted can revoke vote.
    function testRevokeMyVote_RevertsNotVoted() public {
        // Call the internal `_registerVoter1` function.
        _registerVoter1();

        // Call the internal `_createProposal1` function.
        _createProposal1();

        // Revert since Voter1 hasn't voted yet.
        vm.expectRevert(Utils.NotVoted.selector);
        vm.prank(VOTER1);
        modularVoterVault.revokeMyVote(1);
    }

    /// @notice Test to ensure voters can revoke vote on only existing proposal Id.
    function testRevokeMyVote_RevertsInvalidProposalId() public {
        // Call the internal `_registerVoter1` function.
        _registerVoter1();

        // Revert since proposal 0 doesn't exist.
        vm.expectRevert(abi.encodeWithSelector(Utils.InvalidProposalId.selector, 0));
        vm.prank(VOTER1);
        modularVoterVault.revokeMyVote(0);
    }

    /// @notice Test to ensure the contract receives mistakenly sent ETH.
    function testContract_ReceivesMistakenlySentETH() public {
        // Prank and fund contract as voter3.
        vm.prank(VOTER3);
        (bool success,) = payable(address(modularVoterVault)).call{value: ETH_AMOUNT}("");
        assertTrue(success);

        // Assert voter3's mistaken ETH balance is equal to 10 ETH.
        assertEq(modularVoterVault.userMistakenETHBalance(VOTER3), ETH_AMOUNT);
    }

    /// @notice Test to ensure voters can claim back mistakenly sent ETH.
    function testClaimMistakenETH_Succeeds() public {
        // Prank and fund contract as voter3.
        vm.prank(VOTER3);
        (bool success,) = payable(address(modularVoterVault)).call{value: ETH_AMOUNT}("");
        assertTrue(success);

        // Assert voter3's mistaken ETH balance is equal to 10 ETH.
        assertEq(modularVoterVault.userMistakenETHBalance(VOTER3), ETH_AMOUNT);

        // Claim mistakenly sent ETH as Voter3.
        vm.prank(VOTER3);
        modularVoterVault.claimMistakenETH();

        // Assert voter3's mistaken ETH balance is equal to zero.
        assertEq(modularVoterVault.userMistakenETHBalance(VOTER3), 0);
    }

    // ---------------------------------------------- Unit Test: Voters Read Functions ------------------------------
    /// @notice Test to ensure voters can view their data.
    function testMyData_Returns() public {
        // Call the internal `_registerVoter1` function.
        _registerVoter1();

        // Prank and read my data as voter1.
        vm.prank(VOTER1);
        Types.Voter memory voter = modularVoterVault.myData();

        // Assert Both are the same.
        assertEq(voter.id, 1);
        assertEq(voter.dataHash, VOTER1_HASH);
        assertEq(voter.isRegistered, true);
    }

    /// @notice Test to ensure voters can view other voters id.
    function testVoterId_Returns() public {
        // Call the internal `_registerVoter1` function.
        _registerVoter1();

        // Prank and return voter id as voter2.
        vm.prank(VOTER2);
        uint64 id = modularVoterVault.voterId(VOTER1);

        // Assert voter1's Id is equal to 1.
        assertEq(id, 1);
    }

    /// @notice Test to ensure voters can view proposal's data.
    function testProposalData_Returns() public {
        // Call the internal `_createProposal1` function.
        _createProposal1();

        // Prank and read proposal's data as voter1.
        vm.prank(VOTER1);
        Types.Proposal memory proposal = modularVoterVault.proposalData(1);

        // Assert Both are equal.
        assertEq(proposal.id, 1);
        assertEq(proposal.dataHash, PROPOSAL1_HASH);
    }

    /// @notice Test to ensure voters can view other voters registration status.
    function testVoterRegistrationStatus_Returns() public {
        // Call the internal `_registerVoter1` function.
        _registerVoter1();

        // Prank and return voter1's registration status as voter2.
        vm.prank(VOTER2);
        bool status = modularVoterVault.voterRegistrationStatus(VOTER1);

        // Assert voter1's registration status is equal to true.
        assertEq(status, true);
    }

    /// @notice Test to ensure voters can view other voters registration time.
    function testVoterRegistrationTimestamp_Returns() public {
        // Call the internal `_registerVoter1` function.
        _registerVoter1();

        // Prank and return voter1's registration time as voter3.
        vm.prank(VOTER3);
        uint256 time = modularVoterVault.voterRegistrationTimestamp(VOTER1);

        // Assert voter1's registration time is equal to the current time.
        assertEq(time, block.timestamp);
    }

    /// @notice Test to ensure voters can view their voting status and that of other voters.
    function testVoterStatus_Returns() public {
        // Call the internal `_registerVoter1` function.
        _registerVoter1();

        // Call the internal `_createProposal1` function.
        _createProposal1();

        // Prank and vote as voter1.
        vm.prank(VOTER1);
        modularVoterVault.voteOnProposal(1);

        // Assert Voter1's voting status for proposal 1 is equal to true.
        assertEq(modularVoterVault.voterStatus(VOTER1, 1), true);
    }

    /// @notice Test to ensure voters can view the contract's token balance.
    function testContractTokenBalance_Returns() public {
        // Call the internal `_registerVoter1` function.
        _registerVoter1();

        // Call the internal `_registerVoter2` function.
        _registerVoter2();

        // Call the internal `_createProposal1` function.
        _createProposal1();

        // Prank and vote as voter1.
        vm.prank(VOTER1);
        modularVoterVault.voteOnProposal(1);

        // Prank and vote as voter2.
        vm.prank(VOTER2);
        modularVoterVault.voteOnProposal(1);

        // Assert the contract's token balance is equal to 100.
        assertEq(modularVoterVault.contractTokenBalance(), 100);
    }
}
