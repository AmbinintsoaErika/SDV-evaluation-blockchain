// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {SupDeVinciNFT} from "../src/SupDeVinciNFT.sol";
import {SimpleVotingSystem} from "../src/SimpleVotingSystem.sol";

contract DeploySupDeVinciNFT is Script {

    function run() external returns (SupDeVinciNFT) {
        vm.startBroadcast();
        
        SupDeVinciNFT sdvNft = new SupDeVinciNFT();
        SimpleVotingSystem svs = new SimpleVotingSystem();
        sdvNft.transferOwnership(address(svs));

        vm.stopBroadcast();

        return sdvNft;
    }
}