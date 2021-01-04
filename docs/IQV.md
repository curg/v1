## `IQV`



Abstarct contract of the Quadratic Voting (QV).


### `createBallot(bytes32 ballotName, bytes32[] proposalNames) → bool` (external)



Creates the ballot with `ballotName` and 
`proposalNames` which is the array of each proposal's name.

Returns a boolean value indicating whether the operation succeeded.

Emits an one or multiple {Create} event(s).

### `joinAt(uint256 ballotNum, uint256 amount) → bool` (public)



Joins in the `ballotNum`-th ballot by burning `amount` of tokens.

Returns a boolean value indicating whether the operation succeeded.

Emits a {Join} event.

### `voteAt(uint256 ballotNum, uint256[] proposals, uint256[] weights) → bool` (external)



Votes at the `proposals` with using `weights` tokens in the `ballotNum`-th ballot.

Returns a boolean value indicating whether the operation succeeded.

Emits an one or multiple {Vote} event(s).

### `voterAt(uint256 ballotNum) → uint256 weights_, bool voted_` (public)



Returns the amount of weights and voting flag.

Only himself.

### `totalBallots() → uint256 length_` (public)



Returns the amount of ballots in existence.

### `proposalsLengthOf(uint256 ballotNum) → uint256 length_` (public)



Returns the number of the proposals.

### `proposalsOf(uint256 ballotNum) → bytes32[] names_` (public)



Returns the array of names and accumulated expected values of the proposals.

### `proposalOf(uint256 ballotNum, uint256 proposalNum) → bytes32 name_` (public)



Returns the name and accumulated expected value of the proposal.

### `winningProposalOf(uint256 ballotNum) → uint256 winningProposal_` (public)



Computes or gets the winning proposal.

### `winnerNameOf(uint256 ballotNum) → bytes32 winnerName_` (public)



Gets the winning proposal's name.


### `Create(bytes32 ballotName, bytes32 proposalName)`



Emitted when `ballotName` and `proposalName` are created.

Multiple proposals should call multiple {Create} events.

### `Join(address who, uint256 ballotNum, uint256 amount)`



Emitted when `who` joins in the `ballotNum`-th ballot with `amount` tokens.

### `Vote(address who, uint256 ballotNum, uint256 proposal, uint256 weights)`



Emitted when `who` votes at `proposal` in the `ballotNum`-th ballot
with `weights` tokens.

Voting at multiple proposals should call multiple {Vote} events.

