// SPDX-License-Identifier: MIT

/// @author Michealking (BuildsWithKing)
/// @title UtilsTest
/// @notice Created on 15th of Aug, 2025. 

pragma solidity ^0.8.30;

/// @notice Imports Test, AdvancedUserStorage, AdvancedUserStorageTest, Utils and RejectETH. 
import{Test} from "forge-std/Test.sol";
import {AdvancedUserStorage} from "../src/AdvancedUserStorage.sol";
import{AdvancedUserStorageTest} from "./AdvancedUserStorageTest.t.sol";
import{Utils} from "../src/Utils.sol";
import {RejectETH} from "./RejectETH.t.sol";

contract UtilsTest is Test, AdvancedUserStorageTest {

// ----------------------------------- Test for contract activation & deactivation ------------------------------------------------

    /// @notice Test to ensure contract reverts when inactive. 
    function testContractRevertWhenInactive() external {

        // Write as Owner. 
        vm.prank(owner);
        utils.deactivateContract();
       
        // Revert. 
        vm.expectRevert(Utils.Inactive.selector);
        vm.prank(owner);
        utils.withdrawETH(user1, ETH_AMOUNT);

        bool isActive = utils.isContractActive();

        // Ensure both are same. 
        assertEq(isActive, false);
    }

    /// @notice Test to ensure owner cant reactivate contract once active. 
    function testIfOwnerCantReactivateContractOnceActive() external {

        // Revert with message "AlreadyActive". 
        vm.expectRevert(Utils.AlreadyActive.selector);

        // Write as owner.  
        vm.prank(owner);
        utils.activateContract();
    }

    /// @notice Test to ensure owner cant deactivate contract once deactivated.
    function testIfOwnerCantDeactivateContractOnceInactive() external {
        
        // Write as owner. 
        vm.startPrank(owner);
        // Deactive contract. 
        utils.deactivateContract();

         // Revert with message "AlreadyInactive". 
        vm.expectRevert(Utils.AlreadyInactive.selector);
        utils.deactivateContract();

         bool isActive = utils.isContractActive();

        // Ensure both are same. 
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
        utils.deactivateContract();

        // Write as Owner. 
        vm.prank(owner);
        utils.activateContract();
    }

    /// @notice Test to ensure only owner can deactivate contract. 
    function testOnlyOwnerCanDeactiveContract() external {

        vm.expectRevert();

        // Write as user2.
        vm.prank(user2);
        utils.deactivateContract();

    }

    /// @notice Test for deactivateContract. 
    function testOwnerCanDeactiveContract() external {

        // Write as owner. 
        vm.prank(owner);
        utils.deactivateContract();
    }

// ------------------------------------------- Tests for withdrawETH -----------------------------------------------------------------

    /// @notice Test to ensure only owner can withdraw ETH. 
    function testOnlyOwnerCanWithdrawETH() external {
       
       // Revert with message "Unauthorized". 
        vm.expectRevert(Utils.Unauthorized.selector);
        // Write as user2. 
        vm.prank(user2);
        utils.withdrawETH(user2, ETH_AMOUNT);
    }

    /// @notice Test for withdrawETH. 
   function testOwnerCanWithdrawETH() external {

        // Fund contract as user2.  
        vm.prank(user2); 
        (bool success,) = address(utils).call{value: ETH_AMOUNT}("");
        assertTrue(success);

        // Record balance before withdrawal. 
        uint256 balanceBefore = address(this).balance;

        // Withdraw as Owner. 
        vm.prank(owner);
        utils.withdrawETH(user1, ETH_AMOUNT);

        // Record balance after withdrawal. 
        uint256 balanceAfter = address(this).balance;

        // Ensure both are same. 
        assertEq(balanceBefore - balanceAfter, 0);
    } 

    /// @notice Test for Withdraw ETH failed. 
    function testWithdrawFailed() external {

        // Create new instance of RejectETH. 
        RejectETH rejector = new RejectETH();

        // Withdraw as owner.
        vm.startPrank(owner);

        // Fund utlis contract with 0.1 ether.
        vm.deal(address(utils), ETH_AMOUNT);

        // Expect Revert since rejector rejects ETH.
        vm.expectRevert(Utils.WithdrawFailed.selector);

        // Withdraw as owner. 
        utils.withdrawETH(address(rejector), ETH_AMOUNT);

        vm.stopPrank();
    }
    
    /// @notice Test to ensure owner withdraws only when there's funds. 
    function testOwnerCantWithdrawETHOnEmptyFund() external {
       
        // Revert. 
        vm.expectRevert(Utils.NoFunds.selector);

        // withdraw as owner. 
        vm.prank(owner);
        utils.withdrawETH(user1, ETH_AMOUNT);
    }

    /// @notice Test to ensure owner can't withdraw ETH greater than balance. 
    function testOwnerCantWithdrawETHGreaterThanBalance() external {

        // Fund Contract with 0.1 ether.
        vm.deal(address(utils), ETH_AMOUNT);

        // Revert With message "BalanceTooLow".
        vm.expectRevert(Utils.BalanceTooLow.selector);

        vm.prank(owner);
        utils.withdrawETH(user1, startingBalance);
    }

// --------------------------- Test for receive & fallback --------------------------------------------------------------------------

    /// @notice Test for Receive. 
    function testReceiveETH() external {

        // Write as user2. 
        vm.startPrank(user2);
        (bool success,) = address(utils).call{value: ETH_AMOUNT}("");
        assertTrue(success);
        vm.stopPrank();

        assertEq(address(utils).balance, ETH_AMOUNT);
    }

    /// @notice Test for fallback. 
    function testFallback() external {

       // write as user2.
        vm.startPrank(user2);
        (bool success,) = address(utils).call{value: ETH_AMOUNT}(hex"abcd");
        assertTrue(success);
        vm.stopPrank();

        assertEq(address(utils).balance, ETH_AMOUNT); 
    }
}