const Web3 = require("web3");
const web3 = new Web3(Web3.givenProvider);

const nftContractAddress = "<ENDERECO_CONTRATO_NFT>";
const tokenContractAddress = "<ENDERECO_CONTRATO_TOKEN>";

const nftAbi = [/* ABI do contrato NFT */];
const tokenAbi = [/* ABI do contrato Token */];

const nftContract = new web3.eth.Contract(nftAbi, nftContractAddress);
const tokenContract = new web3.eth.Contract(tokenAbi, tokenContractAddress);

async function mintAnimal() {
  const accounts = await web3.eth.requestAccounts();
  await nftContract.methods
    .mintAnimal("https://metadata.json", "2025-01-01", "Fazenda Teste", 1000)
    .send({ from: accounts[0] });
}

async function comprarCredito() {
  const accounts = await web3.eth.requestAccounts();
  await tokenContract.methods
    .comprarCredito(10)
    .send({ from: accounts[0] });
}
