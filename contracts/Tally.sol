// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Tally {
    
    // Address of the contract creator (typically the election authority)
    address public owner;
    address public votingContract;

    function setVotingContract(address _votingContract) external onlyOwner {
        votingContract = _votingContract;
    }

    // Flag to check if the final results have already been published
    bool public resultsPublished;

    // Mapping to store vote counts for each candidate
    mapping(string => uint256) public voteCount;

    // Array to keep track of all candidate names
    mapping(string => bool) public candidateExists;
    string[] public candidates;

    // Event triggered when votes for a candidate are tallied
    event VotesTallied(string candidate, uint256 count);

    // Event triggered once the results are officially published
    event ResultsPublished();

    // Restricts access to functions to only the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the admin can perform this action.");
        _;
    }

    modifier onlyVotingContract() {
        require(msg.sender == votingContract, "Only the voting contract can call this function.");
        _;
    }

    /// Prevents functions from being called again after results are published
    modifier notPublished() {
        require(!resultsPublished, "Results have already been published.");
        _;
    }

    // Constructor to initialise the contract with the candidate list
    constructor() {
        owner = msg.sender;
        resultsPublished = false;
    }

    // Add votes to a candidate's total (can be called multiple times before publishing)
    // candidate The name of the candidate to receive additional votes
    // count Number of votes to add
    function addVotes(string memory candidate, uint256 count) external onlyVotingContract {
        if (!candidateExists[candidate]) {
            candidateExists[candidate] = true;
            candidates.push(candidate);
        }

        voteCount[candidate] += count;
        emit VotesTallied(candidate, voteCount[candidate]);
    }

    // Finalises and publishes the election results
    // Once published, votes can no longer be added
    function publishResults() public onlyVotingContract notPublished {
        require(msg.sender == votingContract, "Not voting contract");
        resultsPublished = true;
        emit ResultsPublished();
    }

    // Gets all results
    function getAllResults() public view returns (string[] memory, uint256[] memory) {
    uint256[] memory counts = new uint256[](candidates.length);
    for (uint i = 0; i < candidates.length; i++) {
        counts[i] = voteCount[candidates[i]];
    }
    return (candidates, counts);
    }

}