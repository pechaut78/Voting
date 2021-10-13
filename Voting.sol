// contracts/Voting
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Admin.sol";



    
contract Voting is Admin {

    struct Voter {
    bool isRegistered;
    bool hasVoted;
    uint votedProposalId;
    }
    
    struct Proposal {
    string description;
    uint voteCount;
    }
    
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
    modifier onlySatus(WorkflowStatus status)
    {
        require(_Status==status,"Function call forbidden now");
        _;
    }

    uint public winningProposalId;  // Store the winner Id
    
    //DB for VoterRegistered & Proposals
    mapping(address=>uint256) _VotersId;    // Mapping of voter's addresses
    Voter[] _Voters;                        // Array of voters
    Proposal[] public _Proposals;           // List of Proposals
    
    
    
    //------------------ Events 
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
    
    
    
    
    constructor() Admin()
    {
        // We start the state machine
        _Status=WorkflowStatus.RegisteringVoters;
    }    
    
    
    //-------------------- Admin functions

    function registerVoter(address addr) public onlySatus(WorkflowStatus.RegisteringVoters)
    {
        whitelist(addr);

        uint256 indx= _Voters.length;
        _VotersId[addr] = indx;
        Voter memory reg;
        reg.isRegistered=true;
        // reg.hasVoted=false; //implicite not needed
        _Voters.push(reg);
        
        emit VoterRegistered(addr);
    }
    
    function startProposalRegistration() public onlyOwner() onlySatus(WorkflowStatus.RegisteringVoters)
    {
        _Status = WorkflowStatus.ProposalsRegistrationStarted;
        emit ProposalsRegistrationStarted();
        emit WorkflowStatusChange(WorkflowStatus.RegisteringVoters,_Status);
    }
    
    function endProposalRegistration() public onlyOwner() onlySatus(WorkflowStatus.ProposalsRegistrationStarted)
    {
        _Status = WorkflowStatus.ProposalsRegistrationEnded;
        emit ProposalsRegistrationEnded();
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationStarted,_Status);
    }
    function startVotingSession() public onlyOwner() onlySatus(WorkflowStatus.ProposalsRegistrationEnded)
    {
        _Status = WorkflowStatus.VotingSessionStarted;
        emit VotingSessionStarted();
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationEnded,_Status);
    }
    function endVotingSession() public onlyOwner() onlySatus(WorkflowStatus.VotingSessionStarted)
    {
        _Status = WorkflowStatus.VotingSessionEnded;
        emit VotingSessionEnded();
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionStarted,_Status);
    }
    function endVotingCount() public onlyOwner() onlySatus(WorkflowStatus.VotingSessionEnded)
    {
        _Status = WorkflowStatus.VotesTallied;
        emit VotesTallied();
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionEnded,_Status);
    }
    
    
    //------------------- Tools 
    function memcmp(bytes memory a, bytes memory b) internal pure returns(bool){
        return (a.length == b.length) && (keccak256(a) == keccak256(b));
    }
    
    
    // Generic functions
    
    //------------------- Proposal Utilities
    function submitProposal(string memory desc) public  onlySatus(WorkflowStatus.ProposalsRegistrationStarted)
    {
        for(uint16 i =0; i<_Proposals.length;i++)
            assert(!memcmp(bytes(_Proposals[i].description),bytes(desc)));  // check if proposal is already in
        
        Proposal memory prop;
        prop.description = desc;
        //prop.voteCount =0; // implicite           
        
        _Proposals.push(prop); // add the proposal
        emit ProposalRegistered(_Proposals.length-1);
    }
    
    function getProposal(uint16 indx) public view returns(string memory) {
        return _Proposals[indx].description;
    }
    function getProposalNb() public view returns(uint16) {
        return uint16(_Proposals.length);
    }
     
    //------------------- Vote Utilities
    function voteFor(uint16 proposition) public onlySatus(WorkflowStatus.VotingSessionStarted) {
        assert(isWhiteListed(msg.sender)); // Make sure the sender is WhiteListed
        uint256 indx = _VotersId[msg.sender];
        assert( !_Voters[indx].hasVoted); // Make sure the sender has not already voted
        assert(proposition<uint16(_Proposals.length)); // Make sure the index is VotesTallied
        
        _Voters[indx].hasVoted = true;
        _Voters[indx].votedProposalId = proposition;
        emit Voted(msg.sender, proposition);
    }
    
    function countVotes() public onlySatus(WorkflowStatus.VotingSessionEnded) onlyOwner()
    {
        for(uint256 i=0;i<_Voters.length;i++)                       // cumulate votes and aggregate them on proposals
            _Proposals[_Voters[i].votedProposalId].voteCount++;

        uint winningCount =0;                                       // Find the winner, parsons all the proposals
        for(uint256 i=0;i<_Proposals.length;i++)
            if(_Proposals[i].voteCount>winningCount)
            {
                winningCount = _Proposals[i].voteCount;
                winningProposalId = i;
            }
        
        endVotingCount();
    }
    
    function getWinningProposition() onlySatus(WorkflowStatus.VotesTallied) public view returns(string memory)
    {
        return _Proposals[winningProposalId].description;
    }
}