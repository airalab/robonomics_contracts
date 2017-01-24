pragma solidity ^0.4.4;
import 'token/Token.sol';
import 'common/Object.sol';

contract LiquidDemocracy is Object {
    Token public votingToken;
    bool  underExecution;
    address public appointee;
    mapping (address => uint) public voterId;
    mapping (address => uint256) public voteWeight;

    uint public delegatedPercent;
    uint public lastWeightCalculation;
    uint public numberOfDelegationRounds;

    uint public numberOfVotes;
    DelegatedVote[] public delegatedVotes;
    string public forbiddenFunction;

    event NewAppointee(address newAppointee, bool changed);

    struct DelegatedVote {
        address nominee;
        address voter;
    }

    function LiquidDemocracy(
        address votingWeightToken,
        string forbiddenFunctionCall,
        uint percentLossInEachRound
    ) {
        votingToken = Token(votingWeightToken);
        delegatedVotes.length++;
        delegatedVotes[0] = DelegatedVote({nominee: 0, voter: 0});
        forbiddenFunction = forbiddenFunctionCall;
        delegatedPercent = 100 - percentLossInEachRound;
        if (delegatedPercent > 100) delegatedPercent = 100;
    }

    function vote(address nominatedAddress) returns (uint voteIndex) {
        if (voterId[msg.sender]== 0) {
            voterId[msg.sender] = delegatedVotes.length;
            numberOfVotes++;
            voteIndex = delegatedVotes.length++;
            numberOfVotes = voteIndex;
        }
        else {
            voteIndex = voterId[msg.sender];
        }

        delegatedVotes[voteIndex] = DelegatedVote({nominee: nominatedAddress, voter: msg.sender});
    }

    function execute(address target, uint valueInEther, bytes32 bytecode) {
        if (msg.sender != appointee                                 // If caller is the current appointee,
            || underExecution //                                    // if the call is being executed,
            || bytes4(bytecode) == bytes4(sha3(forbiddenFunction))  // and it's not trying to do the forbidden function
            || numberOfDelegationRounds < 4 )                       // and delegation has been calculated enough
            throw;

        underExecution = true;

        if (!target.call.value(valueInEther * 1 ether)(bytecode)) { // Then execute the command.
            throw;
        }
        else {
          underExecution = false;
        }
    }

    function calculateVotes() returns (address winner) {
        address currentWinner = appointee;
        uint currentMax = 0;
        uint weight = 0;
        DelegatedVote v = delegatedVotes[0];

        if (now > lastWeightCalculation + 90 minutes) {
            numberOfDelegationRounds = 0;
            lastWeightCalculation = now;

            // Distribute the initial weight
            for (uint i=1; i< delegatedVotes.length; i++) {
                voteWeight[delegatedVotes[i].nominee] = 0;
            }
            for (i=1; i< delegatedVotes.length; i++) {
                voteWeight[delegatedVotes[i].voter] = votingToken.balanceOf(delegatedVotes[i].voter);
            }
        }
        else {
            numberOfDelegationRounds++;
            uint lossRatio = 100 * delegatedPercent ** numberOfDelegationRounds / 100 ** numberOfDelegationRounds;
            if (lossRatio > 0) {
                for (i=1; i< delegatedVotes.length; i++){
                    v = delegatedVotes[i];

                    if (v.nominee != v.voter && voteWeight[v.voter] > 0) {
                        weight = voteWeight[v.voter] * lossRatio / 100;
                        voteWeight[v.voter] -= weight;
                        voteWeight[v.nominee] += weight;
                    }

                    if (numberOfDelegationRounds>3 && voteWeight[v.nominee] > currentMax) {
                        currentWinner = v.nominee;
                        currentMax = voteWeight[v.nominee];
                    }
                }
            }
        }

        if (numberOfDelegationRounds > 3) {
            NewAppointee(currentWinner, appointee == currentWinner);
            appointee = currentWinner;
        }

        return currentWinner;
    }

    function () payable {}
}
