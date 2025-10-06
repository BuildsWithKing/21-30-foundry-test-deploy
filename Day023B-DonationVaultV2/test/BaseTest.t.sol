// SPDX-License-Identifier: MIT

/// @title BaseTest (BaseTest contract for DonationVaultV2).
/// @author Michealking (@BuildsWithKing).
/// @notice Created on the 4th of Oct, 2025.

pragma solidity ^0.8.30;

/// @notice Imports Test from forge standard library, Types, Utils, VaultManager, DonationVaultV2 and RejectETHTest contract.
import {Test} from "forge-std/Test.sol";
import {Types} from "../src/Types.sol";
import {Utils} from "../src/Utils.sol";
import {VaultManager} from "../src/VaultManager.sol";
import {DonationVaultV2} from "../src/DonationVaultV2.sol";
import {RejectETHTest} from "./RejectETHTest.t.sol";

contract BaseTest is Test {
    // -------------------------------------------------- State variables ---------------------------------
    /// @notice Assigns vault & rejector.
    DonationVaultV2 vault;
    RejectETHTest rejector;

    /// @notice Assigns KING, DONOR1, DONOR2, DONOR3 and DONOR50.
    address internal constant KING = address(0x10);
    address internal constant DONOR1 = address(0x1);
    address internal constant DONOR2 = address(0x2);
    address internal constant DONOR3 = address(0x3);
    address internal constant DONOR50 = address(0x50);

    /// @notice Assigns STARTING_BALANCE, ETH_AMOUNT and THREE_ETHER.
    uint256 internal constant STARTING_BALANCE = 10 ether;
    uint256 internal constant ETH_AMOUNT = 1 ether;
    uint256 internal constant THREE_ETHER = 3 ether;

    // --------------------------------------------------- Setup function -----------------------------------
    /// @notice This function runs before every other function.
    function setUp() public virtual {
        // Create new instance of DonationVaultV2 and RejectETHTest contract.
        vault = new DonationVaultV2(KING);
        rejector = new RejectETHTest();

        // Label DONATIONVAULTV2, KING, DONOR1, DONOR2 and DONOR3.
        vm.label(address(vault), "DONATIONVAULTV2");
        vm.label(KING, "KING");
        vm.label(DONOR1, "DONOR1");
        vm.label(DONOR2, "DONOR2");
        vm.label(DONOR3, "DONOR3");
        vm.label(DONOR50, "DONOR50");

        // Fund 10 ETH to DONOR1, DONOR2, DONOR3, DONOR50 and rejector.
        vm.deal(DONOR1, STARTING_BALANCE);
        vm.deal(DONOR2, STARTING_BALANCE);
        vm.deal(DONOR3, STARTING_BALANCE);
        vm.deal(DONOR50, STARTING_BALANCE);
        vm.deal(address(rejector), STARTING_BALANCE);
    }

    // ---------------------------------------------------- Constructor -----------------------------------------

    /// @notice Test to ensure constructor sets king at deployment.
    function testConstructorSetsKing_AtDeployment() public view {
        // Assert current king is same as KING.
        assertEq(vault.currentKing(), KING);
    }

    // ------------------------------------------------------ Internal helper functions ---------------------------
    /// @notice Donate as DONOR1.
    function _donateDONOR1() internal {
        // Emit EthDonated.
        vm.expectEmit(true, true, false, false);
        emit Types.EthDonated(DONOR1, ETH_AMOUNT);

        // Prank as DONOR1.
        vm.prank(DONOR1);
        vault.donateETH{value: ETH_AMOUNT}();
    }

    /// @notice Donate as DONOR2.
    function _donateDONOR2() internal {
        // Emit EthDonated.
        vm.expectEmit(true, true, false, false);
        emit Types.EthDonated(DONOR2, ETH_AMOUNT);

        // Prank as DONOR2.
        vm.prank(DONOR2);
        vault.donateETH{value: ETH_AMOUNT}();
    }

    /// @notice Donate as DONOR3.
    function _donateDONOR3() internal {
        // Emit EthDonated.
        vm.expectEmit(true, true, false, false);
        emit Types.EthDonated(DONOR3, ETH_AMOUNT);

        // Prank as DONOR3.
        vm.prank(DONOR3);
        vault.donateETH{value: ETH_AMOUNT}();
    }
}
