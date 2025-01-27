// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AgroChainNFT is ERC721URIStorage, Ownable {
    uint256 private _tokenIdCounter;

    struct Animal {
        uint256 id;
        string nascimento;
        string fazenda;
        string movimentacao;
        bool certificadoESG;
    }

    mapping(uint256 => Animal) private animais;
    mapping(uint256 => uint256) public precos;

    event AnimalVendido(address comprador, uint256 tokenId, uint256 preco);
    event CertificadoESGEmitido(uint256 tokenId);

    // Construtor corrigido: Inicializa `Ownable` com o deployer como `initialOwner`
    constructor() ERC721("AgroChainAnimal", "ACA") Ownable(msg.sender) {}

    function mintAnimal(
        string memory tokenURI,
        string memory nascimento,
        string memory fazenda,
        uint256 preco
    ) public onlyOwner {
        _tokenIdCounter++;
        uint256 newTokenId = _tokenIdCounter;

        // Cria o NFT
        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        // Registra os dados do animal
        animais[newTokenId] = Animal(newTokenId, nascimento, fazenda, "", false);
        precos[newTokenId] = preco;
    }

    function atualizarMovimentacao(uint256 tokenId, string memory novaMovimentacao) public onlyOwner {
        require(ownerOf(tokenId) != address(0), "Token ID nao existe");
        animais[tokenId].movimentacao = novaMovimentacao;
    }

    function emitirCertificadoESG(uint256 tokenId) public onlyOwner {
        require(ownerOf(tokenId) != address(0), "Token ID nao existe");
        require(!animais[tokenId].certificadoESG, "Certificado ESG ja emitido");

        // Atualiza os dados do animal e os metadados do token
        animais[tokenId].certificadoESG = true;
        string memory certificadoURI = string(
            abi.encodePacked(tokenURI(tokenId), ", ESG: Certificado Emitido")
        );
        _setTokenURI(tokenId, certificadoURI);

        emit CertificadoESGEmitido(tokenId);
    }

    function comprarAnimal(uint256 tokenId) public payable {
        require(ownerOf(tokenId) != address(0), "Token ID nao existe");
        require(msg.value >= precos[tokenId], "Valor insuficiente para compra");

        address vendedor = ownerOf(tokenId);
        _transfer(vendedor, msg.sender, tokenId);
        payable(vendedor).transfer(msg.value);

        emit AnimalVendido(msg.sender, tokenId, msg.value);
    }

    function consultarAnimal(uint256 tokenId) public view returns (Animal memory) {
        require(ownerOf(tokenId) != address(0), "Token ID nao existe");
        return animais[tokenId];
    }
}
