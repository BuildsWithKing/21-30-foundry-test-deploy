// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title BaseTest (BaseTest contract for ModularVoterVault).
/// @author Michealking (@BuildsWithKing).
/// @notice Created on the 25th of Nov, 2025.

/// @notice Imports Test from forge standard library, VoterVaultToken, Types, Utils and ModularVoterVault contract.
import {Test} from "forge-std/Test.sol";
import {VoterVaultToken} from "../src/VoterVaultToken.sol";
import {Types} from "../src/Types.sol";
import {Utils} from "../src/Utils.sol";
import {ModularVoterVault} from "../src/ModularVoterVault.sol";
import {IERC20} from "buildswithking-security/tokens/ERC20/interfaces/IERC20.sol";

contract BaseTest is Test {
    // -------------------------------------------------- State Variables ----------------------------------
    /// @notice Records modularVoterVault's address.
    ModularVoterVault public modularVoterVault;

    /// @notice Records voterVaultToken's address.
    VoterVaultToken public voterVaultToken;

    /// @notice Assigns KING, ZERO, ADMIN, VOTER1, VOTER2 and VOTER3.
    address internal constant KING = address(0x10);
    address internal constant ZERO = address(0);
    address internal constant ADMIN = address(0x5);
    address internal constant VOTER1 = address(0x1);
    address internal constant VOTER2 = address(0x2);
    address internal constant VOTER3 = address(0x3);

    /**
     * @notice Assigns VOTER1_HASH, VOTER2_HASH, VOTER3_HASH, STARTING_BALANCE, ETH_AMOUNT, VOTE_FEE TOTAL_SUPPLY, ONE_THOUSAND_VVT,
     *             PROPOSAL1_HASH, and PROPOSAL2_HASH.
     */
    bytes32 internal constant VOTER1_HASH = 0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890;
    bytes32 internal constant VOTER2_HASH = 0x1220e0b5c7a9f8d6e4c3b2a1f0e9d8c7b6a5d4c3b2a1f0e9d8c7b6a5d4c3b2a1;
    bytes32 internal constant VOTER3_HASH = 0x1220e0b5c7a9f8d6e4c3b2a1f0e9d8c7b6a5d4c3b2a1f0e9d8c7b6a5d4c3b5a1;
    uint256 internal constant STARTING_BALANCE = 10 ether;
    uint256 internal constant ETH_AMOUNT = 1 ether;
    uint256 internal constant VOTE_FEE = 50;
    uint256 internal constant TOTAL_SUPPLY = 100_000_000;
    uint256 internal constant ONE_THOUSAND_VVT = 1000;
    bytes32 internal constant PROPOSAL1_HASH = 0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef4435835878;
    bytes32 internal constant PROPOSAL2_HASH = 0xa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775;

    // --------------------------------------------------- Setup Function -----------------------------------
    /// @notice This function runs before every other function.
    function setUp() public {
        // Create a new instance of VoterVaultToken.
        voterVaultToken = new VoterVaultToken(KING, TOTAL_SUPPLY);

        // Prank as the king and create a new instance of ModularVoterVault.
        vm.prank(KING);
        modularVoterVault = new ModularVoterVault(KING, ADMIN, address(voterVaultToken), VOTE_FEE);

        // Label KING, ZERO, ADMIN, VOTER1, VOTER2 & VOTER3.
        vm.label(KING, "KING");
        vm.label(ZERO, "ZERO");
        vm.label(ADMIN, "ADMIN");
        vm.label(VOTER1, "VOTER1");
        vm.label(VOTER2, "VOTER2");
        vm.label(VOTER3, "VOTER3");

        // Fund 10 ETH to VOTER3.
        vm.deal(VOTER3, STARTING_BALANCE);

        // Prank and Fund 1000 token to VOTER1, and VOTER2.
        vm.startPrank(KING);
        voterVaultToken.transfer(VOTER1, ONE_THOUSAND_VVT);
        voterVaultToken.transfer(VOTER2, ONE_THOUSAND_VVT);

        // Stop pranking as the king.
        vm.stopPrank();

        // Prank as voter1 and approve the contract to spend the specific amount on your behalf.
        vm.prank(VOTER1);
        voterVaultToken.approve(address(modularVoterVault), ONE_THOUSAND_VVT);

        // Prank as voter2 and approve the contract to spend the specific amount on your behalf.
        vm.prank(VOTER2);
        voterVaultToken.approve(address(modularVoterVault), VOTE_FEE);
    }

    // ---------------------------------------------------- Constructor -----------------------------------------
    /// @notice Test to ensure constructor sets king, admin, token and votefee at deployment.
    function testConstructorSetsKingAdmin_TokenAndVoteFee_AtDeployment() public view {
        // Assert king is equal to KING.
        assertEq(modularVoterVault.s_king(), KING);

        // Assert admin is equal to ADMIN.
        assertEq(modularVoterVault.s_admin(), ADMIN);

        // Assert vote fee is equal to 50.
        assertEq(modularVoterVault.i_voteFee(), VOTE_FEE);
    }

    /// @notice Test to ensure the zero address can't be set as the admin at deployment.
    function testConstructor_RevertsInvalidAddress_OnAdminAddress() public {
        // Revert since the address is the zero address.
        vm.expectRevert();
        modularVoterVault = new ModularVoterVault(KING, ZERO, address(voterVaultToken), VOTE_FEE);
    }

    /// @notice Test to ensure the zero address can't be set as the token's address at deployment.
    function testConstructor_RevertsInvalidAddress_OnTokenAddress() public {
        // Revert since the address is the zero address.
        vm.expectRevert();
        modularVoterVault = new ModularVoterVault(KING, ADMIN, ZERO, VOTE_FEE);
    }

    // ------------------------------------------------------ Internal Helper Functions ---------------------------
    /// @notice Registers voter1.
    function _registerVoter1() internal {
        // Emit the event "VoterRegistered", and Prank as VOTER1.
        vm.expectEmit(true, true, true, false);
        emit Types.VoterRegistered(1, VOTER1, VOTER1_HASH);
        vm.prank(VOTER1);
        modularVoterVault.registerMyData(VOTER1_HASH);
    }

    /// @notice Registers voter2.
    function _registerVoter2() internal {
        // Emit the event "VoterRegistered", and Prank as VOTER2.
        vm.expectEmit(true, true, true, false);
        emit Types.VoterRegistered(2, VOTER2, VOTER2_HASH);
        vm.prank(VOTER2);
        modularVoterVault.registerMyData(VOTER2_HASH);
    }

    /// @notice Registers voter3.
    function _registerVoter3() internal {
        // Emit the event "VoterRegistered", and Prank as VOTER3.
        vm.expectEmit(true, true, true, false);
        emit Types.VoterRegistered(3, VOTER3, VOTER3_HASH);
        vm.prank(VOTER3);
        modularVoterVault.registerMyData(VOTER3_HASH);
    }

    /// @notice Registers voter1, voter2 and voter3.
    function _registerMultipleVoters() internal {
        // Call the internal `_registerVoter1` function.
        _registerVoter1();

        // Call the internal `_registerVoter2` function.
        _registerVoter2();

        // Call the internal `_registerVoter3` function.
        _registerVoter3();
    }

    // ---------------------------------------------- Unit Test: King & Admin's Internal Write Helper Functions ------------------------------
    /// @notice Creates a proposal. Callable only by the admin and the king.
    function _createProposal1() internal {
        // Emit the event "ProposalCreated", and Prank as the admin.
        vm.expectEmit(true, true, true, false);
        emit Types.ProposalCreated(1, PROPOSAL1_HASH, ADMIN);
        vm.prank(ADMIN);
        modularVoterVault.createProposal(PROPOSAL1_HASH);
    }

    /// @notice Creates a proposal. Callable only by the admin and the king.
    function _createProposal2() internal {
        // Emit the event "ProposalCreated", and Prank as the king.
        vm.expectEmit(true, true, true, false);
        emit Types.ProposalCreated(2, PROPOSAL2_HASH, KING);
        vm.prank(KING);
        modularVoterVault.createProposal(PROPOSAL2_HASH);
    }

    /// @notice Creates multiple proposals.
    function _createMultipleProposals() internal {
        // Call the internal `CreateProposal1` function.
        _createProposal1();

        // Call the internal `CreateProposal2` function.
        _createProposal2();
    }

    // ------------------------------- Unit Test: VoterVaultToken External Write Function -----------------------
    /// @notice Test to ensure the king can burn tokens.
    function testBurn_Succeeds() public {
        // Prank as the king.
        vm.prank(KING);
        voterVaultToken.burn(ONE_THOUSAND_VVT);

        /**
         * Assert the king's balance is equal to 99,995,000.
         *     Transferred 2000 token to voter1 and voter 2, then burned 1000.
         */
        assertEq(voterVaultToken.balanceOf(KING), TOTAL_SUPPLY - (ONE_THOUSAND_VVT * 3));
    }
}
