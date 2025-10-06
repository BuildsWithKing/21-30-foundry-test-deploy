// SPDX-License-Identifier: MIT

/// @title VaultManager (VaultManager contract for DonationVaultV2).
/// @author Michealking (@BuildsWithKing).
/**
 * @notice Created on the 4th of Oct, 2025.
 *
 *     This contract handles internal donate, and withdraw ETH logic.
 *  Only King can withdraw and get total donors addresses.
 *
 */
pragma solidity ^0.8.30;

/// @notice Imports Utils contract.
import {Utils} from "./Utils.sol";

abstract contract VaultManager is Utils {
    // -------------------------------------------------- Donor's write function ----------------------------------------------
    /// @notice Donates caller's ETH. Emits {EthDonated} event on success.
    function donate() internal {
        // Call internal `_donateETH` helper function.
        _donateETH();
    }

    // --------------------------------------------------- King's write function ----------------------------------------------
    /// @notice Withdraws ETH. Callable Only by the King.
    /// @param _receiverAddress The receiver's address.
    /// @param _ethAmount The amount of ETH to be withdrawn.
    function withdraw(address _receiverAddress, uint256 _ethAmount) internal nonReentrant {
        // Assign contractBalance.
        uint256 contractBalance = address(this).balance;

        // Revert if _ethAmount is greater than contract balance.
        if (_ethAmount > contractBalance) {
            revert InsufficientBalance();
        }

        // Revert if _receiverAddress is the zero or this contract address.
        if (_receiverAddress == address(0) || _receiverAddress == address(this)) {
            revert InvalidAddress();
        }

        // Fund _receiverAddress amount withdrawn, Revert if withdrawal fails.
        (bool success,) = payable(_receiverAddress).call{value: _ethAmount}("");
        if (!success) {
            revert WithdrawalFailed();
        }

        // Emit event EthWithdrawn.
        emit EthWithdrawn(msg.sender, _receiverAddress, _ethAmount);
    }

    // ---------------------------------------------------- King's read function ------------------------------------------
    /// @notice Returns donors addresses.
    /// @param _offset The starting index.
    /// @param _limit The maximum number of donors.
    /// @return _result donor's Addresses.
    function getDonors(uint256 _offset, uint256 _limit) internal view returns (address[] memory _result) {
        // Assign _totalDonors.
        uint256 _totalDonors = donorAddresses.length;

        // Return empty array if total donor is equal zero.
        if (_totalDonors == 0) {
            return new address[](0);
        }

        // Revert if _offset is greater than or equal to totalDonors.
        if (_offset >= _totalDonors) {
            revert HighOffset();
        }

        // Revert if _limit is greater than 1000.
        if (_limit > 1000) {
            revert HighLimit();
        }

        // Assign _end.
        uint256 _end = _offset + _limit;

        // Reset _end to total Donors.
        if (_end > _totalDonors) {
            _end = _totalDonors;
        }

        // Compute numbers of addresses to be returned.
        uint256 _length = _end - _offset;

        // Use a new array to store the returned donor addresses.
        _result = new address[](_length);

        // Assign _donor.
        address[] storage _donor = donorAddresses;

        // Loop through the range.
        for (uint256 i; i < _length; i++) {
            // Copy address from donorAddresses to new array (_result).
            _result[i] = _donor[_offset + i];
        }
    }
}
