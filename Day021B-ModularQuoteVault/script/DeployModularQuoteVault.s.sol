//SPDX-License-Identifier: MIT

/// @author Michealking(@BuildsWithKing).
/// @title DeployModularQuoteVault.
/// @notice Created on 3rd of Sept, 2025.

pragma solidity ^0.8.30;

/// @notice Imports Script from forge standard library and ModularQuoteVault .
import {Script} from "forge-std/Script.sol";
import {ModularQuoteVault} from "../src/ModularQuoteVault.sol";

contract DeployModularQuoteVault is Script {
    function run() external {
        vm.startBroadcast();
        new ModularQuoteVault();
        vm.stopBroadcast();
    }
}
