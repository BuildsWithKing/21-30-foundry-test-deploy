//SPDX-License-Identifier: MIT

/// @author Michealking(@BuildsWithKing).
/// @title DeployDonationVaultV2
/// @notice Created on the 6th of Oct, 2025.

pragma solidity ^0.8.30;

/// @notice Imports Script from forge standard library and DonationVaultV2.
import {Script} from "forge-std/Script.sol";
import {DonationVaultV2} from "../src/DonationVaultV2.sol";

contract DeployDonationVaultV2 is Script {
    function run() external {
        vm.startBroadcast();
        new DonationVaultV2(0x63c013128BF5C7628Fc8B87b68Aa90442AF312aa);
        vm.stopBroadcast();
    }
}
