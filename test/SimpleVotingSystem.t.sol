// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {SimpleVotingSystem} from "../src/SimpleVotingSystem.sol";
import {SupDeVinciNFT} from "../src/SupDeVinciNFT.sol";

contract SimpleVotingSystemTest is Test {
    SimpleVotingSystem public votingSystem;
    SupDeVinciNFT public voteNFT;

    address public constant ADMIN = address(0x1234567890123456789012345678901234567890);
    address public constant FOUNDER = address(0x2345678901234567890123456789012345678901);
    address public constant WITHDRAWER = address(0x3456789012345678901234567890123456789012);

    address public voter1;
    address public voter2;
    address public voter3;

    function setUp() public {
        voter1 = makeAddr("voter1");
        voter2 = makeAddr("voter2");
        voter3 = makeAddr("voter3");

        vm.deal(ADMIN, 100 ether);
        vm.deal(FOUNDER, 50 ether);
        vm.deal(WITHDRAWER, 50 ether);
        vm.deal(voter1, 10 ether);
        vm.deal(voter2, 10 ether);
        vm.deal(voter3, 10 ether);

        vm.startPrank(ADMIN);
        voteNFT = new SupDeVinciNFT();
        votingSystem = new SimpleVotingSystem();

        voteNFT.transferOwnership(address(votingSystem));

        votingSystem.grantRole(votingSystem.FOUNDER_ROLE(), FOUNDER);
        votingSystem.grantRole(votingSystem.WITHDRAWER_ROLE(), WITHDRAWER);
        vm.stopPrank();
    }


    function testAddCandidateAsAdmin() public {
        vm.startPrank(ADMIN);
        votingSystem.addCandidate("Alice");
        vm.stopPrank();

        assertEq(votingSystem.getCandidatesCount(), 1);
        SimpleVotingSystem.Candidate memory c = votingSystem.getCandidate(1);
        assertEq(c.name, "Alice");
        assertEq(c.voteCount, 0);
        assertEq(c.funds, 0);
    }

    function testAddCandidateOnlyAdmin() public {
        vm.startPrank(voter1);
        vm.expectRevert();
        votingSystem.addCandidate("Bob");
        vm.stopPrank();
    }


    function testFundCandidateAsFounder() public {
        vm.startPrank(ADMIN);
        votingSystem.addCandidate("Alice");
        vm.stopPrank();

        vm.startPrank(FOUNDER);
        votingSystem.fundCandidate{value: 1 ether}(1);
        vm.stopPrank();

        SimpleVotingSystem.Candidate memory c = votingSystem.getCandidate(1);
        assertEq(c.funds, 1 ether);
    }

    function testFundCandidateNotFounder() public {
        vm.startPrank(voter1);
        vm.expectRevert();
        votingSystem.fundCandidate{value: 1 ether}(1);
        vm.stopPrank();
    }


    function testVoteValid() public {
        vm.startPrank(ADMIN);
        votingSystem.addCandidate("Alice");
        votingSystem.setStatus(SimpleVotingSystem.Status.VOTE);
        vm.stopPrank();

        vm.warp(block.timestamp + 3600);

        vm.startPrank(voter1);
        votingSystem.vote(1);
        vm.stopPrank();

        assertTrue(votingSystem.voters(voter1));
        SimpleVotingSystem.Candidate memory c = votingSystem.getCandidate(1);
        assertEq(c.voteCount, 1);
        assertTrue(voteNFT.hasVoted(voter1));
    }

    function testVoteOnlyOnce() public {
        vm.startPrank(ADMIN);
        votingSystem.addCandidate("Alice");
        votingSystem.setStatus(SimpleVotingSystem.Status.VOTE);
        vm.stopPrank();

        vm.warp(block.timestamp + 3600);

        vm.startPrank(voter1);
        votingSystem.vote(1);
        vm.stopPrank();

        vm.startPrank(voter1);
        vm.expectRevert("You have already voted !");
        votingSystem.vote(1);
        vm.stopPrank();
    }

    function testVoteBeforeStart() public {
        vm.startPrank(ADMIN);
        votingSystem.addCandidate("Alice");
        votingSystem.setStatus(SimpleVotingSystem.Status.VOTE);
        vm.stopPrank();

        vm.startPrank(voter1);
        vm.expectRevert("Voting has not started yet");
        votingSystem.vote(1);
        vm.stopPrank();
    }


    function testGetWinner() public {
        vm.startPrank(ADMIN);
        votingSystem.addCandidate("Alice");
        votingSystem.addCandidate("Bob");
        votingSystem.setStatus(SimpleVotingSystem.Status.VOTE);
        vm.stopPrank();

        vm.warp(block.timestamp + 3600);

        vm.startPrank(voter1);
        votingSystem.vote(1);
        vm.stopPrank();

        vm.startPrank(voter2);
        votingSystem.vote(2);
        vm.stopPrank();

        vm.startPrank(voter3);
        votingSystem.vote(1);
        vm.stopPrank();

        vm.startPrank(ADMIN);
        votingSystem.setStatus(SimpleVotingSystem.Status.COMPLETED);
        vm.stopPrank();

        SimpleVotingSystem.Candidate memory winner = votingSystem.getWinner();
        assertEq(winner.id, 1);
        assertEq(winner.voteCount, 2);
    }


    function testWithdrawAsWithdrawer() public {
        vm.startPrank(ADMIN);
        votingSystem.addCandidate("Alice");
        votingSystem.setStatus(SimpleVotingSystem.Status.VOTE);
        vm.stopPrank();

        vm.warp(block.timestamp + 3600);

        vm.startPrank(FOUNDER);
        votingSystem.fundCandidate{value: 1 ether}(1);
        vm.stopPrank();

        vm.startPrank(ADMIN);
        votingSystem.setStatus(SimpleVotingSystem.Status.COMPLETED);
        vm.stopPrank();

        uint balanceBefore = WITHDRAWER.balance;

        vm.startPrank(WITHDRAWER);
        votingSystem.withdraw();
        vm.stopPrank();

        uint balanceAfter = WITHDRAWER.balance;
        assertTrue(balanceAfter > balanceBefore);
    }

    function testWithdrawNotWithdrawer() public {
        vm.startPrank(ADMIN);
        votingSystem.addCandidate("Alice");
        votingSystem.setStatus(SimpleVotingSystem.Status.COMPLETED);
        vm.stopPrank();

        vm.startPrank(voter1);
        vm.expectRevert();
        votingSystem.withdraw();
        vm.stopPrank();
    }
}
