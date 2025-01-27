// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AgroChainToken is ERC20, Ownable {
    constructor() ERC20("GreenCreditToken", "GCT") Ownable(msg.sender) {
        _mint(msg.sender, 1000000 * 10**decimals()); // Mint inicial para o administrador
    }

    function comprarCredito(uint256 quantidade) public {
        require(balanceOf(owner()) >= quantidade, "Admin nao tem credito suficiente");
        _transfer(owner(), msg.sender, quantidade);
    }

    function venderCredito(uint256 quantidade) public {
        require(balanceOf(msg.sender) >= quantidade, "Saldo insuficiente");
        _transfer(msg.sender, owner(), quantidade);
    }
}
