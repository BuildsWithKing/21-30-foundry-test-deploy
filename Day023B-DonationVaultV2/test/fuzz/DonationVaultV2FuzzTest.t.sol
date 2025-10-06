// SPDX-License-Identifier: MIT

/// @title DonationVaultV2FuzzTest (DonationVaultV2 fuzz test contract).
/// @author Michealking (@BuildsWithKing).
/// @notice Created on the 4th of Oct, 2025.

pragma solidity ^0.8.30;

/// @notice Imports DonationVaultv2UnitTest and Utils contract.
import {DonationVaultV2UnitTest} from "../unit/DonationVaultV2UnitTest.t.sol";
import {Utils} from "../../src/Utils.sol";

contract DonationVaultV2FuzzTest is DonationVaultV2UnitTest {
    // -------------------------------------- Private helper function -----------------------------------
    /// @notice Assumes, prank and donate ETH as _donorAddress.
    /// @param _donorAddress The donor's address.
    function _assumePrankAndDonateETH(address _donorAddress) private {
        // Assume _donorAddress isn't any of the addresses below.
        vm.assume(
            _donorAddress != KING && _donorAddress != DONOR1 && _donorAddress != DONOR2 && _donorAddress != DONOR3
                && _donorAddress != DONOR50 && _donorAddress != address(0) && _donorAddress != address(vault)
        );

        // Fund 10 ETH to _donorAddress.
        vm.deal(_donorAddress, STARTING_BALANCE);

        // Prank and donate ETH as _donorAddress.
        vm.prank(_donorAddress);
        vault.donateETH{value: ETH_AMOUNT}();
    }
    // -------------------------------------- Fuzz test: Donors write function --------------------------------------

    /// @notice Fuzz test to ensure donors can sucessfully donate ETH.
    /// @param _donorAddress The donor's address.
    function testFuzz_DonateETH_Suceeds(address _donorAddress) public {
        // Call private helper function.
        _assumePrankAndDonateETH(_donorAddress);

        // Assert vault balance is equal to 1 ETH.
        assertEq(vault.vaultBalance(), ETH_AMOUNT);
    }

    // -------------------------------------- Fuzz test: Donors read functions ---------------------------------------
    /// @notice Fuzz test to ensure `lifetimeDonorsCount` returns.
    /// @param _donorAddress The donor's address.
    function testFuzz_LifeTimeDonorsCount_Returns(address _donorAddress) public {
        // Call private ` _assumePrankAndDonateETH` helper function.
        _assumePrankAndDonateETH(_donorAddress);

        // Assert lifetime donors count is equal to 1.
        assertEq(vault.lifetimeDonorsCount(), 1);
    }

    /// @notice Fuzz test to ensure `totalETHDonated` returns.
    /// @param _donorAddress The donor's address.
    function testFuzz_TotalETHDonated_Returns(address _donorAddress) public {
        // Call private `_assumePrankAndDonateETH` helper function.
        _assumePrankAndDonateETH(_donorAddress);

        // Assert total ETH donated is equal to 1 ETH.
        assertEq(vault.totalETHDonated(), ETH_AMOUNT);
    }

    /// @notice Fuzz test to ensure `viewDonorDonationStatus` returns.
    /// @param _donorAddress The donor's address.
    /// @param _randomDonorAddress The random donor's address.
    function testFuzz_ViewDonorDonationStatus(address _donorAddress, address _randomDonorAddress) public {
        // Call private `_assumePrankAndDonateETH` helper function.
        _assumePrankAndDonateETH(_donorAddress);

        // Call private `_assumePrankAndDonateETH` helper function.
        _assumePrankAndDonateETH(_randomDonorAddress);

        // Assert _donorAddress donation status is true.
        assertEq(vault.viewDonorDonationStatus(_randomDonorAddress), true);
    }

    /// @notice Fuzz test to ensure `myDonation` returns.
    /// @param _donorAddress The donor's address.
    function testFuzz_MyDonation_Returns(address _donorAddress) public {
        // Call private `_assumePrankAndDonateETH` helper function.
        _assumePrankAndDonateETH(_donorAddress);

        // Prank as _donorAddress.
        vm.prank(_donorAddress);
        uint256 myDonation = vault.myDonation();

        // Assert _donorAddress donation balance is equal to 1 ETH.
        assertEq(myDonation, ETH_AMOUNT);
    }

    /// @notice Fuzz test to ensure `viewDonorBalance` returns.
    /// @param _donorAddress The donor's address.
    /// @param _randomDonorAddress The random donor's address.
    function testFuzz_ViewDonorBalance_Returns(address _donorAddress, address _randomDonorAddress) public {
        // Call private `_assumePrankAndDonateETH` helper function.
        _assumePrankAndDonateETH(_donorAddress);

        // Call private `_assumePrankAndDonateETH` helper function.
        _assumePrankAndDonateETH(_randomDonorAddress);

        // Prank as _donorAddress.
        vm.prank(_donorAddress);
        uint256 donorBalance = vault.viewDonorBalance(_randomDonorAddress);

        // Assert donor's balance is equal to 1 ETH.
        assertEq(donorBalance, ETH_AMOUNT);
    }

    /// @notice Fuzz test to ensure vaultBalance returns.
    /// @param _donorAddress The donor's address.
    function testFuzz_VaultBalance_Returns(address _donorAddress) public {
        // Call private `_assumePrankAndDonateETH` helper function.
        _assumePrankAndDonateETH(_donorAddress);

        // Assert vault balance is equal to 1 ETH.
        assertEq(vault.vaultBalance(), ETH_AMOUNT);
    }

    // --------------------------------------------------- Fuzz test: King's write function ----------------------------------
    /// @notice Fuzz test to ensure king can successfully `withdrawETH`.
    /// @param _donorAddress The donor's address.
    /// @param _receiverAddress The receiver's address.
    function testFuzz_WithdrawETH_Succeeds(address _donorAddress, address _receiverAddress) public {
        // Call private `_assumePrankAndDonateETH` helper function.
        _assumePrankAndDonateETH(_donorAddress);

        // Assume _receieverAddress is not the zero, vault, or donor's address.
        vm.assume(
            _receiverAddress != address(0) && _receiverAddress != address(vault) && _receiverAddress != _donorAddress
        );

        // Prank and withdraw ETH as KING.
        vm.prank(KING);
        vault.withdrawETH(_receiverAddress, ETH_AMOUNT);

        // Assert _receiverAddress receives 1 ETH.
        assertEq(_receiverAddress.balance, ETH_AMOUNT);
    }

    /// @notice Fuzz test to ensure only the king can withdraw ETH.
    /// @param _donorAddress The donor's address.
    /// @param _userAddress The user's address.
    function testFuzz_WithdrawETH_Reverts(address _donorAddress, address _userAddress) public {
        // Call private `_assumePrankAndDonateETH` helper function.
        _assumePrankAndDonateETH(_donorAddress);

        // Assume _userAddress is not the zero or vault address.
        vm.assume(_userAddress != address(0) && _userAddress != address(vault));

        // Revert since _userAddress is not KING.
        vm.expectRevert();
        vm.prank(_userAddress);
        vault.withdrawETH(_userAddress, ETH_AMOUNT);

        // Assert vault balance is equal to 1 ETH.
        assertEq(vault.vaultBalance(), ETH_AMOUNT);
    }

    /// @notice Fuzz test to ensure king can't `withdrawETH` to the zero or contract address.
    /// @param _donorAddress The donor's address.
    /// @param _receiverAddress The receiver's address.
    function testFuzz_WithdrawETH_RevertsInvalidAddress(address _donorAddress, address _receiverAddress) public {
        // Call private `_assumePrankAndDonateETH` helper function.
        _assumePrankAndDonateETH(_donorAddress);

        // Revert if _receieverAddress is the zero or vault address.
        if (_receiverAddress == address(0) || _receiverAddress == address(vault)) {
            // Revert InvalidAddress, Since _receiverAddress is the zero or vault contract address.
            vm.expectRevert(Utils.InvalidAddress.selector);
            // Prank and withdraw ETH as KING.
            vm.prank(KING);
            vault.withdrawETH(_receiverAddress, ETH_AMOUNT);
        }

        // Assert vault balance is equal to 1 ETH.
        assertEq(vault.vaultBalance(), ETH_AMOUNT);

        // Assert _receiverAddress is equal zero.
        assertEq(_receiverAddress.balance, 0);
    }

    // -------------------------------- Fuzz test: King's read function --------------------------------------------
    /// @notice Fuzz test to ensure king can `getDonorsAddresses`.
    /// @param _donorAddress The donor's address.
    function testFuzz_GetDonorsAddresses_Returns(address _donorAddress) public {
        // Call private `_assumePrankAndDonateETH` helper function.
        _assumePrankAndDonateETH(_donorAddress);

        // Prank and getDonorsAddresses as King.
        vm.prank(KING);
        address[] memory donorsAddresses = vault.getDonorsAddresses(0, 1);

        // Assert _donorAddress is at index zero.
        assertEq(donorsAddresses[0], _donorAddress);
    }

    /// @notice Fuzz test to ensure only King can `getDonorsAddresses`.
    /// @param _donorAddress The donor's address.
    function testFuzz_GetDonorsAddresses_Reverts(address _donorAddress) public {
        // Call private `_assumePrankAndDonateETH` helper function.
        _assumePrankAndDonateETH(_donorAddress);

        // Revert, Since _donorAddress isn't King.
        vm.expectRevert();
        vm.prank(_donorAddress);
        vault.getDonorsAddresses(0, 1);
    }

    /// @notice Fuzz test to ensure `getDonorsAddresses` reverts HighOffset.
    /// @param _donorAddress The donor's address.
    function testFuzz_GetDonorsAddresses_RevertsHighOffset(address _donorAddress) public {
        // Call private `_assumePrankAndDonateETH` helper function.
        _assumePrankAndDonateETH(_donorAddress);

        // Prank and getDonorsAddresses as King.
        vm.expectRevert(Utils.HighOffset.selector);
        vm.prank(KING);
        vault.getDonorsAddresses(100, 20);
    }

    /// @notice Fuzz test to ensure `getDonorsAddresses` reverts HighLimit.
    /// @param _donorAddress The donor's address.
    function testFuzz_GetDonorsAddresses_RevertsHighLimit(address _donorAddress) public {
        // Call private `_assumePrankAndDonateETH` helper function.
        _assumePrankAndDonateETH(_donorAddress);

        // Prank and getDonorsAddresses as King.
        vm.expectRevert(Utils.HighLimit.selector);
        vm.prank(KING);
        vault.getDonorsAddresses(0, 2000);
    }
}
