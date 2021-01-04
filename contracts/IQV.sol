// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;


/**
 * @dev Abstarct contract of the Quadratic Voting (QV).
 */
abstract contract IQV {
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
    ) external virtual returns (bool);

    /**
     * @dev Joins in the `ballotNum`-th ballot by burning `amount` of tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Join} event.
     */
    function joinAt(
        uint256 ballotNum,
        uint256 amount
    ) public virtual returns (bool);

    /**
     * @dev Votes at the `proposals` with using `weights` tokens in the `ballotNum`-th ballot.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits an one or multiple {Vote} event(s).
     */
    function voteAt(
        uint256 ballotNum,
        uint256[] calldata proposals,
        uint256[] calldata weights
    ) external virtual returns (bool);

    /**
     * @dev Returns the amount of weights and voting flag.
     *
     * Only himself.
     */
    function voterAt(
        uint256 ballotNum
    ) public view virtual returns (
        uint256 weights_,
        bool voted_
    );

    /**
     * @dev Returns the amount of ballots in existence.
     */
    function totalBallots(
        // ...
    ) public view virtual returns (
        uint256 length_
    );

    /**
     * @dev Returns the number of the proposals.
     */
    function proposalsLengthOf(
        uint256 ballotNum
    ) public view virtual returns (
        uint256 length_
    );

    /**
     * @dev Returns the array of names and accumulated expected values of the proposals.
     */
    function proposalsOf(
        uint256 ballotNum
    ) public view virtual returns (
        bytes32[] memory names_
    );

    /**
     * @dev Returns the name and accumulated expected value of the proposal.
     */
    function proposalOf(
        uint256 ballotNum,
        uint256 proposalNum
    ) public view virtual returns (
        bytes32 name_
    );

    /** 
     * @dev Computes or gets the winning proposal.
     */
    function winningProposalOf(
        uint256 ballotNum
    ) public view virtual returns (
        uint256 winningProposal_
    );

    /** 
     * @dev Gets the winning proposal's name.
     */
    function winnerNameOf(
        uint256 ballotNum
    ) public view virtual returns (
        bytes32 winnerName_
    );

    /**
     * @dev Emitted when `ballotName` and `proposalName` are created.
     *
     * Multiple proposals should call multiple {Create} events.
     */
    event Create(bytes32 indexed ballotName, bytes32 indexed proposalName);

    /**
     * @dev Emitted when `who` joins in the `ballotNum`-th ballot with `amount` tokens.
     */
    event Join(address indexed who, uint256 indexed ballotNum, uint256 amount);

    /**
     * @dev Emitted when `who` votes at `proposal` in the `ballotNum`-th ballot
     * with `weights` tokens.
     *
     * Voting at multiple proposals should call multiple {Vote} events.
     */
    event Vote(address indexed who, uint256 indexed ballotNum, uint256 proposal, uint256 weights);
}
