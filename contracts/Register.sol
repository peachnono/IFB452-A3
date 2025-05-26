// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract Register {
    //Track who deployed the contract
    address public admin;
    address public votingContract;

    modifier onlyVotingContract() {
        require(msg.sender == votingContract, "Only Voting contract can call this");
        _;
    }

    function setVotingContract(address _votingContract) external {
        require(msg.sender == admin, "Only admin can set voting contract");
        votingContract = _votingContract;
    }

    //Counter for assigning unique voter IDs
    uint256 public voterCount;

    //Voter data struct
    struct Voter {
        string name;
        uint8 age;
        string citizenship;
        string residence;
        bool isRegistered;
        bool hasVoted;
        uint256 voterId;
    }

    //Candidate data struct
    struct Candidate {
        string name;
        address candidateAddress;
    }

    //Map each Ethereum address to its Voter and Candidate record
    mapping(address => Voter) public voters;
    mapping(string => bool) public isCandidateRegistered;

    string[] public candidates;

    //Events to log when things happen
    event VoterVerified(address indexed voter);
    event VoterRegistered(address indexed voter, uint256 voterId);
    event VoteStatusUpdated(address indexed voter);
    event CandidateRegistered(address indexed candidate, string name);

    //Set deployer as admin
    constructor() {
        admin = msg.sender;
        voterCount = 0;
    }

    //Identity check
    function verifyIdentity(
        string memory _name,
        uint8 _age,
        string memory _citizenship,
        string memory _residence

    ) public pure returns (bool) {
        require(_age >= 18, "Must be at least 18");

        // Compare strings by hashing
        require(
            keccak256(bytes(_citizenship)) == keccak256(bytes("AU")),
            "Must be Australian citizen"
        );

        // (add check residence code later for states ?????????or delete comment???????????)
        return true;
    }

    //Register voter if they pass verification and aren't already registered
    function registerVoter(
        string memory _name,
        uint8 _age,
        string memory _citizenship,
        string memory _residence
    ) public {
        //Prevent double-registration
        require(!voters[msg.sender].isRegistered, "Already registered");

        //Verify identity
        require(
            verifyIdentity(_name, _age, _citizenship, _residence),
            "Verification failed"
        );
        emit VoterVerified(msg.sender);

        //Assign new ID and store voter record
        voterCount += 1;
        voters[msg.sender] = Voter({
            name: _name,
            age: _age,
            citizenship: _citizenship,
            residence: _residence,
            isRegistered: true,
            hasVoted: false,
            voterId: voterCount
        });

        //Emit registration event
        emit VoterRegistered(msg.sender, voterCount);
    }

    function setHasVoted(address _voter) external {
        require(voters[_voter].isRegistered, "Not registered");
        require(!voters[_voter].hasVoted, "Already voted");

        voters[_voter].hasVoted = true;
        emit VoteStatusUpdated(_voter);
    }

    function isRegistered(address _voter) external view returns (bool) {
        return voters[_voter].isRegistered;
    }

    function hasVoted(address _voter) external view returns (bool) {
        return voters[_voter].hasVoted;
    }

    function registerCandidate(string memory _name) public onlyVotingContract {

        require(bytes(_name).length > 0, "Name cannot be empty");
        require(!isCandidateRegistered[_name], "Candidate already registered");

        isCandidateRegistered[_name] = true;
        candidates.push(_name);

        emit CandidateRegistered(msg.sender, _name);
    }

    function getAllCandidates() public view returns (string[] memory) {
        return candidates;
    }
}
