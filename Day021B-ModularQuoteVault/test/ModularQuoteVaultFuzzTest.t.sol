// SPDX-License-Identifier: MIT

/// @author Michealking(@BuildsWithKing).
/// @title ModularQuoteVaultFuzzTest.
/// @notice Created on 3rd of Sept, 2025.

/**
 * Fuzz testing _deletedata.
 */
pragma solidity ^0.8.30;

/// @notice Imports Test from forge standard library, Types and ModularQuoteVaultTest contract.
import {Test} from "forge-std/Test.sol";
import {Types} from "../src/Types.sol";
import {ModularQuoteVaultTest} from "./ModularQuoteVaultTest.t.sol";

contract ModularQuoteVaultFuzzTest is Test, ModularQuoteVaultTest {
    /// @notice Fuzz test: Creates user, store quotes, then delete.
    function testFuzz_ClearUserQuotes_andDeleteData(address userAddress, uint8 quoteCount) external {
        // Assume user address is not address zero or owner address.
        vm.assume(userAddress != zero && userAddress != owner);

        // Write as user.
        vm.startPrank(userAddress);

        // Register Users
        modularQuoteVault.register(
            "Michealking BuildsWithKing", 23, Types.Gender.Male, "buildswithking@gmail.com", "Solidity Developer"
        );

        // Store N quotes.
        // Limit fuzz quotes to something manageable.
        uint8 n = quoteCount = 5;

        // Loop through quotes.
        for (uint8 i = 0; i < n; i++) {
            // Store quotes.
            modularQuoteVault.storeQuote(
                "Michealking BuildsWithKing", "Consistency builds mastery", "Self", "Mindset", "I'm here to prove it"
            );
        }

        // Delete user data (this calls internal _clearUserQuotes).
        modularQuoteVault.deleteMyData();

        // Stop prank.
        vm.stopPrank();

        // Assert user is no longer registered.
        assertFalse(modularQuoteVault.checkIfRegistered(userAddress), "User should be unregistered");

        // Assert active quotes count is equal to zero.
        assertEq(modularQuoteVault.getActiveQuoteCount(), 0, "No quotes should remain after deletion");

        // Assert total quotes is equal 5.
        assertEq(modularQuoteVault.getTotalQuotes(), 5, "Total quotes should adjust");

        // Assert active users is equal to zero.
        assertEq(modularQuoteVault.getActiveUserCount(), 0, "No Active User");
    }
}
