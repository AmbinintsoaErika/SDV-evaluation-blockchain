// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {AccessControl} from "openzeppelin-contracts/contracts/access/AccessControl.sol";
import {SupDeVinciNFT} from "../src/SupDeVinciNFT.sol";

contract SimpleVotingSystem  is AccessControl {

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant FOUNDER_ROLE = keccak256("FOUNDER_ROLE");
    bytes32 public constant WITHDRAWER_ROLE = keccak256("WITHDRAWER_ROLE");

    struct Candidate {
        uint id;
        string name;
        uint voteCount;
        uint funds;
    }
    
    enum Status {
        REGISTER_CANDIDATES,
        FOUND_CANDIDATES,
        VOTE,
        COMPLETED
    }

    Status public votingStatus;
    uint public triggeredVoteTime;
    SupDeVinciNFT public sdvNFT;

    mapping(uint => Candidate) public candidates;
    mapping(address => bool) public voters;
    uint[] private candidateIds;

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "Only admins can perform this action.");
        _;
    }

    modifier onlyFounder() {
        require(hasRole(FOUNDER_ROLE, msg.sender), "Only founders can perform this action.");
        _;
    }

    modifier onlyWithdrawer() {
        require(hasRole(WITHDRAWER_ROLE, msg.sender), "Only withdrawers can perform this action.");
        _;
    }

    modifier onlyAllowedStatus(Status _status) {
        require(votingStatus == _status, "This action is not allowed in the current voting status.");
        _;
    }

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        votingStatus = Status.REGISTER_CANDIDATES;
    }

    // Enregistrement des candidats - uniquement les administrateurs
    function addCandidate(string memory _name) public onlyAdmin onlyAllowedStatus(Status.REGISTER_CANDIDATES) {
        require(bytes(_name).length > 0, "Candidate name cannot be empty");

        uint candidateId = candidateIds.length + 1;
        candidates[candidateId] = Candidate({id: candidateId, name: _name, voteCount: 0, funds: 0});
        candidateIds.push(candidateId);
    }

    // Financement d'un candidat par son ID
    function fundCandidate(uint _candidateId) public payable onlyFounder() {
        require(_candidateId > 0 && _candidateId <= candidateIds.length, "Invalid candidate ID");
        require(msg.value > 0, "Invalid fund amount");

        candidates[_candidateId].funds += msg.value;
    }

    function vote(uint _candidateId) external onlyAllowedStatus(Status.VOTE) {
        require(block.timestamp >= triggeredVoteTime + 1 hours, "Voting has not started yet");
        require(!voters[msg.sender] || !sdvNFT.hasVoted(msg.sender), "You have already voted !");
        require(_candidateId > 0 && _candidateId <= candidateIds.length, "Invalid candidate ID");

        voters[msg.sender] = true;
        candidates[_candidateId].voteCount += 1;

        sdvNFT.mint(msg.sender);
    }

    // Récupération des fonds
    function withdraw() external onlyWithdrawer onlyAllowedStatus(Status.COMPLETED) {
        (bool successCall, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(successCall, "The withdrawal has failed.");
    }

    // Récupération du vainqueur du vote
    function getWinner() external view onlyAllowedStatus(Status.COMPLETED) returns (Candidate memory winner) {
        uint finalVotes = 0;

        for(uint i=0; i < candidateIds.length; i++) {
            Candidate memory c = candidates[candidateIds[i]];
            if(c.voteCount > finalVotes) {
                finalVotes = c.voteCount;
                winner = c;
            }
        }
    }

    // Récupération du nombre de votes
    function getTotalVotes(uint _candidateId) public view returns (uint) {
        require(_candidateId > 0 && _candidateId <= candidateIds.length, "Invalid candidate ID");
        return candidates[_candidateId].voteCount;
    }

    // Récupération du nombre de candidats
    function getCandidatesCount() public view returns (uint) {
        return candidateIds.length;
    }

    // Récupération d'un candidat par son ID
    function getCandidate(uint _candidateId) public view returns (Candidate memory) {
        require(_candidateId > 0 && _candidateId <= candidateIds.length, "Invalid candidate ID");
        return candidates[_candidateId];
    }

    function getStatus() public view returns (Status) {
        return votingStatus;
    }

    function setStatus(Status _status) public onlyAdmin {
        votingStatus = _status;

        if(_status == Status.VOTE) {
            triggeredVoteTime = block.timestamp;
        }
    }
}