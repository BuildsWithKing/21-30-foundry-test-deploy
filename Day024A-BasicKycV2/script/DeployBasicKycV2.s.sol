//SPDX-License-Identifier: MIT

/// @author Michealking(@BuildsWithKing).
/// @title DeployBasicKycV2
/// @notice Created on the 30th of Oct, 2025.

pragma solidity ^0.8.30;

/// @notice Imports Script from forge standard library and BasicKycV2 contract.
import {Script} from "forge-std/Script.sol";
import {BasicKycV2} from "../src/BasicKycV2.sol";

contract DeployBasicKycV2 is Script {
    function run() external {
        vm.startBroadcast();
        new BasicKycV2(0x63c013128BF5C7628Fc8B87b68Aa90442AF312aa, 0x922611b3EF6bE646198a071770e872D8e4cB4560);
        vm.stopBroadcast();
    }
}
