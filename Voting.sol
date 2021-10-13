// contracts/Voting
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Admin.sol";

struct Voter {
bool isRegistered;
bool hasVoted;
uint votedProposalId;
}

struct Proposal {
string description;
uint voteCount;
}


contract Voting is Admin {

    enum WorkflowStatus {
    RegisteringVoters,
    ProposalsRegistrationStarted,
    ProposalsRegistrationEnded,
    VotingSessionStarted,
    VotingSessionEnded,
    VotesTallied
    }

    //Status of the contract
    WorkflowStatus _Status;
    
    event VoterRegistered(address voterAddress);
    event ProposalsRegistrationStarted();
    event ProposalsRegistrationEnded();
    event ProposalRegistered(uint proposalId);
    event VotingSessionStarted();
    event VotingSessionEnded();
    event Voted (address voter, uint proposalId);
    event VotesTallied();
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus
    newStatus);
    
    
    
    
}