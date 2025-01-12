// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FirstToken} from "../src/FirstToken.sol";

contract DepployFirstToken is Script {
    uint256 public constant INITIAL_SUPPLY = 1_000_000 ether;

    function run() external returns(FirstToken) {
        vm.startBroadcast();
        FirstToken ft = new FirstToken(INITIAL_SUPPLY);
        vm.stopBroadcast();
        return ft;
    }
}
