//SPDX-License-Identifier: MIT

/// @author Michealking(@BuildsWithKing).
/// @title DeployVoterVaultToken.
/// @notice Created on the 26th of Nov, 2025.

pragma solidity ^0.8.30;

/// @notice Imports Script from forge standard library and VoterVaultToken contract.
import {Script} from "forge-std/Script.sol";
import {VoterVaultToken} from "../src/VoterVaultToken.sol";

contract DeployVoterVaultToken is Script {
    /// @notice Deploys the contract.
    function run() external {
        vm.startBroadcast();
        new VoterVaultToken(0x63c013128BF5C7628Fc8B87b68Aa90442AF312aa, 100000000);
        vm.stopBroadcast();
    }
}
