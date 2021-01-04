## `PQV`



Implementation of the {IQV} abstract contract based on 'PQV' method.

Probablistic quadratic voting, PQV, is the mitigation of 'Sybil attack'.
See the paper 'Secure Voting System with Sybil Attack Resistance using
Probabilistic Quadratic Voting and Trusted Execution Environment' for
advanced.


### `constructor(address initialCVTAddress, address initialRandomAddress)` (public)



Sets the 'CVT' and 'Random' contracts.

Requirements:

- the `CVTAddress` MUST be a contract address.
- the `initialRandomAddress` MUST be a contract address.

### `createBallot(bytes32 ballotName, bytes32[] proposalNames) → bool` (external)



Creates the ballot with `ballotName` and 
`proposalNames` which is the array of each proposal's name.

Returns a boolean value indicating whether the operation succeeded.

Emits an one or multiple {Create} event(s).

### `createBallot(bytes32 ballotName, bytes32[] proposalNames, uint256 ballotTimeLimit) → bool` (external)



Creates the ballot with `ballotName`, `proposalNames`, and
`ballotTimeLimit` which is the time (seconds) when vote ends.

Returns a boolean value indicating whether the operation succeeded.

Emits an one or multiple {Create} event(s).

Requirements:

- `ballotTimeLimit` >= `_minimumTimeLimit`

### `_createBallot(bytes32 ballotName, bytes32[] proposalNames, uint256 ballotTimeLimit)` (internal)



Creates the ballot with `ballotName`, `proposalNames`, and `ballotTimeLimit`.
Also it reserves random campaign via {_randomAddress}.

This is internal function is equivalent to {createBallot}.

Returns a boolean value indicating whether the operation succeeded.

Emits an one or multiple {Create} event(s).

### `joinAt(uint256 ballotNum, uint256 amount) → bool` (public)



Joins in the `ballotNum`-th ballot by burning `amount` of tokens.

Returns a boolean value indicating whether the operation succeeded.

Emits a {Join} event.

Requirements:

- the caller MUST NOT vote the ballot before.
- `ballotNum` cannot be out of the range of array.
- the caller MUST have a balance of at least `amount`.

### `voteAt(uint256 ballotNum, uint256[] proposals, uint256[] weights) → bool` (external)



Votes at the `proposals` with using `weights` tokens in the `ballotNum`-th ballot.

Returns a boolean value indicating whether the operation succeeded.

Emits an one or multiple {Vote} event(s).

Requirements:

- the caller MUST NOT vote the ballot before.
- `ballotNum` cannot be out of the range of array.
- each element of `proposals` cannot be out of the range of array.
- the caller MUST have a balance of at least sum of `weights`.

### `tallyUp(uint256 ballotNum) → bool` (public)



ends the `ballotNum`-th ballot.

Returns a boolean value indicating whether the operation succeeded.

Requirements:

- `ballotNum` cannot be out of the range of array.
- `ballotNum`-th ballot's `timeLimit` SHOULD be exceed.
- at least one voting is needed.

### `_probablistic(uint256 voteCount, uint256 totalVoteCount, uint256 exponent_) → uint256` (internal)



Computes probability of voting.

### `_totalVoteCountOf(uint256 ballotNum) → uint256 totalVoteCounts_` (internal)



Computes total votes in the `ballotNum`-th ballot.

### `voterAt(uint256 ballotNum) → uint256 weights_, bool voted_` (public)



Returns the amount of ballots in existence.

Only himself.

### `totalBallots() → uint256 length_` (public)



Returns the amount of ballots in existence.

### `proposalsLengthOf(uint256 ballotNum) → uint256 length_` (public)



Returns the number of the proposals.

### `proposalsOf(uint256 ballotNum) → bytes32[] names_` (public)



Returns the array of names of the proposals.

TODO: Returns accumulated expected values.

### `proposalOf(uint256 ballotNum, uint256 proposalNum) → bytes32 name_` (public)



Returns the name of the proposal.

TODO: Returns accumulated expected value.

### `winningProposalOf(uint256 ballotNum) → uint256 winningProposal_` (public)



Computes or gets the winning proposal.

Requirements:

- ballot MUST be ended.

### `winnerNameOf(uint256 ballotNum) → bytes32 winnerName_` (public)



Gets the winning proposal's name.

Requirements:

- ballot MUST have been ended before.

### `getBallotOf(uint256 ballotNum) → bytes32 name_, uint256 currentTime_, uint256 timeLimit_, bool ended_, uint256 winningProposal_` (public)



Returns the `ballotNum`-th ballot.

### `getExponent() → uint256` (public)



Returns the number of exponent.

### `setExponent(uint256 newExponent)` (public)



Sets {_exponent} to a value other than the default one of 2.

### `getMinimumTimeLimit() → uint256` (public)



Returns the minimum time limit.

### `setMinimumTimeLimit(uint256 newMinimumTimeLimit)` (public)



Sets {_minimumTimeLimit} to a value
other than the default one of 1 hours.

### `getCVTAddress() → address` (public)



Returns the address of 'CVT' contract.

### `setCVTAddress(address newCVTAddress)` (public)



Sets the 'CVT' via an address.
{newCVTAddress}.

Requirements:

- the `newCVTAddress` MUST be contract address.

### `getRandomAddress() → address` (public)



Returns the address of 'Random' contract.

### `setRandomAddress(address newRandomAddress)` (public)



Sets the 'Random' contract via an address.
{newRandomAddress}.

Requirements:

- the `newRandomAddress` MUST be contract address.

### `_pow(uint256 a, uint256 b) → uint256` (internal)



Computes power.

`a` ** 'b'.

### `_sqrt(uint256 x) → uint256 y` (internal)



Computes sqrt of `x`.

### `_sum(uint256[] list) → uint256 sum_` (internal)



Computes summation of array `list`.

### `_uint256ToInt256(uint256 x) → int256 y` (internal)



Converts uint256 to int256

TODO: Safe type casting.

### `addOwnership(address account, uint8 level) → bool` (public)



Calls {_addOwnership}.

### `deleteOwnership(address account) → bool` (public)



Calls {_deleteOwnership}.

### `transferOwnership(address oldOwner, address newOwner) → bool` (public)



Calls {_transferOwnership}.

### `changeOwnershipLevel(address account, uint8 level) → bool` (public)



Calls {_changeOwnershipLevel}.


