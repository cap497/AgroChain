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

    struct Vaccination {
        string vaccineName;
        uint256 dateAdministered;
        string veterinarian;
        uint256 nextDueDate;
    }

    struct Treatment {
        string diagnosis;
        string medication;
        uint256 treatmentDate;
        string veterinarian;
    }

    struct Production {
        string productionType;
        uint256 amount;
        uint256 collectionDate;
    }

    struct Reproduction {
        uint256 partnerId;
        uint256 dateOfReproduction;
        uint256 offspringCount;
    }

    // Mapeamentos para dados do animal
    mapping(uint256 => Animal) private animais;
    mapping(uint256 => Vaccination[]) private vaccinationHistory;
    mapping(uint256 => Treatment[]) private treatmentHistory;
    mapping(uint256 => Production[]) private productionHistory;
    mapping(uint256 => Reproduction[]) private reproductionHistory;

    // Mapeamento de preços para compra
    mapping(uint256 => uint256) public precos;

    event AnimalVendido(address comprador, uint256 tokenId, uint256 preco);
    event CertificadoESGEmitido(uint256 tokenId);

    constructor() ERC721("AgroChainAnimal", "ACA") Ownable(msg.sender) {}

    // Função para criar um novo animal (NFT)
    function mintAnimal(
        string memory tokenURI,
        string memory nascimento,
        string memory fazenda,
        uint256 preco
    ) public onlyOwner {
        _tokenIdCounter++;
        uint256 newTokenId = _tokenIdCounter;

        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        animais[newTokenId] = Animal(newTokenId, nascimento, fazenda, "", false);
        precos[newTokenId] = preco;
    }

    // Função para atualizar movimentação do animal
    function atualizarMovimentacao(uint256 tokenId, string memory novaMovimentacao) public onlyOwner {
        require(isAnimalExistente(tokenId), "Token ID nao existe");
        animais[tokenId].movimentacao = novaMovimentacao;
    }

    // Função para emitir certificado ESG
    function emitirCertificadoESG(uint256 tokenId) public onlyOwner {
        require(isAnimalExistente(tokenId), "Token ID nao existe");
        require(!animais[tokenId].certificadoESG, "Certificado ESG ja emitido");

        animais[tokenId].certificadoESG = true;
        string memory certificadoURI = string(
            abi.encodePacked(tokenURI(tokenId), ", ESG: Certificado Emitido")
        );
        _setTokenURI(tokenId, certificadoURI);

        emit CertificadoESGEmitido(tokenId);
    }

    // Função para registrar vacinação
    function registrarVacinacao(
        uint256 tokenId,
        string memory vaccineName,
        uint256 dateAdministered,
        string memory veterinarian,
        uint256 nextDueDate
    ) public onlyOwner {
        require(isAnimalExistente(tokenId), "Token ID nao existe");
        vaccinationHistory[tokenId].push(Vaccination(vaccineName, dateAdministered, veterinarian, nextDueDate));
    }

    // Consultar histórico de vacinações
    function getHistoricoVacinacao(uint256 tokenId) public view returns (Vaccination[] memory) {
        require(isAnimalExistente(tokenId), "Token ID nao existe");
        return vaccinationHistory[tokenId];
    }

    // Função para registrar tratamento
    function registrarTratamento(
        uint256 tokenId,
        string memory diagnosis,
        string memory medication,
        uint256 treatmentDate,
        string memory veterinarian
    ) public onlyOwner {
        require(isAnimalExistente(tokenId), "Token ID nao existe");
        treatmentHistory[tokenId].push(Treatment(diagnosis, medication, treatmentDate, veterinarian));
    }

    // Consultar histórico de tratamentos
    function getHistoricoTratamento(uint256 tokenId) public view returns (Treatment[] memory) {
        require(isAnimalExistente(tokenId), "Token ID nao existe");
        return treatmentHistory[tokenId];
    }

    // Função para registrar produção
    function registrarProducao(
        uint256 tokenId,
        string memory productionType,
        uint256 amount,
        uint256 collectionDate
    ) public onlyOwner {
        require(isAnimalExistente(tokenId), "Token ID nao existe");
        productionHistory[tokenId].push(Production(productionType, amount, collectionDate));
    }

    // Consultar histórico de produção
    function getHistoricoProducao(uint256 tokenId) public view returns (Production[] memory) {
        require(isAnimalExistente(tokenId), "Token ID nao existe");
        return productionHistory[tokenId];
    }

    // Função para registrar reprodução
    function registrarReproducao(
        uint256 tokenId,
        uint256 partnerId,
        uint256 dateOfReproduction,
        uint256 offspringCount
    ) public onlyOwner {
        require(isAnimalExistente(tokenId), "Token ID nao existe");
        require(isAnimalExistente(partnerId), "Partner ID nao existe");
        reproductionHistory[tokenId].push(Reproduction(partnerId, dateOfReproduction, offspringCount));
    }

    // Consultar histórico de reprodução
    function getHistoricoReproducao(uint256 tokenId) public view returns (Reproduction[] memory) {
        require(isAnimalExistente(tokenId), "Token ID nao existe");
        return reproductionHistory[tokenId];
    }

    // Verifica se o animal existe
    function isAnimalExistente(uint256 tokenId) internal view returns (bool) {
        return animais[tokenId].id != 0;
    }

    // Consultar dados do animal
    function consultarAnimal(uint256 tokenId) public view returns (Animal memory) {
        require(isAnimalExistente(tokenId), "Token ID nao existe");
        return animais[tokenId];
    }

    // Comprar um animal
    function comprarAnimal(uint256 tokenId) public payable {
        require(isAnimalExistente(tokenId), "Token ID nao existe");
        require(msg.value >= precos[tokenId], "Valor insuficiente para compra");

        address vendedor = ownerOf(tokenId);
        _transfer(vendedor, msg.sender, tokenId);
        payable(vendedor).transfer(msg.value);

        emit AnimalVendido(msg.sender, tokenId, msg.value);
    }
}
