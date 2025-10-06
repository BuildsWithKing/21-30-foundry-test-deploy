// SPDX-License-Identifier: MIT

/// @title RejectETHTest (RejectETH test contract for DonationVaultV2).
/// @author Michealking (@BuildsWithKing).
/// @notice Created on the 4th of Oct, 2025.

pragma solidity ^0.8.30;

/// @notice Thrown when contract rejects ETH deposit.
/// @dev Thrown when a user or contract transfers ETH.
error EthRejected();

contract RejectETHTest {
    /// @notice Rejects ETH deposit.
    receive() external payable {
        revert EthRejected();
    }
}
