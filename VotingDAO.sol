// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

contract EMVoting is Ownable {

    uint256 public votingCounter;

    struct Voting {
        bool isActive;
        uint month;
        address employeeOfTheMonth;

        mapping(address => bool) votingStatus;
        mapping(address => address) voteTarget;
        mapping(address => uint256) votesReceived;

        address[] eligibleEmployees;
   }


    mapping(uint => Voting) public votingRegistry;

    event VotingCreate(uint month);
    event VotingClosed(uint month);
    event VoteComputed(address votee, address receiver);
    event EmployeeOfTheMonth(address employee, uint month);



    function createNewVoting(uint _month) public onlyOwner {
        require(!votingRegistry[votingCounter].isActive, "A voting section is already live!");

        Voting storage voting = votingRegistry[votingCounter];

        voting.month = _month;
        voting.isActive = true;
        voting.month = votingCounter;

        emit VotingCreate(_month);
    }

    function vote(address _chosenEmployee) public {
        require(votingRegistry[votingCounter].isActive, "No voting section active at the moment.");
        require(votingRegistry[votingCounter].votingStatus[msg.sender] == false, "You can only vote once.");

        if(votingRegistry[votingCounter].votesReceived[_chosenEmployee] == 0) {
            votingRegistry[votingCounter].eligibleEmployees.push(_chosenEmployee);
        }

        votingRegistry[votingCounter].votesReceived[_chosenEmployee] ++;
        votingRegistry[votingCounter].voteTarget[msg.sender] = _chosenEmployee;
        votingRegistry[votingCounter].votingStatus[msg.sender] = true;

        emit VoteComputed(msg.sender, _chosenEmployee);
    }

    function endVoting() public onlyOwner {
        require(!votingRegistry[votingCounter].isActive, "No voting section active at the moment.");

        votingRegistry[votingCounter].isActive = false;
        getMostVotedEmployee();

        emit VotingClosed(votingCounter);

        votingCounter ++;
    }

    function getMostVotedEmployee() public {
        address[] storage contestants = votingRegistry[votingCounter].eligibleEmployees;

        address employeeOfTheMonth = contestants[0];

        for(uint i = 1; i < contestants.length; i ++) {
            if (votingRegistry[votingCounter].votesReceived[contestants[i]] > votingRegistry[votingCounter].votesReceived[employeeOfTheMonth]) {
                employeeOfTheMonth = votingRegistry[votingCounter].eligibleEmployees[i];
            }
        }

        votingRegistry[votingCounter].employeeOfTheMonth = employeeOfTheMonth;

        emit EmployeeOfTheMonth(employeeOfTheMonth, votingCounter);
    }

}
