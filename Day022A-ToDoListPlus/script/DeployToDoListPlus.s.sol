//SPDX-License-Identifier: MIT

/// @author Michealking(@BuildsWithKing).
/// @title DeployToDoListPlus
/// @notice Created on the 12th of Sept, 2025.

pragma solidity ^0.8.30;

/// @notice Imports Script from forge standard library and DeployToDoListPlus.
import {Script} from "forge-std/Script.sol";
import {ToDoListPlus} from "../src/ToDoListPlus.sol";

contract DeployToDoListPlus is Script {
    function run() external {
        vm.startBroadcast();
        new ToDoListPlus();
        vm.stopBroadcast();
    }
}
