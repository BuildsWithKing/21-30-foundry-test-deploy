// SPDX-License-Identifier: MIT

/// @title BankBaseFuzzTest (BankBase fuzz test contract for SimpleBankX).
/// @author Michealking (@BuildsWithKing).
/// @notice Created on the 1st of Oct, 2025.

pragma solidity ^0.8.30;

/// @notice Imports BaseTest, Types and Utils contract.
import {BaseTest} from "../BaseTest.t.sol";
import {Types} from "../../src/Types.sol";
import {Utils} from "../../src/Utils.sol";

contract BankBaseFuzzTest is BaseTest {
    // ---------------------------------------------------- Private helper function. ---------------------------------------
    /// @notice Assumes, prank and registers _userAddress.
    function _assumePrankAndRegister(address _userAddress) private {
        // Assume _userAddress is not USER1, USER2, USER3, KING, a contract address, zero or this contract.
        vm.assume(
            _userAddress != USER1 && _userAddress != USER2 && _userAddress != USER3 && _userAddress != KING
                && _userAddress.code.length == 0 && _userAddress != address(0) && _userAddress != address(this)
        );

        // Revert WithdrawalFailed, if _userAddress is any contract, address zero, or this contract.
        if (_userAddress.code.length > 0 || _userAddress == address(0) || _userAddress == address(this)) {
            vm.expectRevert(Utils.WithdrawalFailed.selector);
        }

        // Prank and register as _userAddress.
        vm.prank(_userAddress);
        simpleBankX.registerMyAddress();
    }

    // ------------------------------------------------ Fuzz test: Users write functions ---------------------------------
    /// @notice Fuzz test: RegisterMyAddress succeeds.
    /// @param _userAddress The user's address.
    function testFuzz_RegisterMyAddress_Succeeds(address _userAddress) public {
        // Call private _assumePrankAndRegister function.
        _assumePrankAndRegister(_userAddress);

        // Assign status.
        Types.RegistrationStatus status = simpleBankX.checkUserRegistrationStatus(_userAddress);

        // Assert _userAddress registration status is registered.
        assertEq(uint8(status), 1);
    }

    /// @notice Fuzz test: RegisterMyAddress reverts AlreadyRegistered.
    /// @param _userAddress The user's address.
    function testFuzz_RegisterMyAddress_RevertsAlreadyRegistered(address _userAddress) public {
        // Call private _assumePrankAndRegister function.
        _assumePrankAndRegister(_userAddress);

        // Revert AlreadyRegistered, since users can register just once.
        vm.expectRevert(Utils.AlreadyRegistered.selector);
        vm.prank(_userAddress);
        simpleBankX.registerMyAddress();

        // Stop prank.
        vm.stopPrank();
    }

    /// @notice Fuzz test: UnregisterMyAddress Succeeds.
    /// @param _userAddress The user's address.
    function testFuzz_UnregisterMyAddress_Succeeds(address _userAddress) public {
        // Call private _assumePrankAndRegister function.
        _assumePrankAndRegister(_userAddress);

        // Prank and Unregister as _userAddress.
        vm.prank(_userAddress);
        simpleBankX.unregisterMyAddress();

        // Assign status.
        Types.RegistrationStatus status = simpleBankX.checkUserRegistrationStatus(_userAddress);

        // Assert _userAddress registration status is not registered.
        assertEq(uint8(status), 0);
    }

    /// @notice Fuzz test: UnregisterMyAddress reverts NotRegistered.
    /// @param _userAddress The user's address.
    function testFuzz_UnregisterMyAddress_RevertsNotRegistered(address _userAddress) public {
        // Assume _userAddress is not USER1, USER2, USER3, KING, a contract address, zero or this contract.
        vm.assume(
            _userAddress != USER1 && _userAddress != USER2 && _userAddress != USER3 && _userAddress != KING
                && _userAddress.code.length == 0 && _userAddress != address(0) && _userAddress != address(this)
        );

        // Revert NotRegistered, since only registered users can unregister.
        vm.expectRevert(Utils.NotRegistered.selector);
        vm.prank(_userAddress);
        simpleBankX.unregisterMyAddress();
    }

    /// @notice Fuzz test: UnregisterMyAddress refunds users.
    /// @param _userAddress The user's address.
    function testFuzz_UnregisterMyAddress_RefundsUsers(address _userAddress) public {
        // Call private _assumePrankAndRegister function.
        _assumePrankAndRegister(_userAddress);

        // Prank as _userAddress.
        vm.startPrank(_userAddress);

        // Fund 10 ETH to _userAddress.
        vm.deal(_userAddress, STARTING_BALANCE);

        // Deposit ETH as _userAddress.
        simpleBankX.depositMyETH{value: ETH_AMOUNT}();

        // Assign balanceBefore.
        uint256 balanceBefore = simpleBankX.myBalance();

        // Unregister as _userAddress.
        simpleBankX.unregisterMyAddress();

        // Assign balanceAfter.
        uint256 balanceAfter = simpleBankX.myBalance();

        // Stop prank.
        vm.stopPrank();

        // Assert _userAddress balance after is less than balance before withdrawal.
        assertLt(balanceAfter, balanceBefore);
        assertEq(balanceAfter, 0);
    }

    /// @notice Fuzz test: UnregisterMyAddress reverts WithdrawalFailed.
    /// @param _userAddress The user's address.
    function testFuzz_UnregisterMyAddress_RevertsWithdrawalFailed(address _userAddress) public {
        // Assume _userAddress is a contract address.
        vm.assume(_userAddress.code.length > 0);

        // Fund 10 ETH to _userAddress.
        vm.deal(_userAddress, STARTING_BALANCE);

        // Prank, register and Deposit ETH as _userAddress.
        vm.startPrank(_userAddress);
        simpleBankX.registerMyAddress();
        simpleBankX.depositMyETH{value: STARTING_BALANCE}();

        // Revert WithdrawalFailed, due to gas heavy fallback.
        vm.expectRevert(Utils.WithdrawalFailed.selector);
        simpleBankX.unregisterMyAddress();

        // Stop prank.
        vm.stopPrank();

        // Assert balance of _userAddress is equal to 10 ETH.
        assertEq(simpleBankX.checkUserBalance(_userAddress), STARTING_BALANCE);
    }

    /// @notice Fuzz test: DepositMyETH succeeds.
    /// @param _userAddress The user's address.
    function testFuzz_DepositMyETH_Succeeds(address _userAddress) public {
        // Call private _assumePrankAndRegister function.
        _assumePrankAndRegister(_userAddress);

        // Fund 10 ETH to _userAddress.
        vm.deal(_userAddress, STARTING_BALANCE);

        // Deposit ETH as _userAddress.
        vm.prank(_userAddress);
        simpleBankX.depositMyETH{value: ETH_AMOUNT}();

        // Assert _userAddress wallet balance reduced.
        assertEq(_userAddress.balance, STARTING_BALANCE - ETH_AMOUNT);

        // Assert balance of _userAddress is equal to 1 ETH.
        assertEq(simpleBankX.checkUserBalance(_userAddress), ETH_AMOUNT);
    }

    /// @notice Fuzz test: WithdrawMyETH succeeds.
    /// @param _userAddress The user's address.
    function testFuzz_WithdrawMyETH_Succeeds(address _userAddress) public {
        // Fund 10 ETH to _userAddress.
        vm.deal(_userAddress, STARTING_BALANCE);

        // Call private _assumePrankAndRegister function.
        _assumePrankAndRegister(_userAddress);

        // Deposit ETH as _userAddress.
        vm.startPrank(_userAddress);
        simpleBankX.depositMyETH{value: STARTING_BALANCE}();

        // Withdraw ETH as _userAddress.
        simpleBankX.withdrawMyETH(ETH_AMOUNT);

        // Stop prank.
        vm.stopPrank();

        // Assert balance of _userAddress is less than 10 ETH.
        assertLt(simpleBankX.checkUserBalance(_userAddress), STARTING_BALANCE);

        // Assert _userAddress wallet balance increased.
        assertEq(_userAddress.balance, ETH_AMOUNT);
    }

    /// @notice Fuzz test: TransferETH succeeds.
    /// @param _senderAddress The sender's address.
    /// @param _receiverAddress The receiver's address.
    function testFuzz_TransferETH_Succeeds(address _senderAddress, address _receiverAddress) public {
        // Assume _senderAddress is not equal to _receiverAddress.
        vm.assume(_senderAddress != _receiverAddress);

        // Call private _assumePrankAndRegister function.
        _assumePrankAndRegister(_senderAddress);

        // Call private _assumePrankAndRegister function.
        _assumePrankAndRegister(_receiverAddress);

        // Fund 10 ETH to _senderAddress.
        vm.deal(_senderAddress, STARTING_BALANCE);

        // Prank, deposit and transfer ETH as _senderAddress.
        vm.startPrank(_senderAddress);
        simpleBankX.depositMyETH{value: STARTING_BALANCE}();
        simpleBankX.transferETH(_receiverAddress, ETH_AMOUNT);

        // Stop prank.
        vm.stopPrank();

        // Assert balance of _receiverAddress is equal to 1 ETH.
        assertEq(simpleBankX.checkUserBalance(_receiverAddress), ETH_AMOUNT);
    }

    // --------------------------------------------------------------- Fuzz test: King's read function -----------------------------------
    /// @notice Fuzz test: getRegisteredUsers reverts HighOffset.
    /// @param _userAddress The user's address.
    /// @param _offset The starting index.
    /// @param _limit The maximum numbers of users.
    function testFuzz_GetRegisteredUsers_RevertsHighOffset(address _userAddress, uint256 _offset, uint256 _limit)
        public
    {
        // Call private _assumePrankAndRegister function.
        _assumePrankAndRegister(_userAddress);

        // Bound _offset minimum as 10, maximum as 500.
        _offset = uint256(bound(_offset, 10, 500));

        // Bound _limit minimum as 1, maximum as 1000.
        _limit = uint256(bound(_limit, 1, 1000));

        // Revert HighOffset, since _offset is greater users index.
        vm.expectRevert(Utils.HighOffset.selector);
        vm.prank(KING);
        simpleBankX.getRegisteredUsers(_offset, _limit);
    }

    /// @notice Fuzz test: getRegisteredUsers reverts HighLimit.
    /// @param _userAddress The user's address.
    /// @param _offset The starting index.
    /// @param _limit The maximum numbers of users.
    function testFuzz_GetRegisteredUsers_RevertsHighLimit(address _userAddress, uint256 _offset, uint256 _limit)
        public
    {
        // Call private _assumePrankAndRegister function.
        _assumePrankAndRegister(_userAddress);

        // Bound _offset minimum as 0, maximum as 0.
        _offset = uint256(bound(_offset, 0, 0));

        // Bound _limit minimum as 1001, maximum as 5000.
        _limit = uint256(bound(_limit, 1001, 5000));

        // Revert HighLimit, since _limit is greater than contract's maxiumum limit (1000).
        vm.expectRevert(Utils.HighLimit.selector);
        vm.prank(KING);
        simpleBankX.getRegisteredUsers(_offset, _limit);
    }

    /// @notice Fuzz test: getRegisteredUsers end bound.
    /// @param _userAddress The user's address.
    /// @param _offset The starting index.
    /// @param _limit The maximum numbers of users.
    function testFuzz_GetRegisteredUsers_EndBound(address _userAddress, uint256 _offset, uint256 _limit) public {
        // Call private _assumePrankAndRegister function.
        _assumePrankAndRegister(_userAddress);

        // Bound _offset minimum as 0, maximum as 0.
        _offset = uint256(bound(_offset, 0, 0));

        // Bound _limit minimum as 1, maximum as 1000.
        _limit = uint256(bound(_limit, 1, 1000));

        // Prank and get registered users as KING.
        vm.prank(KING);
        address[] memory userAddresses = simpleBankX.getRegisteredUsers(_offset, _limit);

        // Assert _userAddress is at index zero in the array.
        assertEq(userAddresses[0], _userAddress);
    }
}
