## `CVT`



Inheritance of the {ERC20} implementation and Using some
features of {ERC20Burnable} and {ERC20Mintable} .


### `constructor(string name, string symbol)` (public)



Sets the values for {name} and {symbol}, initializes
{decimals} with a value of 0.

The formal two of these values are immutable: they can only
be set once during construction.

### `mint(address account, uint256 amount) → bool` (public)



Mints `amount` tokens to `account`.

See {ERC20-_mint}.

### `burn(uint256 amount) → bool` (public)



Burns `amount` tokens from the caller.

See {ERC20Burnable-burn}.

### `burnFrom(address account, uint256 amount) → bool` (public)



Burns `amount` tokens from `account`.

See {ERC20Burnable-burnFrom}.

### `addOwnership(address account, uint8 level) → bool` (public)



Calls {_addOwnership}.

### `deleteOwnership(address account) → bool` (public)



Calls {_deleteOwnership}.

### `transferOwnership(address oldOwner, address newOwner) → bool` (public)



Calls {_transferOwnership}.

### `changeOwnershipLevel(address account, uint8 level) → bool` (public)



Calls {_changeOwnershipLevel}.


