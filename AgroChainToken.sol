// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AgroChainToken is ERC20, Ownable {
    uint256 public precoPorToken = 0.001 ether; // 1 GCT = 0.001 ETH

    constructor() ERC20("GreenCreditToken", "GCT") Ownable(msg.sender) {
        _mint(msg.sender, 1000000 * 10**decimals()); // Mint inicial para o administrador
    }

    function comprarCredito(uint256 quantidade) public payable {
        require(balanceOf(owner()) >= quantidade, "Admin nao tem credito suficiente");
        require(msg.value >= quantidade * precoPorToken, "Valor insuficiente");
        _transfer(owner(), msg.sender, quantidade);
    }

    function venderCredito(uint256 quantidade) public {
        require(balanceOf(msg.sender) >= quantidade, "Saldo insuficiente");
        _transfer(msg.sender, owner(), quantidade);
        payable(msg.sender).transfer(quantidade * precoPorToken);
    }

    function queimarTokens(uint256 quantidade) public onlyOwner {
        _burn(owner(), quantidade);
    }

    function setPrecoPorToken(uint256 novoPreco) public onlyOwner {
        precoPorToken = novoPreco;
    }
}