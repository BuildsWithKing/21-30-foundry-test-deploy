// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title KingAdminUnitTest.
/// @author Michealking (@BuildsWithKing).
/// @notice Created on the 25th of Nov, 2025.

/// @notice Imports Types, Utils and ModularVoterVaultUnitTest contract.
import {Types} from "../../src/Types.sol";
import {Utils} from "../../src/Utils.sol";
import {ModularVoterVaultUnitTest} from "./ModularVoterVaultUnitTest.t.sol";

contract KingAdminUnitTest is ModularVoterVaultUnitTest {
    // ------------------------------------------------- Unit Test: King's Write Function -----------------------
    /// @notice Test to ensure the king can assign admin.
    function testAssignAdmin_Succeeds() public {
        // Assign admin2
        address admin2 = address(50);

        // Prank as the King.
        vm.prank(KING);
        modularVoterVault.assignAdmin(admin2);

        // Assert admin2 is the current admin.
        assertEq(modularVoterVault.s_admin(), admin2);
    }

    /// @notice Test to ensure the king can't assign the current admin as the new admin.
    function testAssignAdmin_ReturnsForSameAdmin() public {
        // Return since the address is the current admin's address.
        vm.prank(KING);
        modularVoterVault.assignAdmin(ADMIN);
    }

    /// @notice Test to ensure the king can't assign the zero address as the admin.
    function testAssignAdmin_RevertsInvalidAddress() public {
        // Revert since the address is the zero address.
        vm.expectRevert();
        vm.prank(KING);
        modularVoterVault.assignAdmin(ZERO);
    }

    /// @notice Test to ensure only the king can assign admin.
    function testAssignAdmin_RevertsUnauthorized() public {
        // Revert since voter3 isn't the king.
        vm.expectRevert();
        vm.prank(VOTER3);
        modularVoterVault.assignAdmin(VOTER3);
    }

    /// @notice Test to ensure the king can withdraw tokens.
    function testWithdrawToken_Succeeds() public {
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

        // Prank and withdraw token as the king.
        vm.prank(KING);
        modularVoterVault.withdrawToken(KING, 100);

        // Assert the contract's token balance is equal to zero.
        assertEq(modularVoterVault.contractTokenBalance(), 0);
    }

    // ---------------------------------------------- Unit Test: King & Admin's External Write Functions --------------------
    /// @notice Test to ensure the king and admin can delete proposals.
    function testDeleteProposal_Succeeds() public {
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
    }

    /// @notice Test to ensure the king and admin can only delete existing proposals.
    function testDeleteProposal_RevertsInvalidProposalId() public {
        // Revert since proposal 1 doesn't exist.
        vm.expectRevert(abi.encodeWithSelector(Utils.InvalidProposalId.selector, 1));
        vm.prank(KING);
        modularVoterVault.deleteProposal(1);
    }

    // ---------------------------------------------- Unit Test: King & Admin's External Read Functions ---------------------
    /// @notice Test to ensure the king and admin can view voters data.
    function testVoterData_Returns() public {
        // Call the internal `_registerVoter1` function.
        _registerVoter1();

        // Call the internal `_registerVoter2` function.
        _registerVoter2();

        // Prank and return voter data as the admin.
        vm.prank(ADMIN);
        Types.Voter memory voterData = modularVoterVault.voterData(VOTER2);

        // Assert both are the same.
        assertEq(voterData.id, 2);
        assertEq(voterData.isRegistered, true);
        assertEq(voterData.dataHash, VOTER2_HASH);
        assertEq(voterData.registeredAt, block.timestamp);
    }

    /// @notice Test to ensure the admin and the king can view registered voters.
    function testRegisteredVoters_Returns() public {
        // Call the internal `_registerMultipleVoters` function.
        _registerMultipleVoters();

        // Prank and return registered voters as the king.
        vm.prank(KING);
        address[] memory voters = modularVoterVault.registeredVoters(1, 3);

        // Assert each registered voter is at the respective index.
        assertEq(voters[0], VOTER1);
        assertEq(voters[1], VOTER2);
        assertEq(voters[2], VOTER3);
    }

    /// @notice Test to ensure the king and the admin can't view any registered voter, when no voter is registered.
    function testRegisteredVoters_RevertsNoRegisteredVoter() public {
        // Revert since no voter is registered.
        vm.expectRevert(Utils.NoRegisteredVoter.selector);
        vm.prank(ADMIN);
        modularVoterVault.registeredVoters(1, 3);
    }

    /// @notice Test to ensure the king and admin can't input zero as the start Id.
    function testRegisteredVoters_RevertsInvalidRange() public {
        // Call the internal `_registerVoter1` function.
        _registerVoter1();

        // Call the internal `_registerVoter2` function.
        _registerVoter2();

        // Revert since zero is not a valid id.
        vm.expectRevert(Utils.InvalidRange.selector);
        vm.prank(KING);
        modularVoterVault.registeredVoters(0, 3);
    }

    /// @notice Test to ensure the endId resets to lifetime voters.
    function testRegisteredVoters_ResetsEndId() public {
        // Call the internal `_registerMultipleVoters` function.
        _registerMultipleVoters();

        // Prank and return registered voters as the admin.
        vm.prank(ADMIN);
        address[] memory voters = modularVoterVault.registeredVoters(1, 500);

        // Assert each registered voter is at the respective index.
        assertEq(voters[0], VOTER1);
        assertEq(voters[1], VOTER2);
        assertEq(voters[2], VOTER3);
    }

    /// @notice Test to ensure the king and the admin can't input an endId greater than 500.
    function testRegisteredVoters_RevertsHugeEndId() public {
        // Call the internal `_registerVoter1` function.
        _registerVoter1();

        // Call the internal `_registerVoter2` function.
        _registerVoter2();

        // Revert since the endId is greater than 500.
        vm.expectRevert(Utils.HugeEndId.selector);
        vm.prank(KING);
        modularVoterVault.registeredVoters(1, 5000);
    }

    /// @notice Test to ensure the admin and the king can view voters addresses of a particular proposal.
    function testVotersAddresses_Returns() public {
        // Call the internal `_registerMultipleVoters` function.
        _registerMultipleVoters();

        // Call the internal `_createProposal1` function.
        _createProposal1();

        // Prank and vote as voter1.
        vm.prank(VOTER1);
        modularVoterVault.voteOnProposal(1);

        // Prank and vote as voter2.
        vm.prank(VOTER2);
        modularVoterVault.voteOnProposal(1);

        // Prank and return voters addresses as the king.
        vm.prank(KING);
        address[] memory voters = modularVoterVault.votersAddresses(1, 1, 3);

        // Assert each voter is at the respective index.
        assertEq(voters[0], VOTER1);
        assertEq(voters[1], VOTER2);
    }

    /// @notice Test to ensure the king and the admin can't view voters addresses, when no voter is registered.
    function testVotersAddresses_RevertsNoRegisteredVoter() public {
        // Call the internal `_createProposal1` function.
        _createProposal1();

        // Revert since no voter is registered.
        vm.expectRevert(Utils.NoRegisteredVoter.selector);
        vm.prank(KING);
        modularVoterVault.votersAddresses(1, 1, 3);
    }

    /// @notice Test to ensure the king and admin can't input zero as the start Id.
    function testVotersAddresses_RevertsInvalidRange() public {
        // Call the internal `_registerVoter1` function.
        _registerVoter1();

        // Call the internal `_registerVoter2` function.
        _registerVoter2();

        // Call the internal `_createProposal1` function.
        _createProposal1();

        // Revert since zero is not a valid id.
        vm.expectRevert(Utils.InvalidRange.selector);
        vm.prank(KING);
        modularVoterVault.votersAddresses(1, 0, 3);
    }

    /// @notice Test to ensure the endId resets to lifetime voters.
    function testVotersAddresses_ResetsEndId() public {
        // Call the internal `_registerMultipleVoters` function.
        _registerMultipleVoters();

        // Call the internal `_createProposal1` function.
        _createProposal1();

        // Prank and vote on proposal 1 as voter1.
        vm.prank(VOTER1);
        modularVoterVault.voteOnProposal(1);

        // Prank and vote on proposal 1 as voter2.
        vm.prank(VOTER2);
        modularVoterVault.voteOnProposal(1);

        // Prank and return registered voters as the king.
        vm.prank(KING);
        address[] memory voters = modularVoterVault.votersAddresses(1, 1, 500);

        // Assert each voter is at the respective index.
        assertEq(voters[0], VOTER1);
        assertEq(voters[1], VOTER2);
    }

    /// @notice Test to ensure the king and the admin can't input an endId greater than 500.
    function testVotersAddresses_RevertsHugeEndId() public {
        // Call the internal `_registerVoter1` function.
        _registerVoter1();

        // Call the internal `_registerVoter2` function.
        _registerVoter2();

        // Call the internal `_createProposal1` function.
        _createProposal1();

        // Revert since the endId is greater than 500.
        vm.expectRevert(Utils.HugeEndId.selector);
        vm.prank(KING);
        modularVoterVault.votersAddresses(1, 1, 5000);
    }

    /// @notice Test to ensure the king and admin can't input non-existing proposal id.
    function testVotersAddresses_RevertsInvalidProposalId() public {
        // Call the internal `_registerVoter1` function.
        _registerVoter1();

        // Call the internal `_registerVoter2` function.
        _registerVoter2();

        // Revert since proposal 0 doesn't exist.
        vm.expectRevert(abi.encodeWithSelector(Utils.InvalidProposalId.selector, 0));
        vm.prank(ADMIN);
        modularVoterVault.votersAddresses(0, 1, 5000);
    }
}
