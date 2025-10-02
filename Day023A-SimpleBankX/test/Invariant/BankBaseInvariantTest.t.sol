// SPDX-License-Identifier: MIT

/// @title BankBaseInvariantTest (BankBase invariant test contract for SimpleBankX).
/// @author Michealking (@BuildsWithKing).
/// @notice Created on the 2nd of Oct, 2025.

pragma solidity ^0.8.30;

/// @notice Imports BaseTest contract and StdInvariant from forge standard library.
import {BaseTest} from "../BaseTest.t.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";

contract BankBaseInvariantTest is StdInvariant, BaseTest {
    // ------------------------------------------------- Invariant setUp function ------------------------
    /// @notice Runs before every invariant test.
    function setUp() public override {
        // Run main setUp function (baseTest).
        super.setUp();

        // Register SimpleBankX as fuzz target contract.
        targetContract(address(simpleBankX));

        // Whitelist only user-facing functions.
        bytes4[] memory selectors = new bytes4[](12);
        selectors[0] = simpleBankX.registerMyAddress.selector;
        selectors[1] = simpleBankX.unregisterMyAddress.selector;
        selectors[2] = simpleBankX.depositMyETH.selector;
        selectors[3] = simpleBankX.withdrawMyETH.selector;
        selectors[4] = simpleBankX.transferETH.selector;
        selectors[5] = simpleBankX.myRegistrationStatus.selector;
        selectors[6] = simpleBankX.checkUserRegistrationStatus.selector;
        selectors[7] = simpleBankX.activeUsersCount.selector;
        selectors[8] = simpleBankX.lifetimeUsersCount.selector;
        selectors[9] = simpleBankX.bankBalance.selector;
        selectors[10] = simpleBankX.myBalance.selector;
        selectors[11] = simpleBankX.checkUserBalance.selector;

        // Fuzz only user-facing contract.
        targetSelector(FuzzSelector({addr: address(simpleBankX), selectors: selectors}));
    }

    /// @notice Invariant test to ensure contract balance is consistent.
    function invariant_TotalBalanceConsistency() public {
        // Prank and getRegisteredUsers as KING.
        vm.prank(KING);
        address[] memory userAddresses = simpleBankX.getRegisteredUsers(0, 1000);

        // Assign sum.
        uint256 sum;

        // Loop through array's length.
        for (uint256 i = 0; i < userAddresses.length; i++) {
            sum += simpleBankX.checkUserBalance(userAddresses[i]);
        }

        // Assert sum is always equal to contract balance.
        assertEq(sum, address(simpleBankX).balance);
    }
}
