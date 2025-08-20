// SPDX-License-Identifier: MIT

/// @author Michealking (BuildsWithKing)
/// @title RejectETH
/// @notice Created on 19th of Aug, 2025. 

/// @notice This contract rejects ETH to simulate a "WithdrawFailed" transaction. 

pragma solidity ^0.8.30;

contract RejectETH {

    /// @notice Rejects ETH. 
     receive() external payable {
        revert ("ETH Rejected");
    }
}