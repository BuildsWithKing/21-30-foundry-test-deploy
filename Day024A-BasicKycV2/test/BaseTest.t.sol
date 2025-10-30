// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title BaseTest (BaseTest contract for BasicKycV2).
/// @author Michealking (@BuildsWithKing).
/// @notice Created on the 28th of Oct, 2025.

/// @notice Imports Test from forge standard library, Types, Utils and BasicKycV2 contract.
import {Test} from "forge-std/Test.sol";
import {Types} from "../src/Types.sol";
import {Utils} from "../src/Utils.sol";
import {BasicKycV2} from "../src/BasicKycV2.sol";

contract BaseTest is Test {
    // -------------------------------------------------- State Variables ----------------------------------
    /// @notice Assigns basicKycV2.
    BasicKycV2 public basicKycV2;

    /// @notice Assigns KING, ZERO, ADMIN, USER1, USER2 and USER3.
    address internal constant KING = address(0x10);
    address internal constant ZERO = address(0);
    address internal constant ADMIN = address(0x5);
    address internal constant USER1 = address(0x1);
    address internal constant USER2 = address(0x2);
    address internal constant USER3 = address(0x3);

    /// @notice Assigns USER1_HASH, USER2_HASH, USER3_HASH, STARTING_BALANCE & ETH_AMOUNT
    bytes32 internal constant USER1_HASH = 0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890;
    bytes32 internal constant USER2_HASH = 0x1220e0b5c7a9f8d6e4c3b2a1f0e9d8c7b6a5d4c3b2a1f0e9d8c7b6a5d4c3b2a1;
    bytes32 internal constant USER3_HASH = 0x1220e0b5c7a9f8d6e4c3b2a1f0e9d8c7b6a5d4c3b2a1f0e9d8c7b6a5d4c3b5a1;
    uint256 internal constant STARTING_BALANCE = 10 ether;
    uint256 internal constant ETH_AMOUNT = 1 ether;

    // --------------------------------------------------- Setup Function -----------------------------------
    /// @notice This function runs before every other function.
    function setUp() public {
        // Create new instance of BasicKycV2.
        basicKycV2 = new BasicKycV2(KING, ADMIN);

        // Label KING, ZERO, ADMIN USER1, USER2 & USER3.
        vm.label(KING, "KING");
        vm.label(ZERO, "ZERO");
        vm.label(ADMIN, "ADMIN");
        vm.label(USER1, "USER1");
        vm.label(USER2, "USER2");
        vm.label(USER3, "USER3");

        // Fund 10 ETH to USER3.
        vm.deal(USER3, STARTING_BALANCE);
    }

    // ---------------------------------------------------- Constructor -----------------------------------------

    /// @notice Test to ensure constructor sets king and admin at deployment.
    function testConstructorSetsKingAndAdmin_AtDeployment() public view {
        // Assert current king is equal to KING.
        assertEq(basicKycV2.currentKing(), KING);

        // Assert admin is equal to ADMIN.
        assertEq(basicKycV2.s_admin(), ADMIN);
    }

    /// @notice Test to ensure the zero address can't be set as the admin at deployment.
    function testConstructor_RevertsInvalidAddress() public {
        // Revert since the address is the zero address.
        vm.expectRevert(abi.encodeWithSelector(Utils.InvalidAddress.selector, ZERO));
        basicKycV2 = new BasicKycV2(KING, ZERO);
    }

    // ------------------------------------------------------ Internal Helper Functions ---------------------------
    /// @notice Registers user1.
    function _registerUser1() internal {
        // Emit the event "UserRegistered", and Prank as USER1.
        vm.expectEmit(true, true, true, false);
        emit Types.UserRegistered(1, USER1, USER1_HASH);
        vm.prank(USER1);
        basicKycV2.registerMyData(USER1_HASH);
    }

    /// @notice Registers user2.
    function _registerUser2() internal {
        // Emit the event "UserRegistered", and Prank as USER2.
        vm.expectEmit(true, true, true, false);
        emit Types.UserRegistered(2, USER2, USER2_HASH);
        vm.prank(USER2);
        basicKycV2.registerMyData(USER2_HASH);
    }

    /// @notice Registers user3.
    function _registerUser3() internal {
        // Emit the event "UserRegistered", and Prank as USER3.
        vm.expectEmit(true, true, true, false);
        emit Types.UserRegistered(3, USER3, USER3_HASH);
        vm.prank(USER3);
        basicKycV2.registerMyData(USER3_HASH);
    }

    /// @notice Registers user1, user2 and user3.
    function _registerMultipleUsers() internal {
        // Call the internal `_registerUser1` function.
        _registerUser1();

        // Call the internal `_registerUser2` function.
        _registerUser2();

        // Call the internal `_registerUser3` function.
        _registerUser3();
    }

    /// @notice Verify user1. Callable by the king or the admin.
    function _verifyUser1() internal {
        // Emit the event "UserVerified", and Prank as the KING.
        vm.expectEmit(true, true, false, false);
        emit Types.UserVerified(basicKycV2.userId(USER1), USER1, KING);
        vm.prank(KING);
        basicKycV2.verifyUser(USER1);
    }
}
