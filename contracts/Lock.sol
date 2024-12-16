//SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
    @title ERC20Token
    @dev A simple ERC20 token with a inital supply of 1 million tokens minted to the deployer's address
*/

contract ERC20Token is ERC20{
/**
    @dev Constructor that gives the deployer 1 Million Tokens on deployment.
    @param name the name of the token.
    @param symbol the symbol of the token.
*/

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1000000 * 10 ** decimals()); //Mint 1 million tokens to the deployer address.
    }
}
