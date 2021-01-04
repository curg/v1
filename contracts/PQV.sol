// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "openzeppelin-solidity/contracts/GSN/Context.sol";
import "./access/MultiOwnable.sol";
import "./IQV.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/utils/Address.sol";
import "./token/CVT.sol";
import "./random/Random.sol";


/**
 * @title PQV
 * @dev Implementation of the {IQV} abstract contract based on 'PQV' method.
 *
 * Probablistic quadratic voting, PQV, is the mitigation of 'Sybil attack'.
 * See the paper 'Secure Voting System with Sybil Attack Resistance using
 * Probabilistic Quadratic Voting and Trusted Execution Environment' for
 * advanced.
 */
contract PQV is Context, MultiOwnable, IQV {
    using SafeMath for uint256;
    using Address for address;

    struct Voter {
        uint256 weights;
        bool voted; // if true, that person already voted
    }

    struct Proposal {
        // If you can limit the length to a certain number of bytes, 
        // always use one of bytes1 to bytes32 because they are much cheaper
        bytes32 name;           // short name (up to 32 bytes)
        uint256[] voteCounts;   // number of accumulated votes (sqrt-ed)
    }

    struct Ballot {
        bytes32 name;
        uint256 currentTime;
        uint256 timeLimit;
        Proposal[] proposals;
        mapping(address => Voter) voters;
        bool ended;
        uint256 winningProposal;
    }

    address private _CVTAddress;
    address private _randomAddress;
    
    bytes4 private constant BURNFROM = bytes4(keccak256(bytes('burnFrom(address,uint256)')));
    bytes4 private constant RANDOM = bytes4(keccak256(bytes('random()')));

    uint8 private constant OWNERBLE = 7;
    uint8 private constant ADDRESS = 7;
    uint8 private constant EXPONENT = 6;
    uint8 private constant TIMELIMIT = 5;

    uint256 private _exponent = 2;
    uint256 private _minimumTimeLimit = 1 hours;

    Ballot[] private _ballots;

    /**
     * @dev Sets the 'CVT' and 'Random' contracts.
     *
     * Requirements:
     *
     * - the `CVTAddress` MUST be a contract address.
     * - the `initialRandomAddress` MUST be a contract address.
     */
    constructor (
        address initialCVTAddress,
        address initialRandomAddress
    ) public {
        // conditions
        require(initialCVTAddress.isContract(), "NOT a contract address.");
        require(initialRandomAddress.isContract(), "NOT a contract address.");

        _CVTAddress = initialCVTAddress;    // CVT contract
        _randomAddress = initialRandomAddress;  // Random contract
    }

    /**
     * @dev Creates the ballot with `ballotName` and 
     * `proposalNames` which is the array of each proposal's name.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits an one or multiple {Create} event(s).
     */
    function createBallot(
        bytes32 ballotName,
        bytes32[] calldata proposalNames
    ) external override returns (bool) {
        _createBallot(ballotName, proposalNames, _minimumTimeLimit);

        return true;
    }

    /**
     * @dev Creates the ballot with `ballotName`, `proposalNames`, and
     * `ballotTimeLimit` which is the time (seconds) when vote ends.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits an one or multiple {Create} event(s).
     *
     * Requirements:
     *
     * - `ballotTimeLimit` >= `_minimumTimeLimit`
     */
    function createBallot(
        bytes32 ballotName,
        bytes32[] calldata proposalNames,
        uint256 ballotTimeLimit
    ) external returns (bool) {
        _createBallot(ballotName, proposalNames, ballotTimeLimit);

        return true;
    }

    /**
     * @dev Creates the ballot with `ballotName`, `proposalNames`, and `ballotTimeLimit`.
     * Also it reserves random campaign via {_randomAddress}.
     *
     * This is internal function is equivalent to {createBallot}.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits an one or multiple {Create} event(s).
     */
    function _createBallot(
        bytes32 ballotName,
        bytes32[] memory proposalNames,
        uint256 ballotTimeLimit
    ) internal {
        // conditions
        require(
            ballotTimeLimit >= _minimumTimeLimit,
            "`ballotTimeLimit` MUST be higher than or at least same as `_minimumTimeLimit`."
        );

        _ballots.push();
        Ballot storage ballot = _ballots[_ballots.length - 1];

        ballot.name = ballotName;
        ballot.currentTime = now;
        ballot.timeLimit = ballotTimeLimit;
        for (uint256 i = 0; i < proposalNames.length; i++) {
            ballot.proposals.push(Proposal({
                name: proposalNames[i],
                voteCounts: new uint256[](0)
            }));

            emit Create(ballotName, proposalNames[i]);
        }
    }

    /**
     * @dev Joins in the `ballotNum`-th ballot by burning `amount` of tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Join} event.
     *
     * Requirements:
     *
     * - the caller MUST NOT vote the ballot before.
     * - `ballotNum` cannot be out of the range of array.
     * - the caller MUST have a balance of at least `amount`.
     */
    function joinAt(
        uint256 ballotNum,
        uint256 amount
    ) public override returns (bool) {
        Ballot storage ballot = _ballots[ballotNum];

        // conditions
        require(!ballot.ended, "The ballot is ended.");
        require(ballot.currentTime + ballot.timeLimit > now, "Exceed time limit.");
        require(!ballot.voters[_msgSender()].voted, "You already voted.");

        (bool check, bytes memory data) = _CVTAddress.call(
            abi.encodeWithSelector(BURNFROM, _msgSender(), amount)
        );
        require(
            check && (data.length == 0 || abi.decode(data, (bool))),
            "call burnFrom(address, uint256) is failed."
        );

        ballot.voters[_msgSender()].weights = ballot.voters[_msgSender()].weights.add(amount);

        emit Join(_msgSender(), ballotNum, amount);

        return true;
    }

    /**
     * @dev Votes at the `proposals` with using `weights` tokens in the `ballotNum`-th ballot.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits an one or multiple {Vote} event(s).
     *
     * Requirements:
     *
     * - the caller MUST NOT vote the ballot before.
     * - `ballotNum` cannot be out of the range of array.
     * - each element of `proposals` cannot be out of the range of array.
     * - the caller MUST have a balance of at least sum of `weights`.
     */
    function voteAt(
        uint256 ballotNum,
        uint256[] calldata proposals_,
        uint256[] calldata weights_
    ) external override returns (bool) {
        Ballot storage ballot = _ballots[ballotNum];
        Voter storage sender = ballot.voters[_msgSender()];

        // conditions
        require(!ballot.ended, "The ballot is ended.");
        require(ballot.currentTime + ballot.timeLimit > now, "Exceed time limit.");
        require(!sender.voted, "You already voted.");
        require(_sum(weights_) <= sender.weights, "Exceed the rights.");

        sender.voted = true;

        // If 'i' is out of the range of the array,
        // this will throw automatically and revert all changes
        for (uint256 i = 0; i < proposals_.length; i++) {
            ballot.proposals[proposals_[i]].voteCounts.push(weights_[i]);

            emit Vote(_msgSender(), ballotNum, proposals_[i], weights_[i]);
        }

        return true;
    }

    /**
     * @dev ends the `ballotNum`-th ballot.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Requirements:
     *
     * - `ballotNum` cannot be out of the range of array.
     * - `ballotNum`-th ballot's `timeLimit` SHOULD be exceed.
     * - at least one voting is needed.
     */
    function tallyUp(
        uint256 ballotNum
    ) public returns (bool) {
        Ballot storage ballot = _ballots[ballotNum];

        // conditions
        require(!ballot.ended, "Already ended.");
        require(ballot.currentTime + ballot.timeLimit <= now, "Not yet.");
        uint256 totalVoteCount = _totalVoteCountOf(ballotNum);
        require(totalVoteCount != 0, "Nobody voted.");

        ballot.ended = true;

        uint256 winningVoteCount = 0;
        uint256 voteCount = 0;

        while (winningVoteCount == 0) { // until non-zero
            for (uint256 p = 0; p < ballot.proposals.length; p++) {
                Proposal storage proposal = ballot.proposals[p];

                voteCount = 0;
                for (uint256 v = 0; v < proposal.voteCounts.length; v++) {

                    // PQV
                    voteCount = voteCount.add(
                        _probablistic(
                            proposal.voteCounts[v],
                            totalVoteCount,
                            _exponent
                        )
                    );
                }

                if (
                    voteCount > winningVoteCount
                ) { // new winning proposal
                    winningVoteCount = voteCount;
                    ballot.winningProposal = p;
                }
                else if (
                    (voteCount != 0) && (voteCount == winningVoteCount)
                ) { // pick randomly
                    (bool check, bytes memory data) = address(_randomAddress).call(
                        abi.encodeWithSelector(RANDOM)
                    );
                    require(
                        check && (data.length != 0),
                        "call random() is failed."
                    );
                    uint256 returnValue = abi.decode(data, (uint256));

                    if (returnValue.mod(2) == 1) {
                        winningVoteCount = voteCount;
                        ballot.winningProposal = p;
                    }
                }
            }
        }

        return true;
    }

    /** 
     * @dev Computes probability of voting.
     */
    function _probablistic(
        uint256 voteCount,
        uint256 totalVoteCount,
        uint256 exponent_
    ) internal returns (uint256) {
        uint256 numerator = _pow(voteCount, exponent_);

        if (numerator >= totalVoteCount) {
            return _sqrt(voteCount);
        }
        else {
            (bool check, bytes memory data) = address(_randomAddress).call(
                abi.encodeWithSelector(RANDOM)
            );
            require(
                check && (data.length != 0),
                "call random() is failed."
            );
            uint256 returnValue = abi.decode(data, (uint256));

            if (numerator > returnValue.mod(totalVoteCount)) {
                return _sqrt(voteCount);
            }
        }
        return 0;
    }

    /** 
     * @dev Computes total votes in the `ballotNum`-th ballot.
     */
    function _totalVoteCountOf(
        uint256 ballotNum
    ) internal view returns (uint256 totalVoteCounts_) {
        Ballot storage ballot = _ballots[ballotNum];

        for (uint256 i=0; i<ballot.proposals.length; i++) {
            totalVoteCounts_ = totalVoteCounts_.add(_sum(ballot.proposals[i].voteCounts));
        }
    }

    /**
     * @dev Returns the amount of ballots in existence.
     *
     * Only himself.
     */
    function voterAt(
        uint256 ballotNum
    ) public view override returns (
        uint256 weights_,
        bool voted_
    ) {
        Ballot storage ballot = _ballots[ballotNum];

        weights_ = ballot.voters[_msgSender()].weights;
        voted_ = ballot.voters[_msgSender()].voted;
    }

    /**
     * @dev Returns the amount of ballots in existence.
     */
    function totalBallots(
    ) public view override returns (
        uint256 length_
    ) {
        length_ = _ballots.length;
    }

    /**
     * @dev Returns the number of the proposals.
     */
    function proposalsLengthOf(
        uint256 ballotNum
    ) public view override returns (
        uint256 length_
    ) {
        length_ = _ballots[ballotNum].proposals.length;
    }

    /**
     * @dev Returns the array of names of the proposals.
     *
     * TODO: Returns accumulated expected values.
     */
    function proposalsOf(
        uint256 ballotNum
    ) public view override returns (
        bytes32[] memory names_
    ) {
        uint256 length_ = proposalsLengthOf(ballotNum);

        names_ = new bytes32[](length_);

        for (uint256 i=0; i<length_; i++) {
            names_[i] = proposalOf(ballotNum, i);
        }
    }

    /**
     * @dev Returns the name of the proposal.
     *
     * TODO: Returns accumulated expected value.
     */
    function proposalOf(
        uint256 ballotNum,
        uint256 proposalNum
    ) public view override returns (
        bytes32 name_
    ) {
        Proposal storage proposal = _ballots[ballotNum].proposals[proposalNum];
        name_ = proposal.name;
    }

    /** 
     * @dev Computes or gets the winning proposal.
     *
     * Requirements:
     *
     * - ballot MUST be ended.
     */
    function winningProposalOf(
        uint256 ballotNum
    ) public view override returns (
        uint256 winningProposal_
    ) {
        Ballot storage ballot = _ballots[ballotNum];

        require(ballot.ended, "Not yet.");

        winningProposal_ = ballot.winningProposal;
    }

    /** 
     * @dev Gets the winning proposal's name.
     *
     * Requirements:
     *
     * - ballot MUST have been ended before.
     */
    function winnerNameOf(
        uint256 ballotNum
    ) public view override returns (
        bytes32 winnerName_
    ) {
        Ballot storage ballot = _ballots[ballotNum];

        require(ballot.ended, "Not yet.");

        winnerName_ = ballot.proposals[winningProposalOf(ballotNum)].name;
    }

    /**
     * @dev Returns the `ballotNum`-th ballot.
     */
    function getBallotOf(
        uint256 ballotNum
    ) public view returns (
        bytes32 name_,
        uint256 currentTime_,
        uint256 timeLimit_,
        bool ended_,
        uint256 winningProposal_
    ) {
        Ballot storage ballot = _ballots[ballotNum];
        name_ = ballot.name;
        currentTime_ = ballot.currentTime;
        timeLimit_ = ballot.timeLimit;
        ended_ = ballot.ended;
        winningProposal_ = ballot.winningProposal;
    }

    /**
     * @dev Returns the number of exponent.
     */
    function getExponent(
        // ...
    ) public view returns (uint256) {
        return _exponent;
    }

    /**
     * @dev Sets {_exponent} to a value other than the default one of 2.
     */
    function setExponent(
        uint256 newExponent
    ) public onlyOwner(EXPONENT) {
        _exponent = newExponent;
    }

    /**
     * @dev Returns the minimum time limit.
     */
    function getMinimumTimeLimit(
        // ...
    ) public view returns (uint256) {
        return _minimumTimeLimit;
    }

    /**
     * @dev Sets {_minimumTimeLimit} to a value
     * other than the default one of 1 hours.
     */
    function setMinimumTimeLimit(
        uint256 newMinimumTimeLimit
    ) public onlyOwner(TIMELIMIT) {
        _minimumTimeLimit = newMinimumTimeLimit;
    }

    /**
     * @dev Returns the address of 'CVT' contract.
     */
    function getCVTAddress(
        // ...
    ) public view returns (address) {
        return _CVTAddress;
    }

    /**
     * @dev Sets the 'CVT' via an address.
     * {newCVTAddress}.
     *
     * Requirements:
     *
     * - the `newCVTAddress` MUST be contract address.
     */
    function setCVTAddress(
        address newCVTAddress
    ) public onlyOwner(ADDRESS) {
        require(newCVTAddress.isContract(), "NOT a contract address.");

        _CVTAddress = newCVTAddress;
    }

    /**
     * @dev Returns the address of 'Random' contract.
     */
    function getRandomAddress(
        // ...
    ) public view returns (address) {
        return _randomAddress;
    }

    /**
     * @dev Sets the 'Random' contract via an address.
     * {newRandomAddress}.
     *
     * Requirements:
     *
     * - the `newRandomAddress` MUST be contract address.
     */
    function setRandomAddress(
        address newRandomAddress
    ) public onlyOwner(ADDRESS) {
        require(newRandomAddress.isContract(), "NOT a contract address.");

        _randomAddress = newRandomAddress;
    }

    /** 
     * @dev Computes power.
     *
     * `a` ** 'b'.
     */
    function _pow(
        uint256 a,
        uint256 b
    ) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        if (a == 1) {
            return 1;
        }
        if (b == 0) {
            return 1;
        }
        if (b == 1) {
            return a;
        }

        uint256 c = a ** b;
        require(c > a, "SafeMath: power overflow");

        return c;
    }

    /** 
     * @dev Computes sqrt of `x`.
     */
    function _sqrt(
        uint256 x
    ) internal pure returns (
        uint256 y
    ) {
        uint256 z = x.add(1).div(2);
        y = x;
        while (z < y) {
            y = z;
            z = x.div(z).add(z).div(2);
        }
    }

    /** 
     * @dev Computes summation of array `list`.
     */
    function _sum(
        uint256[] memory list
    ) internal pure returns (
        uint256 sum_
    ) {
        for(uint256 i=0; i<list.length; i++) {
            sum_ = sum_.add(list[i]);
        }
    }

    /**
     * @dev Converts uint256 to int256
     *
     * TODO: Safe type casting.
     */
    function _uint256ToInt256(
        uint256 x
    ) internal pure returns (
        int256 y
    ) {
        y = int256(x);
    }

    /**
     * @dev Calls {_addOwnership}.
     */
    function addOwnership(
        address account,
        uint8 level
    ) public virtual onlyOwner(OWNERBLE) returns (bool) {
        _addOwnership(account, level);

        return true;
    }

    /**
     * @dev Calls {_deleteOwnership}.
     */
    function deleteOwnership(
        address account
    ) public virtual onlyOwner(OWNERBLE) returns (bool) {
        _deleteOwnership(account);

        return true;
    }

    /**
     * @dev Calls {_transferOwnership}.
     */
    function transferOwnership(
        address oldOwner,
        address newOwner
    ) public virtual onlyOwner(OWNERBLE) returns (bool) {
        _transferOwnership(oldOwner, newOwner);

        return true;
    }

    /**
     * @dev Calls {_changeOwnershipLevel}.
     */
    function changeOwnershipLevel(
        address account,
        uint8 level
    ) public virtual onlyOwner(OWNERBLE) returns (bool) {
        _changeOwnershipLevel(account, level);

        return true;
    }
}
