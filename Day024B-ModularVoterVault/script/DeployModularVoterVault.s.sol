//SPDX-License-Identifier: MIT

/// @author Michealking(@BuildsWithKing).
/// @title DeployModularVoterVault
/// @notice Created on the 26th of Nov, 2025.

pragma solidity ^0.8.30;

/// @notice Imports Script from forge standard library and ModularVoterVault contract.
import {Script} from "forge-std/Script.sol";
import {ModularVoterVault} from "../src/ModularVoterVault.sol";

contract DeployModularVoterVault is Script {
    /// @notice Deploys the contract.
    function run() external {
        vm.startBroadcast();
        new ModularVoterVault(
            0x63c013128BF5C7628Fc8B87b68Aa90442AF312aa,
            0x922611b3EF6bE646198a071770e872D8e4cB4560,
            0x82B8002BF728dA892354D475d6B591AD01bD885f,
            50
        );
        vm.stopBroadcast();
    }
}
