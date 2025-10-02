// SPDX-License-Identifier: MIT

/// @title BankBaseUnitTest (BankBase unit test contract for SimpleBankX).
/// @author Michealking (@BuildsWithKing).
/// @notice Created on the 30th of Sept, 2025.

pragma solidity ^0.8.30;

/// @notice Imports BaseTest, Types and Utils contract.
import {BaseTest} from "../BaseTest.t.sol";
import {Types} from "../../src/Types.sol";
import {Utils} from "../../src/Utils.sol";

contract BankBaseUnitTest is BaseTest {
    // --------------------------------------- Unit Test: Users write functions ------------------------
    /// @notice Test to ensure users can successfully register.
    function testRegisterMyAddress_Succeeds() public {
        // Call internal `_registerUser1` helper function.
        _registerUser1();

        // Assign USER1's registration status.
        Types.RegistrationStatus status = simpleBankX.checkUserRegistrationStatus(USER1);

        // Assert USER1's registration status is 1 (Registered).
        assertEq(uint8(status), 1);
    }

    /// @notice Test to ensure users can register only once.
    function testRegisterMyAddress_RevertsAlreadyRegistered() public {
        // Call internal `_registerUser1` helper function.
        _registerUser1();

        // Revert if USER1 tries reregistering.
        vm.expectRevert(Utils.AlreadyRegistered.selector);
        vm.prank(USER1);
        simpleBankX.registerMyAddress();
    }

    /// @notice Test to ensure users can unregister successfully.
    function testUnregisterMyAddress_Succeeds() public {
        // Call internal `_registerUser1` helper function.
        _registerUser1();

        // Prank and unregister as USER1.
        vm.prank(USER1);
        vm.expectEmit(true, true, false, false);
        emit Types.UnregisteredWithRefund(USER1, 0);
        simpleBankX.unregisterMyAddress();

        // Assign USER1's registration status.
        Types.RegistrationStatus status = simpleBankX.checkUserRegistrationStatus(USER1);

        // Assert USER1's status is 0 (NotRegistered).
        assertEq(uint8(status), 0);
    }

    /// @notice Test to ensure only registered users can unregister.
    function testUnRegisterMyAddress_RevertsNotRegistered() public {
        // Revert NotRegistered, since USER2 haven't registered.
        vm.expectRevert(Utils.NotRegistered.selector);
        vm.prank(USER2);
        simpleBankX.unregisterMyAddress();
    }

    /// @notice Test to ensure unregister reverts for failed withdrawal.
    function testUnregisterMyAddress_RevertsWithdrawalFailed() public {
        // Prank and register as rejector.
        vm.startPrank(address(rejector));
        simpleBankX.registerMyAddress();

        // Deposit ETH as rejector.
        simpleBankX.depositMyETH{value: ETH_AMOUNT}();

        // Assign balanceBefore.
        uint256 balanceBefore = simpleBankX.myBalance();

        // Revert WithdrawalFailed, since rejector rejects ETH.
        vm.expectRevert(Utils.WithdrawalFailed.selector);
        simpleBankX.unregisterMyAddress();

        // Assign balanceAfter.
        uint256 balanceAfter = simpleBankX.myBalance();

        // Stop prank.
        vm.stopPrank();

        // Assert rejector's balance after withdrawal is equal to balance before.
        assertEq(balanceAfter, balanceBefore);
    }

    /// @notice Test to ensure swap and pop works correctly once users unregisters.
    function testSwapAndPop_Succeeds() public {
        // Call internal `_registerUser1` helper function.
        _registerUser1();

        // Call internal `_registerUser2` helper function.
        _registerUser2();

        // Call internal `_registerUser3` helper function.
        _registerUser3();

        // Prank and unregister as USER2.
        vm.prank(USER2);
        vm.expectEmit(true, true, false, false);
        emit Types.UnregisteredWithRefund(USER2, 0);
        simpleBankX.unregisterMyAddress();

        // Prank and getRegisteredUsers as KING.
        vm.prank(KING);
        address[] memory userAddresses = simpleBankX.getRegisteredUsers(0, 3);

        // Assert USER1 and USER3 index on userAddresses array.
        assertEq(userAddresses[0], USER1);
        assertEq(userAddresses[1], USER3);
    }

    /// @notice Test to ensure users can successfully deposit ETH.
    function testDepositMyETH_Succeeds() public {
        // Call internal `_registerUser1` helper function.
        _registerUser1();

        // Prank and deposit ETH as USER1.
        vm.startPrank(USER1);
        vm.expectEmit(true, true, false, false);
        emit Types.EthDeposited(USER1, 0);
        simpleBankX.depositMyETH{value: ETH_AMOUNT}();

        // Assign myBalance.
        uint256 myBalance = simpleBankX.myBalance();

        // Stop prank.
        vm.stopPrank();

        // Assert USER1's balance is equal to 1 ETH.
        assertEq(myBalance, ETH_AMOUNT);
    }

    /// @notice Test to ensure only registered users can deposit ETH.
    function testDepositMyETH_RevertsNotRegistered() public {
        // Revert NotRegistered, since USER2 haven't registered.
        vm.expectRevert(Utils.NotRegistered.selector);
        vm.prank(USER2);
        simpleBankX.depositMyETH();
    }

    /// @notice Test to ensure users can't deposit zero ETH.
    function testDepositMyETH_RevertsAmountTooLow() public {
        // Call internal `_registerUser1` helper function.
        _registerUser1();

        // Revert AmountTooLow, if USER1 tries depositing zero ETH.
        vm.expectRevert(Utils.AmountTooLow.selector);
        vm.prank(USER1);
        simpleBankX.depositMyETH{value: 0}();
    }

    /// @notice Test to ensure registered users can withdraw ETH deposited.
    function testWithdrawMyETH_Succeeds() public {
        // Call internal `_registerUser1` helper function.
        _registerUser1();

        // Prank and deposit ETH as USER1.
        vm.startPrank(USER1);
        vm.expectEmit(true, true, false, false);
        emit Types.EthDeposited(USER1, 0);
        simpleBankX.depositMyETH{value: ETH_AMOUNT}();

        // Assign balanceBefore.
        uint256 balanceBefore = simpleBankX.myBalance();

        // Withdraw ETH as USER1.
        vm.expectEmit(true, true, false, false);
        emit Types.EthWithdrawn(USER1, 0);
        simpleBankX.withdrawMyETH(ETH_AMOUNT);

        // Assign balanceAfter.
        uint256 balanceAfter = simpleBankX.myBalance();

        // Stop prank.
        vm.stopPrank();

        // Assert USER1's balance after withdrawal is less than balance before.
        assertLt(balanceAfter, balanceBefore);
    }

    /// @notice Test to ensure only registered users can withdraw ETH.
    function testWithdrawMyETH_RevertsNotRegistered() public {
        // Revert NotRegistered, since USER3 haven't registered.
        vm.expectRevert(Utils.NotRegistered.selector);
        vm.prank(USER3);
        simpleBankX.withdrawMyETH(ETH_AMOUNT);
    }

    /// @notice Test to ensure users with zero bank balance can't withdraw.
    function testWithdrawMyETH_RevertsInsufficientBalance() public {
        // Call internal `_registerUser1` helper function.
        _registerUser1();

        // Call internal `_registerUser2` helper function.
        _registerUser2();

        // Revert InsufficientBalance, since USER2 haven't deposited.
        vm.expectRevert(Utils.InsufficientBalance.selector);
        vm.prank(USER2);
        simpleBankX.withdrawMyETH(ETH_AMOUNT);
    }

    /// @notice Test to ensure failed withdrawal reverts.
    function testWithdrawMyETH_RevertsWithdrawalFailed() public {
        // Prank and register as rejector.
        vm.startPrank(address(rejector));
        simpleBankX.registerMyAddress();

        // Deposit ETH as rejector.
        simpleBankX.depositMyETH{value: ETH_AMOUNT}();

        // Assign balanceBefore.
        uint256 balanceBefore = simpleBankX.myBalance();

        // Revert WithdrawalFailed, since rejector rejects ETH.
        vm.expectRevert(Utils.WithdrawalFailed.selector);
        simpleBankX.withdrawMyETH(ETH_AMOUNT);

        // Assign balanceAfter.
        uint256 balanceAfter = simpleBankX.myBalance();

        // Stop prank.
        vm.stopPrank();

        // Assert rejector's balance after withdrawal is equal to balance before.
        assertEq(balanceAfter, balanceBefore);
    }

    /// @notice Test to ensure registered users can transfer ETH.
    function testTransferETH_Succeeds() public {
        // Call internal `_registerUser1` helper function.
        _registerUser1();

        // Call internal `_registerUser2` helper function.
        _registerUser2();

        // Call internal `_registerUser3` helper function.
        _registerUser3();

        // Prank and deposit ETH as USER1.
        vm.startPrank(USER1);
        simpleBankX.depositMyETH{value: STARTING_BALANCE}();

        // Assign USER1's balance before transfer.
        uint256 balanceBefore = simpleBankX.myBalance();

        // Transfer 1 ETH to USER2.
        simpleBankX.transferETH(USER2, ETH_AMOUNT);

        // Transfer 1 ETH to USER3.
        simpleBankX.transferETH(USER3, ETH_AMOUNT);

        // Assign USER1's balance after transfer.
        uint256 balanceAfter = simpleBankX.myBalance();

        // Stop prank.
        vm.stopPrank();

        // Assert USER1's balance after is less than balance before transfer.
        assertLt(balanceAfter, balanceBefore);

        // Assert USER2 and USER3 balance are both equal to 1 ETH.
        assertEq(simpleBankX.checkUserBalance(USER2), ETH_AMOUNT);
        assertEq(simpleBankX.checkUserBalance(USER3), ETH_AMOUNT);
    }

    /// @notice Test to ensure users with zero bank balance can't transfer ETH.
    function testTransferETH_RevertsInsufficientBalance() public {
        // Call internal `_registerUser1` helper function.
        _registerUser1();

        // Call internal `_registerUser2` helper function.
        _registerUser2();

        // Revert InsufficientBalance, since USER2 haven't deposited.
        vm.expectRevert(Utils.InsufficientBalance.selector);
        vm.prank(USER2);
        simpleBankX.transferETH(USER1, ETH_AMOUNT);
    }

    /// @notice Test to ensure only registered users can transfer ETH.
    function testTransferETH_RevertsNotRegistered() public {
        // Revert NotRegistered, since USER1 haven't registered.
        vm.expectRevert(Utils.NotRegistered.selector);
        vm.prank(USER1);
        simpleBankX.transferETH(USER3, STARTING_BALANCE);
    }

    /// @notice Test to ensure users can't transfer ETH to self.
    function testTransferETH_RevertsSelfTransferFailed() public {
        // Call internal `_registerUser1` helper function.
        _registerUser1();

        // Prank and deposit ETH as USER1.
        vm.startPrank(USER1);
        simpleBankX.depositMyETH{value: STARTING_BALANCE}();

        // Revert SelfTransferFailed, since address belongs to USER1.
        vm.expectRevert(Utils.SelfTransferFailed.selector);
        simpleBankX.transferETH(USER1, ETH_AMOUNT);

        // Stop prank.
        vm.stopPrank();

        // Assert USER1's balance remains the same.
        assertEq(simpleBankX.checkUserBalance(USER1), STARTING_BALANCE);
    }

    /// @notice Test to ensure only registered users can recieve ETH transfer.
    function testTransferETH_RevertsWhenReceiverIsNotRegistered() public {
        // Call internal `_registerUser1` helper function.
        _registerUser1();

        // Prank and deposit ETH as USER1.
        vm.startPrank(USER1);
        simpleBankX.depositMyETH{value: STARTING_BALANCE}();

        // Revert NotRegistered, since USER2 haven't registered.
        vm.expectRevert(Utils.NotRegistered.selector);
        simpleBankX.transferETH(USER2, ETH_AMOUNT);

        // Stop prank.
        vm.stopPrank();

        // Assert USER1's balance remains the same.
        assertEq(simpleBankX.checkUserBalance(USER1), STARTING_BALANCE);
    }

    // ------------------------------------------------ Unit Test: Users read functions -------------------------------
    /// @notice Test to ensure users can check their registration status.
    function testMyRegistrationStatus_Returns() public {
        // Call internal `_registerUser1` helper function.
        _registerUser1();

        // Prank and read status as USER1.
        vm.prank(USER1);
        Types.RegistrationStatus status = simpleBankX.myRegistrationStatus();

        // Assert USER1's registration status is equal to 1 (Registered).
        assertEq(uint8(status), 1);
    }

    /// @notice Test to ensure users can check the registration status of another.
    function testCheckUserRegistrationStatus_Returns() public {
        // Call internal `_registerUser1` helper function.
        _registerUser1();

        // Call internal `_registerUser2` helper function.
        _registerUser2();

        // Prank and read status as USER1.
        vm.prank(USER1);
        Types.RegistrationStatus status = simpleBankX.checkUserRegistrationStatus(USER2);

        // Assert USER2's registration status is equal to 1 (Registered).
        assertEq(uint8(status), 1);
    }

    /// @notice Test to ensure active users returns existing users count.
    function testActiveUsers_Returns() public {
        // Call internal `_registerUser1` helper function.
        _registerUser1();

        // Call internal `_registerUser2` helper function.
        _registerUser2();

        // Call internal `_registerUser3` helper function.
        _registerUser3();

        // Prank and unregister as USER2.
        vm.prank(USER2);
        simpleBankX.unregisterMyAddress();

        // Assert active users count is equal to 2.
        assertEq(simpleBankX.activeUsersCount(), 2);
    }

    /// @notice Test to ensure lifetime users returns total users ever registered.
    function testLifetimeUsers_Returns() public {
        // Call internal `_registerUser1` helper function.
        _registerUser1();

        // Call internal `_registerUser2` helper function.
        _registerUser2();

        // Call internal `_registerUser3` helper function.
        _registerUser3();

        // Prank and unregister as USER2.
        vm.prank(USER2);
        simpleBankX.unregisterMyAddress();

        // Assert lifetime users count is equal to 3.
        assertEq(simpleBankX.lifetimeUsersCount(), 3);
    }

    /// @notice Test to ensure users can check their balance.
    function testCheckMyBalance_Returns() public {
        // Call internal `_registerUser1` helper function.
        _registerUser1();

        // Call internal `_registerUser2` helper function.
        _registerUser2();

        // Prank and deposit ETH as USER2.
        vm.startPrank(USER2);
        simpleBankX.depositMyETH{value: ETH_AMOUNT}();

        // Assign myBalance.
        uint256 myBalance = simpleBankX.myBalance();

        // Stop prank.
        vm.stopPrank();

        // Assert USER2's balance is equal to 1 ETH.
        assertEq(myBalance, ETH_AMOUNT);
    }

    /// @notice Test to ensure users can check other users balance.
    function testCheckUserBalance_Returns() public view {
        // Assert USER3's balance is equal to zero.
        assertEq(simpleBankX.checkUserBalance(USER3), 0);
    }

    /// @notice Test to ensure users can view bank balance.
    function testBankBalance_Returns() public {
        // Call internal `_registerUser1` helper function.
        _registerUser1();

        // Call internal `_registerUser2` helper function.
        _registerUser2();

        // Prank and deposit ETH as USER2.
        vm.prank(USER2);
        simpleBankX.depositMyETH{value: ETH_AMOUNT}();

        //  Assert bank balance is equal to 1 ETH.
        assertEq(simpleBankX.bankBalance(), ETH_AMOUNT);
    }
}
