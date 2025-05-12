// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Register {
    //Track who deployed the contract
    address public admin;

    //Counter for assigning unique voter IDs
    uint256 public voterCount;

    //Voter data struct
    struct Voter {
        string name;
        uint8 age;
        string citizenship;
        string residence;
        bool isRegistered;
        uint256 voterId;
    }

    //Map each Ethereum address to its Voter record
    mapping(address => Voter) public voters;

    //Events to log when things happen
    event VoterVerified(address indexed voter);
    event VoterRegistered(address indexed voter, uint256 voterId);

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
            voterId: voterCount
        });

        //Emit registration event
        emit VoterRegistered(msg.sender, voterCount);
    }
}
