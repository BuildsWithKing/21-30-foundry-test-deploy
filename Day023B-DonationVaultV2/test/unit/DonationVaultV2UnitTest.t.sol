// SPDX-License-Identifier: MIT

/// @title DonationVaultV2UnitTest (DonationVaultV2 unit test contract).
/// @author Michealking (@BuildsWithKing).
/// @notice Created on the 4th of Oct, 2025.

pragma solidity ^0.8.30;

/// @notice Imports BaseTest, Types and Utils contract.
import {BaseTest} from "../BaseTest.t.sol";
import {Types} from "../../src/Types.sol";
import {Utils} from "../../src/Utils.sol";

contract DonationVaultV2UnitTest is BaseTest {
    // --------------------------------------- Unit test: Donors write function ------------------------------------
    /// @notice Test to ensure donors can successfully `donateETH`.
    function testDonateETH_Succeeds() public {
        // Call internal `_donateDONOR1` helper function.
        _donateDONOR1();

        // Call internal `_donateDONOR2` helper function.
        _donateDONOR2();

        // Call internal `_donateDONOR3` helper function.
        _donateDONOR3();

        // Assert vault balance is equal to 3 ETH.
        assertEq(vault.vaultBalance(), THREE_ETHER);
    }

    /// @notice Test to ensure donors can't donate zero ETH.
    function testDonateETH_RevertsAmountTooLow() public {
        // Revert `AmountTooLow`, if DONOR2 tries depositing zero ETH.
        vm.expectRevert(Utils.AmountTooLow.selector);
        vm.prank(DONOR2);
        vault.donateETH{value: 0}();
    }

    /// @notice Test to ensure donors can't donate ETH when contract is paused.
    function testDonateETH_RevertsWhenPaused() public {
        // Prank as king.
        vm.prank(KING);
        vault.pauseContract();

        // Revert, since contract is paused.
        vm.expectRevert();
        vm.prank(DONOR2);
        vault.donateETH{value: ETH_AMOUNT}();
    }

    // ------------------------------------------ Unit test: Donors read functions ---------------------------
    /// @notice Test to ensure `lifetimeDonorsCount` returns.
    function testLifetimeDonorsCount_Returns() public {
        // Call internal `_donateDONOR1` helper function.
        _donateDONOR1();

        // Assert lifetime donors count is equal to one.
        assertEq(vault.lifetimeDonorsCount(), 1);

        // Assert vault balance is equal to 1 ETH.
        assertEq(vault.vaultBalance(), ETH_AMOUNT);
    }

    /// @notice Test to ensure `totalETHDonated` returns.
    function testTotalETHDonated_Returns() public {
        // Call internal `_donateDONOR1` helper function.
        _donateDONOR1();

        // Call internal `_donateDONOR2` helper function.
        _donateDONOR2();

        // Call internal `_donateDONOR3` helper function.
        _donateDONOR3();

        // Assert vault balance is equal to 3 ETH.
        assertEq(vault.vaultBalance(), THREE_ETHER);

        // Assert total ETH donated is equal to 3 ETH.
        assertEq(vault.totalETHDonated(), THREE_ETHER);
    }

    /// @notice Test to ensure donors can view other donor's donation status.
    function testViewDonorsDonationStatus_Returns() public {
        // Call internal `_donateDONOR1` helper function.
        _donateDONOR1();

        // Assert DONOR1's donation status is true.
        assertEq(vault.viewDonorDonationStatus(DONOR1), true);

        // Assert DONOR3's donation status is false.
        assertEq(vault.viewDonorDonationStatus(DONOR3), false);
    }

    /// @notice Test to ensure `myDonation` returns.
    function testMyDonation_Returns() public {
        // Call internal `_donateDONOR2` helper function.
        _donateDONOR2();

        // Prank as DONOR2.
        vm.prank(DONOR2);
        uint256 myDonation = vault.myDonation();

        // Assert DONOR2's donation balance is equal to 1 ETH.
        assertEq(myDonation, ETH_AMOUNT);
    }

    /// @notice Test to ensure `viewDonorBalance` returns.
    function testViewDonorBalance_Returns() public {
        // Call internal `_donateDONOR3` helper function.
        _donateDONOR3();

        // Call internal `_donateDONOR3` helper function.
        _donateDONOR3();

        // Call internal `_donateDONOR3` helper function.
        _donateDONOR3();

        // Prank as DONOR1.
        vm.prank(DONOR1);
        uint256 donorBalance = vault.viewDonorBalance(DONOR3);

        // Assert DONOR3's donation balance is equal to 3 ETH.
        assertEq(donorBalance, THREE_ETHER);
    }

    /// @notice Test to ensure `vaultBalance` returns.
    function testVaultBalance_Returns() public {
        // Call internal `_donateDONOR1` helper function.
        _donateDONOR1();

        // Call internal `_donateDONOR2` helper function.
        _donateDONOR2();

        // Call internal `_donateDONOR3` helper function.
        _donateDONOR3();

        // Assert vault balance is equal to 3 ETH.
        assertEq(vault.vaultBalance(), THREE_ETHER);
    }

    // ---------------------------------------------- Unit test: King's write function ----------------------------
    /// @notice Test to ensure KING can withdraw ETH.
    function testWithdrawETH_Succeeds() public {
        // Call internal `_donateDONOR1` helper function.
        _donateDONOR1();

        // Call internal `_donateDONOR2` helper function.
        _donateDONOR2();

        // Call internal `_donateDONOR3` helper function.
        _donateDONOR3();

        // Emit EthWithdrawn, prank and withdraw ETH as KING.
        vm.expectEmit(true, true, true, false);
        emit Types.EthWithdrawn(KING, DONOR50, THREE_ETHER);
        vm.prank(KING);
        vault.withdrawETH(DONOR50, THREE_ETHER);

        // Assert vault balance is equal to zero after KING withdraws.
        assertEq(vault.vaultBalance(), 0);
    }

    /// @notice Test to ensure only the KING can withdraw ETH.
    function testWithdrawETH_Reverts() public {
        // Call internal `_donateDONOR1` helper function.
        _donateDONOR1();

        // Call internal `_donateDONOR2` helper function.
        _donateDONOR2();

        // Revert, since DONOR3 isn't the KING.
        vm.expectRevert();
        vm.prank(DONOR3);
        vault.withdrawETH(DONOR3, ETH_AMOUNT);
    }

    /// @notice Test to ensure KING can't withdraw ETH on zero vault balance.
    function testWithdrawETH_RevertsInsufficientBalance() public {
        // Revert `InsufficientBalance`, since contract balance is empty.
        vm.expectRevert(Utils.InsufficientBalance.selector);
        vm.prank(KING);
        vault.withdrawETH(DONOR50, ETH_AMOUNT);
    }

    /// @notice Test to ensure KING can't withdraw ETH to the zero or this contract address.
    function testWithdrawETH_RevertsInvalidAddress() public {
        // Call internal `_donateDONOR3` helper function.
        _donateDONOR3();

        // Revert `InvalidAddress`, since the receiver's address is the zero address.
        vm.expectRevert(Utils.InvalidAddress.selector);
        vm.prank(KING);
        vault.withdrawETH(address(0), ETH_AMOUNT);

        // Revert `InvalidAddress`, since the receiver's address is this contract address.
        vm.expectRevert(Utils.InvalidAddress.selector);
        vm.prank(KING);
        vault.withdrawETH(address(vault), ETH_AMOUNT);

        // Assert vault balance remains the same.
        assertEq(vault.vaultBalance(), ETH_AMOUNT);
    }

    /// @notice Test to ensure failed withdrawal reverts.
    function testWithdrawETH_RevertsWithdrawalFailed() public {
        // Call internal `_donateDONOR1` helper function.
        _donateDONOR1();

        // Assign balanceBefore and view vault's balance.
        uint256 balanceBefore = vault.vaultBalance();

        // Revert WithdrawalFailed, since rejector rejects ETH.
        vm.expectRevert(Utils.WithdrawalFailed.selector);
        vm.prank(KING);
        vault.withdrawETH(address(rejector), ETH_AMOUNT);

        // Assign balanceAfter and view vault's balance.
        uint256 balanceAfter = vault.vaultBalance();

        // Assert vault's balance before is equal to balance after KING attempts withdrawETH.
        assertEq(balanceBefore, balanceAfter);
    }

    // ------------------------------------------------------- Unit test: King's read function ------------------------------------
    /// @notice Test to ensure KING can `getDonorsAddresses`.
    function testGetDonorsAddresses_Returns() public {
        // Call internal `_donateDONOR1` helper function.
        _donateDONOR1();

        // Call internal `_donateDONOR2` helper function.
        _donateDONOR2();

        // Call internal `_donateDONOR3` helper function.
        _donateDONOR3();

        // Prank and getDonorsAddresses as KING.
        vm.prank(KING);
        address[] memory donorAddresses = vault.getDonorsAddresses(0, 3);

        // Assert DONOR1 is at index zero, DONOR2 is at index one, DONOR3 is at index two.
        assertEq(donorAddresses[0], DONOR1);
        assertEq(donorAddresses[1], DONOR2);
        assertEq(donorAddresses[2], DONOR3);
    }

    /// @notice Test to ensure _end resets bounds.
    function testGetDonorsAddresses_ResetsBounds() public {
        // Call internal `_donateDONOR1` helper function.
        _donateDONOR1();

        // Call internal `_donateDONOR2` helper function.
        _donateDONOR2();

        // Call internal `_donateDONOR3` helper function.
        _donateDONOR3();

        // Prank and getDonorsAddresses as KING.
        vm.prank(KING);
        address[] memory donorAddresses = vault.getDonorsAddresses(0, 500);

        // Assert DONOR1 is at index zero, DONOR2 is at index one, DONOR3 is at index two.
        assertEq(donorAddresses[0], DONOR1);
        assertEq(donorAddresses[1], DONOR2);
        assertEq(donorAddresses[2], DONOR3);
    }

    /// @notice Test to ensure `getDonorsAddresses` returns empty array.
    function testGetDonorsAddresses_ReturnsEmptyArray() public {
        // Prank and getDonorsAddresses as KING.
        vm.prank(KING);
        address[] memory donorAddresses = vault.getDonorsAddresses(5, 3);

        // Assert donorsAddresses array's length is equal to zero.
        assertEq(donorAddresses.length, 0);
    }

    /// @notice Test to ensure only the KING can `getDonorsAddresses`.
    function testGetDonorsAddresses_Reverts() public {
        // Call internal `_donateDONOR1` helper function.
        _donateDONOR1();

        // Call internal `_donateDONOR2` helper function.
        _donateDONOR2();

        // Revert, since DONOR3 isn't the KING.
        vm.expectRevert();
        vm.prank(DONOR3);
        vault.getDonorsAddresses(0, 2);
    }

    /// @notice Test to ensure `HighOffset` reverts.
    function testGetDonorsAddresses_RevertsHighOffset() public {
        // Call internal `_donateDONOR1` helper function.
        _donateDONOR1();

        // Call internal `_donateDONOR2` helper function.
        _donateDONOR2();

        // Revert HighOffset, since donors are less than 20.
        vm.expectRevert(Utils.HighOffset.selector);
        // Prank and getDonorsAddresses as KING.
        vm.prank(KING);
        vault.getDonorsAddresses(20, 3);
    }

    /// @notice Test to ensure `HighLimit` reverts.
    function testGetDonorsAddresses_RevertsHighLimit() public {
        // Call internal `_donateDONOR1` helper function.
        _donateDONOR1();

        // Call internal `_donateDONOR2` helper function.
        _donateDONOR2();

        // Revert HighLimit, since donors are less than 2000.
        vm.expectRevert(Utils.HighLimit.selector);
        // Prank and getDonorsAddresses as KING.
        vm.prank(KING);
        vault.getDonorsAddresses(0, 2000);
    }

    // ------------------------------------------------- Unit test: Receive and fallback function ---------------------------------------
    /// @notice Test to ensure receive handles ETH without calldata.
    function testReceive_Succeeds() public {
        // Prank and deposit ETH as DONOR50.
        vm.prank(DONOR50);
        (bool success,) = address(vault).call{value: ETH_AMOUNT}("");
        assertTrue(success);

        // Assert vault balance is equal to 1 ETH.
        assertEq(vault.vaultBalance(), ETH_AMOUNT);
    }

    /// @notice Test to ensure fallback handles ETH with calldata.
    function testFallback_Succeeds() public {
        // Prank and deposit ETH as DONOR50.
        vm.prank(DONOR50);
        (bool success,) = address(vault).call{value: ETH_AMOUNT}(
            hex"55641345000000000000000000000000000000000000000000000000000000000000006d"
        );
        assertTrue(success);

        // Assert vault balance is equal to 1 ETH.
        assertEq(vault.vaultBalance(), ETH_AMOUNT);
    }
}
