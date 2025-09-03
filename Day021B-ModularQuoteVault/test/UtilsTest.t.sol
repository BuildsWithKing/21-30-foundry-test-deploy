// SPDX-License-Identifier: MIT

/// @author Michealking(@BuildsWithKing).
/// @title UtilsTest for Utils (ModularQuoteVault).
/// @notice Created on 2nd Sept, 2025.

pragma solidity ^0.8.30;

/**
 * @notice Tests for utils contract.
 */

/// @notice Imports Test from forge standard library, ModularQuoteVaultTest, Utils and RejectETHTest contract.
import {Test} from "forge-std/Test.sol";
import {ModularQuoteVaultTest} from "./ModularQuoteVaultTest.t.sol";
import {Utils} from "../src/Utils.sol";
import {RejectETHTest} from "./RejectETHTest.t.sol";

contract UtilsTest is Test, ModularQuoteVaultTest {
    // ----------------------------------- Test for contract activation & deactivation ------------------------------------------------

    /// @notice Test to ensure contract reverts when inactive.
    function testContractRevertWhenInactive() external {
        // Write as Owner.
        vm.prank(owner);
        vm.expectEmit(true, false, false, false);
        emit Utils.ContractDeactivated(owner);
        utils.deactivateContract();

        // Revert with message "Inactive.
        vm.expectRevert(Utils.Inactive.selector);
        vm.prank(owner);
        utils.sendETH(user1, ETH_AMOUNT);

        // Access contract state.
        bool isActive = utils.isContractActive();

        // Assert both are same.
        assertEq(isActive, false);
    }

    /// @notice Test to ensure owner cant reactivate contract once active.
    function testOwnerCantReactivateContractOnceActive() external {
        // Revert with message "AlreadyActive".
        vm.expectRevert(Utils.AlreadyActive.selector);

        // Write as owner.
        vm.prank(owner);
        utils.activateContract();
    }

    /// @notice Test to ensure owner cant deactivate contract once deactivated.
    function testOwnerCantDeactivateContractOnceInactive() external {
        // Write as owner.
        vm.startPrank(owner);
        // Deactive contract.
        utils.deactivateContract();

        // Revert with message "AlreadyInactive".
        vm.expectRevert(Utils.AlreadyInactive.selector);
        utils.deactivateContract();

        bool isActive = utils.isContractActive();

        // Assert both are same.
        assertEq(isActive, false);

        // Stop prank.
        vm.stopPrank();
    }

    /// @notice Test to ensure only owner can activate contract.
    function testOnlyOwnerCanActiveContract() external {
        // Revert
        vm.expectRevert(Utils.Unauthorized.selector);
        vm.prank(user2);
        utils.activateContract();
    }

    /// @notice Test for activateContract.
    function testOwnerCanActivateContract() external {
        // Write as Owner.
        vm.prank(owner);
        vm.expectEmit(true, false, false, false);
        emit Utils.ContractDeactivated(owner);
        utils.deactivateContract();

        // Write as Owner.
        vm.prank(owner);
        vm.expectEmit(true, false, false, false);
        emit Utils.ContractActivated(owner);
        utils.activateContract();
    }

    // ---------------------------------------------- Tests for TransferOwnership & RenounceOwnership --------------------------------

    /// @notice Test to ensure owner can transfer ownership.
    function testTransferOwnership() external {
        // Emit OwnershipTransferred.
        vm.expectEmit(true, true, false, false);
        emit Utils.OwnershipTransferred(owner, newOwner);

        // Write as owner.
        vm.prank(owner);
        utils.transferOwnership(newOwner);
    }

    /// @notice Test owner cant transfer ownership to self, contract or zero address.
    function testOwnerCantTransferToSelfOrContractOrZeroAddress() external {
        // Write as owner.
        vm.startPrank(owner);

        // Revert with message "Invalid Address".
        vm.expectRevert(Utils.SameOwner.selector);
        utils.transferOwnership(owner);

        // Revert with message "Invalid Address".
        vm.expectRevert(Utils.InvalidAddress.selector);
        utils.transferOwnership(zero);

        // Revert with message "Invalid Address".
        vm.expectRevert(Utils.InvalidAddress.selector);
        utils.transferOwnership(address(utils));

        // Stop prank.
        vm.stopPrank();
    }

    /// @notice Test to ensure owner can renounce ownership.
    function testRenounceOwnerShip() external {
        // Emit OwnershipRenounced.
        vm.expectEmit(true, true, false, false);
        emit Utils.OwnershipRenounced(owner, zero);

        // Write as owner.
        vm.prank(owner);
        utils.renounceOwnership();
    }

    // ------------------------------------------- Tests for SendETH -----------------------------------------------------------------

    /// @notice Test to ensure only owner can send ETH.
    function testOnlyOwnerCanSendETH() external {
        // Revert with message "Unauthorized".
        vm.expectRevert(Utils.Unauthorized.selector);
        // Write as user2.
        vm.prank(user2);
        utils.sendETH(user2, ETH_AMOUNT);
    }

    /// @notice Test for sendETH.
    function testOwnerCansendETH() external {
        // Fund contract as user2.
        vm.prank(user2);
        (bool success,) = address(utils).call{value: ETH_AMOUNT}("");
        assertTrue(success);

        // Record balance before transfer.
        uint256 balanceBefore = address(this).balance;

        // Send ETH as Owner.
        vm.prank(owner);
        utils.sendETH(user1, ETH_AMOUNT);

        // Record balance after transfer.
        uint256 balanceAfter = address(this).balance;

        // Ensure both are same.
        assertEq(balanceBefore - balanceAfter, 0);
    }

    /// @notice Test for Withdraw ETH failed.
    function testWithdrawFailed() external {
        // Create new instance of RejectETH.
        RejectETHTest rejector = new RejectETHTest();

        // Withdraw as owner.
        vm.startPrank(owner);

        // Fund utlis contract with 0.1 ether.
        vm.deal(address(utils), ETH_AMOUNT);

        // Expect Revert since rejector rejects ETH.
        vm.expectRevert(Utils.WithdrawFailed.selector);

        // Send ETH as Owner.
        utils.sendETH(address(rejector), ETH_AMOUNT);

        vm.stopPrank();
    }

    /// @notice Test to ensure owner send ETH only when there's funds.
    function testOwnerCantSendETHOnEmptyFund() external {
        // Revert with message "NoFunds".
        vm.expectRevert(Utils.NoFunds.selector);

        // Send ETH as Owner.
        vm.prank(owner);
        utils.sendETH(user1, ETH_AMOUNT);
    }

    /// @notice Test to ensure owner can't send ETH greater than balance.
    function testOwnerCantSendETHGreaterThanBalance() external {
        // Fund Contract with 0.1 ether.
        vm.deal(address(utils), ETH_AMOUNT);

        // Revert With message "BalanceTooLow".
        vm.expectRevert(Utils.BalanceTooLow.selector);

        // Send ETH as Owner.
        vm.prank(owner);
        utils.sendETH(user1, STARTING_BALANCE);
    }

    // --------------------------- Test for receive & fallback --------------------------------------------------------------------------

    /// @notice Test for Receive.
    function testReceiveETH() external {
        // Write as user2.
        vm.startPrank(user2);
        (bool success,) = address(utils).call{value: ETH_AMOUNT}("");
        assertTrue(success);
        vm.stopPrank();

        // Assert Both are same.
        assertEq(address(utils).balance, ETH_AMOUNT);
    }

    /// @notice Test for fallback.
    function testFallback() external {
        // write as user2.
        vm.startPrank(user2);
        (bool success,) = address(utils).call{value: ETH_AMOUNT}(hex"abcd");
        assertTrue(success);
        vm.stopPrank();

        // Assert Both are same.
        assertEq(address(utils).balance, ETH_AMOUNT);
    }
}
