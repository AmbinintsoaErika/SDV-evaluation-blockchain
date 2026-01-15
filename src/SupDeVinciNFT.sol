// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

contract SupDeVinciNFT is ERC721, Ownable {
   uint256 private sTokenCounter;

   constructor() ERC721("SupdevinciNFT", "SDVNFT")Ownable(msg.sender) {
      sTokenCounter = 0;
   }

   function mint(address addr) public onlyOwner() {
      _safeMint(addr, sTokenCounter);
      sTokenCounter++;
   }

   // Vérification si l'utilisateur possède déjà un NFT
   function hasVoted(address user) external view returns (bool) {
      return balanceOf(user) > 0;
   }
}