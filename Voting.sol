// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IVoterRegistry {
    function isRegistered(address user) external view returns (bool);
    function hasVoted(address user) external view returns (bool);
    function setHasVoted(address user) external;
}

interface ITally {
    function addVotes(string memory candidate, uint256 count) external;
    function publishResults() external;
}

contract Voting {
    address public owner;
    bool public electionStarted;
    bool public resultsPublished;

    IVoterRegistry public registry;
    ITally public tally;

    string[] public candidates;

    event ElectionStarted();
    event VoteCasted(address voter, string candidate);
    event ResultsPublished();

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier electionActive() {
        require(electionStarted, "Election not started");
        require(!resultsPublished, "Voting ended");
        _;
    }

    constructor(
        string[] memory _candidates,
        address _registryAddress,
        address _tallyAddress
    ) {
        owner = msg.sender;
        candidates = _candidates;
        registry = IVoterRegistry(_registryAddress);
        tally = ITally(_tallyAddress);
    }

    function startElection() public onlyOwner {
        require(!electionStarted, "Already started");
        electionStarted = true;
        emit ElectionStarted();
    }

    function vote(string memory candidate) public electionActive {
        require(registry.isRegistered(msg.sender), "Not registered");
        require(!registry.hasVoted(msg.sender), "Already voted");

        bool valid = false;
        for (uint i = 0; i < candidates.length; i++) {
            if (keccak256(bytes(candidates[i])) == keccak256(bytes(candidate))) {
                valid = true;
                break;
            }
        }
        require(valid, "Candidate not found");

        registry.setHasVoted(msg.sender);
        tally.addVotes(candidate, 1);
        emit VoteCasted(msg.sender, candidate);
    }

    function publishResults() public onlyOwner {
        require(!tallyResultsPublished(), "Already published");
        tally.publishResults();
        emit ResultsPublished();
    }

    function tallyResultsPublished() public view returns (bool) {
        (bool success, bytes memory data) = address(tally).staticcall(
            abi.encodeWithSignature("resultsPublished()")
        );
        require(success, "Failed to fetch results");
        return abi.decode(data, (bool));
    }

    function getAllCandidates() public view returns (string[] memory) {
        return candidates;
    }
}
