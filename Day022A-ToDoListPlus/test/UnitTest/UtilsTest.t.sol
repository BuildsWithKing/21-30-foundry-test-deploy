// SPDX-License-Identifier: MIT

/// @title Utils (Utils Unit Test Contract).
/// @author Michealking (@BuildsWithKing).
/// @notice Created on 9th of Sept, 2025.

pragma solidity ^0.8.30;

/// @notice Imports BaseTest and Utils contract.
import {BaseTest} from "./BaseTest.t.sol";
import {Utils} from "../../src/Utils.sol";

contract UtilsTest is BaseTest {
    // ----------------------------------- Test for contract activation & deactivation ------------------------------------------------

    /// @notice Test to ensure contract reverts when inactive.
    function testContractRevertWhenInactive() external {
        // Write as Owner.
        vm.startPrank(owner);
        vm.expectEmit(true, false, false, false);
        emit Utils.ContractDeactivated(owner);
        utils.deactivateContract();

        // Revert with "InactiveContract.
        vm.expectRevert(Utils.InactiveContract.selector);
        utils.renounceOwnership();

        // Stop writing as owner.
        vm.stopPrank();
    }

    /// @notice Test to ensure owner cant reactivate contract once active.
    function testOwnerCantReactivateContractOnceActive() external {
        // Revert with "AlreadyActive".
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

        // Revert with "AlreadyInactive".
        vm.expectRevert(Utils.AlreadyInactive.selector);
        utils.deactivateContract();

        // Stop prank.
        vm.stopPrank();
    }

    /// @notice Test to ensure only owner can activate contract.
    function testOnlyOwnerCanActiveContract() external {
        // Revert with "Unauthorized".
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

        // Revert with "Invalid Address".
        vm.expectRevert(Utils.SameOwner.selector);
        utils.transferOwnership(owner);

        // Revert with "Invalid Address".
        vm.expectRevert(Utils.InvalidAddress.selector);
        utils.transferOwnership(zero);

        // Revert with "Invalid Address".
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

    // ------------------------------------- Test for receieve and fallback -----------------------------

    /// @notice Test to ensure receive rejects ETH.
    function testReceiveRejectsETH() external {
        // Write as user2.
        vm.prank(user2);
        vm.expectRevert(Utils.ETHRejected.selector);
        (bool success,) = address(utils).call{value: ETH_AMOUNT}("");
        assertFalse(!success);
    }

    /// @notice Test to ensure fallback rejects ETH.
    function testFallbackRejectsETH() external {
        // Write as user2.
        vm.prank(user2);
        vm.expectRevert(Utils.ETHRejected.selector);
        (bool success,) = address(utils).call{value: ETH_AMOUNT}("hexabcd");
        assertFalse(!success);
    }
}
