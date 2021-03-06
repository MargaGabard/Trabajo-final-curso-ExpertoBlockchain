// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

/*
 * Ownable
 *
 * Base contract with an owner.
 * Provides onlyOwner modifier, which prevents function from running if it is called by anyone other than the owner.
 */
contract Ownable {
    address public owner;

    constructor()  {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender == owner)
            _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0),"Invalid address");
        owner = newOwner;
    }

   
}