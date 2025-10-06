// SPDX-License-Identifier: MIT

/// @title DonationVaultV2 contract.
/// @author Michealking (@BuildsWithKing).
/**
 * @notice Created on the 4th of Oct, 2025.
 *
 *     This contract handles external donate ETH, track personal balance, and the total vault balance.
 *  Only King can withdraw ETH and return total donors addresses.
 */
pragma solidity ^0.8.30;

/// @notice Imports VaultManager and KingPausable contract.
import {VaultManager} from "./VaultManager.sol";
import {KingPausable} from "buildswithking-security/access/extensions/KingPausable.sol";

contract DonationVaultV2 is KingPausable, VaultManager {
    // ------------------------------------------------------------------- Constructor --------------------------------------------
    /// @notice Accepts king's address at deployment.
    /// @dev Sets _kingAddress as deployer.
    /// @param _kingAddress The king's address.
    constructor(address _kingAddress) KingPausable(_kingAddress) {}

    // ----------------------------------------------------------- Donors external write functions. -----------------------------------

    /// @notice Donates callers ETH.
    function donateETH() external payable whenActive {
        // Call internal `donate` function.
        donate();
    }

    // ---------------------------------------------------------- Donors external read functions. --------------------------------------

    /// @notice Returns lifetime donors count.
    /// @return Total donors.
    function lifetimeDonorsCount() external view returns (uint256) {
        return lifetimeDonors;
    }

    /// @notice Returns total ETH ever donated.
    /// @return Total ETH.
    function totalETHDonated() external view returns (uint256) {
        return totalDonated;
    }

    /// @notice Returns address's donation status.
    /// @param _donorAddress The donor's address.
    /// @return bool (true || false).
    function viewDonorDonationStatus(address _donorAddress) external view returns (bool) {
        return hasDonated[_donorAddress];
    }

    /// @notice Returns caller's donation balance.
    /// @return Caller's donation balance.
    function myDonation() external view returns (uint256) {
        return donorBalance[msg.sender];
    }

    /// @notice Returns address's donation balance.
    /// @param _donorAddress The donor's address.
    /// @return Address's donation balance.
    function viewDonorBalance(address _donorAddress) external view returns (uint256) {
        return donorBalance[_donorAddress];
    }
    // -------------------------------------------------------------------- Donors public read function. ------------------------------------------

    /// @notice Returns vault's balance.
    /// @return Vault's balance.
    function vaultBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // ---------------------------------------------------------------------- King's external write function. ---------------------------------------
    /// @notice Withdraws ETH. Callable Only by the King.
    /// @param _receiverAddress The receiver's address.
    /// @param _ethAmount The amount of ETH to be withdrawn.
    function withdrawETH(address _receiverAddress, uint256 _ethAmount) external onlyKing {
        // Call internal `withdraw` function.
        withdraw(_receiverAddress, _ethAmount);
    }

    // ---------------------------------------------------------------------- King's external read function. ----------------------------------------
    /// @notice Returns donors addresses.
    /// @param _offset The starting index.
    /// @param _limit The maximum number of donors.
    /// @return _result donor's Addresses.
    function getDonorsAddresses(uint256 _offset, uint256 _limit)
        external
        view
        onlyKing
        returns (address[] memory _result)
    {
        // Return internal `getDonors` function.
        return getDonors(_offset, _limit);
    }
}
