// SPDX-License-Identifier: MIT

/// @title DonationVaultV2InvariantTest (DonationVaultV2 invariant test contract).
/// @author Michealking (@BuildsWithKing).
/// @notice Created on the 4th of Oct, 2025.

pragma solidity ^0.8.30;

/// @notice Imports BaseTest, and StdInvariant from forge standard library.
import {BaseTest} from "../BaseTest.t.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";

contract DonationVaultV2InvariantTest is StdInvariant, BaseTest {
    // ---------------------------------------------- invariant setup function -------------------------
    /// @notice Runs before every other invariant test.
    function setUp() public override {
        // Run main setUp function on BaseTest.
        super.setUp();

        // Register DonationVaultV2(vault) as the fuzz target contract.
        targetContract(address(vault));

        // Whitelist only user-facing functions.
        bytes4[] memory selectors = new bytes4[](7);
        selectors[0] = vault.donateETH.selector;
        selectors[1] = vault.lifetimeDonorsCount.selector;
        selectors[2] = vault.totalETHDonated.selector;
        selectors[3] = vault.viewDonorDonationStatus.selector;
        selectors[4] = vault.myDonation.selector;
        selectors[5] = vault.viewDonorBalance.selector;
        selectors[6] = vault.vaultBalance.selector;

        // Fuzz only user-facing contract.
        targetSelector(FuzzSelector({addr: address(vault), selectors: selectors}));
    }
    // --------------------------------------------- Invariant test: Donors read functions ------------------

    /// @notice Invariant test to ensure donors can't donate ETH when contract is paused.
    function invariant_whenPaused_NoDonations() public {
        // If contract state is paused.
        if (vault.isContractActive() == false) {
            // Revert, Since contract is paused.
            vm.expectRevert();
            vm.prank(DONOR3);
            vault.donateETH{value: ETH_AMOUNT}();
        }
    }

    /// @notice Invariant test to ensure vault balance remains consistent.
    function invariant_VaultBalanceConsistency() public {
        // Prank and getDonorsAddresses as KING.
        vm.prank(KING);
        address[] memory donorAddresses = vault.getDonorsAddresses(0, 1000);

        // Assign balance.
        uint256 balance;

        // Loop through donorsAddresses array's length.
        for (uint256 i = 0; i < donorAddresses.length; i++) {
            // Add donors balance to balance.
            balance += vault.viewDonorBalance(donorAddresses[i]);
        }

        // Assert balance is always equal to vault's balance.
        assertEq(balance, address(vault).balance);
    }

    /// @notice Invariant test to ensure donors can't donate zero ETH or less than.
    function invariant_NoNegativeDonations() public view {
        // Assert totalETHDonated is greater than or equal to zero.
        assertGe(vault.totalETHDonated(), 0);

        // Assert lifetime donors count is equal to zero.
        assertGe(vault.lifetimeDonorsCount(), 0);
    }

    /// @notice Invariant test to ensure total donations minus withdrawals is greater than or equal to vault balance.
    function invariant_totalDonationsMinusWithdrawals_GreaterThanOrEqualsVaultBalance() public view {
        // Assign totalDonated and contractBalance
        uint256 totalDonated = vault.totalETHDonated();
        uint256 contractBalance = vault.vaultBalance();

        // Assert totalDonated is greater than or equal to contract balance.
        assertGe(totalDonated, contractBalance);
    }

    // ------------------------------------------------------ Invariant test: King write function. ----------------------------
    /// @notice Invariant test to ensure only the KING can withdraw ETH.
    function invariant_OnlyKingCanWithdrawETH() public {
        // Revert, since DONOR50 isn't KING.
        vm.expectRevert();
        vm.prank(DONOR50);
        vault.withdrawETH(DONOR50, ETH_AMOUNT);
    }
}
