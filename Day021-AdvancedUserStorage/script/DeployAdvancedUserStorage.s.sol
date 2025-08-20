//SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

/// @notice Imports Script and AdvancedUserStorage. 
import {Script} from "forge-std/Script.sol";
import {AdvancedUserStorage} from "../src/AdvancedUserStorage.sol";

contract DeployUserStorage is Script {
    function run() external {
        vm.startBroadcast();
        new AdvancedUserStorage();
        vm.stopBroadcast();
    }
}