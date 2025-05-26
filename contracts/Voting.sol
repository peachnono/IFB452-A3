// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IVoterRegistry {
    function isRegistered(address user) external view returns (bool);
    function hasVoted(address user) external view returns (bool);
    function setHasVoted(address user) external;

    function registerCandidate(string memory name) external;
    function isCandidateRegistered(string memory name) external view returns (bool);
    function getAllCandidates() external view returns (string[] memory);
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

    event ElectionStarted();
    event VoteCasted(address voter, string candidate);
    event ResultsPublished();
    event CandidateRegistered(address indexed candidate, string name);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the admin can perform this action");
        _;
    }

    modifier electionActive() {
        require(electionStarted, "Election not started");
        require(!resultsPublished, "Voting ended");
        _;
    }

    constructor(
        address _registryAddress,
        address _tallyAddress
    ) {
        owner = msg.sender;
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

        string[] memory allCandidates = registry.getAllCandidates();

        bool valid = false;
        for (uint i = 0; i < allCandidates.length; i++) {
            if (keccak256(bytes(allCandidates[i])) == keccak256(bytes(candidate))) {
                valid = true;
                break;
            }
        }
        require(valid, "Candidate not found");

        registry.setHasVoted(msg.sender);
        tally.addVotes(candidate, 1);
        emit VoteCasted(msg.sender, candidate);
    }

    function registerCandidate(string memory name) public {
        require(!electionStarted, "Cannot register after election starts");
        registry.registerCandidate(name);
        emit CandidateRegistered(msg.sender, name);
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
        return registry.getAllCandidates();
    }

}
