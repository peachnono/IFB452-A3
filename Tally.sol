// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Tally - A simple vote counting and publishing contract
/// @author 
/// @notice This contract is used to tally votes after an election and publish the final results
contract Tally {
    
    // Address of the contract creator (typically the election authority)
    address public owner;

    // Flag to check if the final results have already been published
    bool public resultsPublished;

    // Mapping to store vote counts for each candidate
    mapping(string => uint256) public voteCount;

    // Array to keep track of all candidate names
    string[] public candidates;

    // Event triggered when votes for a candidate are tallied
    event VotesTallied(string candidate, uint256 count);

    // Event triggered once the results are officially published
    event ResultsPublished();

    /// @dev Restricts access to functions to only the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    /// @dev Prevents functions from being called again after results are published
    modifier notPublished() {
        require(!resultsPublished, "Results have already been published.");
        _;
    }

    /// @notice Constructor to initialize the contract with the candidate list
    /// @param _candidates Array of candidate names participating in the election
    constructor(string[] memory _candidates) {
        owner = msg.sender;
        candidates = _candidates;
        resultsPublished = false;
    }

    /// @notice Add votes to a candidate's total (can be called multiple times before publishing)
    /// @param candidate The name of the candidate to receive additional votes
    /// @param count Number of votes to add
    function addVotes(string memory candidate, uint256 count) public onlyOwner notPublished {
        voteCount[candidate] += count;
    }

    /// @notice Finalizes and publishes the election results
    /// @dev Once published, votes can no longer be added
    function publishResults() public onlyOwner notPublished {
        resultsPublished = true;
        emit ResultsPublished();
    }}