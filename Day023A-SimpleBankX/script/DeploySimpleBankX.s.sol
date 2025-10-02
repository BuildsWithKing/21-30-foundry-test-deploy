//SPDX-License-Identifier: MIT

/// @author Michealking(@BuildsWithKing).
/// @title DeploySimpleBankX
/// @notice Created on the 3rd of Oct, 2025.

pragma solidity ^0.8.30;

/// @notice Imports Script from forge standard library and SimpleBankX.
import {Script} from "forge-std/Script.sol";
import {SimpleBankX} from "../src/SimpleBankX.sol";

contract DeploySimpleBankX is Script {
    function run() external {
        vm.startBroadcast();
        new SimpleBankX(0x63c013128BF5C7628Fc8B87b68Aa90442AF312aa);
        vm.stopBroadcast();
    }
}
