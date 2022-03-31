// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FumToken is ERC20 {


    constructor() ERC20("FumToken", "FUM")  {
      super._mint(msg.sender, 5000000 * 10 ** decimals());
     
    }

    function mint(address to, uint256 amount) public  {
        super._mint(to, amount);
    }

}


