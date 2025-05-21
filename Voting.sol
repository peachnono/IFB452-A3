// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Voting - A secure election contract integrated with voter registration
contract Voting {
    address public owner;
    bool public resultsPublished;

    // Candidate name => vote count
    mapping(string => uint256) public voteCount;
    string[] public candidates;

    // Voter address => has voted
    mapping(address => bool) public hasVoted;

    mapping(address => bool) public isRegistered;

    // Events
    event VoteCasted(address indexed voter, string candidate);
    event VotesTallied(string candidate, uint256 count);
    event ResultsPublished();
    event VoterManuallyRegistered(address voter);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier notPublished() {
        require(!resultsPublished, "Results have already been published");
        _;
    }

    modifier onlyRegistered() {
        require(isRegistered[msg.sender], "Not a registered voter");
        _;
    }

    constructor(string[] memory _candidates) {
        owner = msg.sender;
        candidates = _candidates;
        resultsPublished = false;
    }

    function registerVoter(address voter) public onlyOwner {
        require(!isRegistered[voter], "Voter already registered");
        isRegistered[voter] = true;
        emit VoterManuallyRegistered(voter);
    }

    function vote(string memory candidate) public onlyRegistered notPublished {
        require(!hasVoted[msg.sender], "Already voted");

        bool validCandidate = false;
        for (uint i = 0; i < candidates.length; i++) {
            if (keccak256(bytes(candidates[i])) == keccak256(bytes(candidate))) {
                validCandidate = true;
                break;
            }
        }
        require(validCandidate, "Candidate not found");

        voteCount[candidate]++;
        hasVoted[msg.sender] = true;

        emit VoteCasted(msg.sender, candidate);
    }

    function publishResults() public onlyOwner notPublished {
        resultsPublished = true;
        emit ResultsPublished();

        for (uint i = 0; i < candidates.length; i++) {
            emit VotesTallied(candidates[i], voteCount[candidates[i]]);
        }
    }

    function getCandidateVotes(string memory candidate) public view returns (uint256) {
        return voteCount[candidate];
    }

    function getAllCandidates() public view returns (string[] memory) {
        return candidates;
    }
}
