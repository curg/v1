// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../access/MultiOwnable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";


/**
 * @title CVT
 * @dev Inheritance of the {ERC20} implementation and Using some
 * features of {ERC20Burnable} and {ERC20Mintable} .
 */
contract CVT is MultiOwnable, ERC20 {
    uint8 private constant OWNERBLE = 7;
    uint8 private constant MINTABLE = 6;
    uint8 private constant BURNABLE = 5;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes
     * {decimals} with a value of 0.
     *
     * The formal two of these values are immutable: they can only
     * be set once during construction.
     */
    constructor (
        string memory name,
        string memory symbol
    ) public payable ERC20(name, symbol) {
        _setupDecimals(0);
    }

    /**
     * @dev Mints `amount` tokens to `account`.
     *
     * See {ERC20-_mint}.
     */
    function mint(
        address account,
        uint256 amount
    ) public onlyOwner(MINTABLE) returns (bool) {
        _mint(account, amount);

        return true;
    }

    /**
     * @dev Burns `amount` tokens from the caller.
     *
     * See {ERC20Burnable-burn}.
     */
    function burn(
        uint256 amount
    ) public returns (bool) {
        _burn(_msgSender(), amount);

        return true;
    }

    /**
     * @dev Burns `amount` tokens from `account`.
     *
     * See {ERC20Burnable-burnFrom}.
     */
    function burnFrom(
        address account,
        uint256 amount
    ) public onlyOwner(BURNABLE) returns (bool) {
        // uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");
        // _approve(account, _msgSender(), decreasedAllowance);

        _burn(account, amount);

        return true;
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
