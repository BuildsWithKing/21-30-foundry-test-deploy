// SPDX-License-Identifier: MIT

/// @title BaseTest (BaseTest contract for SimpleBankX).
/// @author Michealking (@BuildsWithKing).
/// @notice Created on the 30th of Sept, 2025.

pragma solidity ^0.8.30;

/// @notice Imports Test from forge standard library, Types, Utils, BankBase, SimpleBankX and RejectETHTest contract.
import {Test} from "forge-std/Test.sol";
import {Types} from "../src/Types.sol";
import {Utils} from "../src/Utils.sol";
import {BankBase} from "../src/BankBase.sol";
import {SimpleBankX} from "../src/SimpleBankX.sol";
import {RejectETHTest} from "./RejectETHTest.t.sol";

contract BaseTest is Test {
    // -------------------------------------------------- State variables ---------------------------------
    /// @notice Assigns simpleBankX & rejector.
    SimpleBankX simpleBankX;
    RejectETHTest rejector;

    /// @notice Assigns KING, USER1, USER2 and USER3.
    address internal constant KING = address(0x10);
    address internal constant USER1 = address(0x1);
    address internal constant USER2 = address(0x2);
    address internal constant USER3 = address(0x3);

    /// @notice Assigns STARTING_BALANCE and ETH_AMOUNT
    uint256 internal constant STARTING_BALANCE = 10 ether;
    uint256 internal constant ETH_AMOUNT = 1 ether;

    // --------------------------------------------------- Setup function -----------------------------------
    /// @notice This function runs before every other function.
    function setUp() public virtual {
        // Create new instance of SimpleBankX and RejectETHTest contract.
        simpleBankX = new SimpleBankX(KING);
        rejector = new RejectETHTest();

        // Label KING, USER1, USER2 and USER3.
        vm.label(KING, "KING");
        vm.label(USER1, "USER1");
        vm.label(USER2, "USER2");
        vm.label(USER3, "USER3");

        // Fund 10 ETH to USER1, USER2 and rejector.
        vm.deal(USER1, STARTING_BALANCE);
        vm.deal(USER2, STARTING_BALANCE);
        vm.deal(address(rejector), STARTING_BALANCE);
    }

    // ---------------------------------------------------- Constructor -----------------------------------------

    /// @notice Test to ensure constructor sets king at deployment.
    function testConstructorSetsKing_AtDeployment() public view {
        // Assert current king is same as KING.
        assertEq(simpleBankX.currentKing(), KING);
    }

    // ------------------------------------------------------ Internal helper functions ---------------------------
    /// @notice Registers USER1.
    function _registerUser1() internal {
        // Prank, emit Registered event and register as USER1.
        vm.prank(USER1);
        vm.expectEmit(true, true, false, false);
        emit Types.Registered(1, USER1);
        simpleBankX.registerMyAddress();
    }

    /// @notice Registers USER2.
    function _registerUser2() internal {
        // Prank, emit Registered event and register as USER2.
        vm.prank(USER2);
        vm.expectEmit(true, true, false, false);
        emit Types.Registered(2, USER2);
        simpleBankX.registerMyAddress();
    }

    /// @notice Registers USER3.
    function _registerUser3() internal {
        // Prank, emit Registered event and register as USER3.
        vm.prank(USER3);
        vm.expectEmit(true, true, false, false);
        emit Types.Registered(3, USER3);
        simpleBankX.registerMyAddress();
    }
}
