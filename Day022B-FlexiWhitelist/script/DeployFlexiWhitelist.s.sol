//SPDX-License-Identifier: MIT

/// @author Michealking(@BuildsWithKing).
/// @title DeployFlexiWhitelist
/// @notice Created on the 21st of Sept, 2025.

pragma solidity ^0.8.30;

/// @notice Imports Script from forge standard library and FlexiWhitelist.
import {Script} from "forge-std/Script.sol";
import {FlexiWhitelist} from "../src/FlexiWhitelist.sol";

contract DeployFlexiWhitelist is Script {
    function run() external {
        vm.startBroadcast();
        new FlexiWhitelist(0x63c013128BF5C7628Fc8B87b68Aa90442AF312aa);
        vm.stopBroadcast();
    }
}