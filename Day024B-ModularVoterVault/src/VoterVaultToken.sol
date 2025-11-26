// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title VoterVaultToken (Token contract for ModularVoterVault).
/// @author Michealking (@BuildsWithKing).
/**
 * @notice Created on the 21st of Nov, 2025.
 *
 *  @dev  ERC20 token contract. Deploy first and credit voters.
 */

/// @notice Imports KingERC20 contract.
import {KingERC20} from "buildswithking-security/tokens/ERC20/KingERC20.sol";

contract VoterVaultToken is KingERC20 {
    // ---------------------------------------------------- Constructor -----------------------------------------
    /// @notice Assigns the king, and token's information at deployment.
    /// @dev Sets the king, token's name, symbol, initial supply at deployment. Mints the initial supply to the king upon deployment.
    /// @param king_ The king's address.
    /// @param initialSupply_ The token's initial supply.
    constructor(address king_, uint256 initialSupply_) KingERC20(king_, "VoterVaultToken", "VVT", initialSupply_) {}

    // ----------------------------------------- External Write Function ---------------------------------------
    /// @notice Burns token. i.e Removes certain amount of the token from existence.
    /// @param amount The amount of tokens to be burned.
    function burn(uint256 amount) external virtual {
        // Call the internal `burn` function.
        _burn(msg.sender, amount);
    }
}
