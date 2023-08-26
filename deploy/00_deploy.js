const hre = require("hardhat");
require("dotenv").config();

const { networkConfig } = require("../helper-hardhat-config");

const private_key = process.env.PRIVATE_KEY;
const wallet = new ethers.Wallet(private_key, ethers.provider);

module.exports = async ({ deployments }) => {
  // ethers is available in the global scope
  const [deployer] = await ethers.getSigners();
  console.log(
    "Deploying the contracts with the account:",
    await deployer.getAddress()
  );

  console.log(
    "Account balance:",
    (await deployer.provider.getBalance(deployer.address)).toString()
  );

  const accounts = await ethers.getSigners();
  //console.log(accounts[0])

  console.log("Wallet Ethereum Address:", wallet.address);
  const chainId = network.config.chainId;

  //deploy aggregator
  //   const Cid = "0x13653c684011cf94843636c490025489a6397673"
  const Cid = await ethers.getContractFactory("Cid", accounts[0]);
  console.log("Deploying Cid...");
  const cid = await Cid.deploy();
  await cid.deployed();
  console.log("Cid deployed to:", cid.address);

  //deploy aggregator
  const Proof = await ethers.getContractFactory("Proof", {
    libraries: {
      Cid: cid.address,
    },
  });
  console.log("Deploying Proof...");
  const proof = await Proof.deploy();
  await proof.deployed();
  console.log("Proof deployed to:", proof.address);

  //deploy aggregator
  const Aggregator = await ethers.getContractFactory("Aggregator", {
    libraries: {
      Cid: cid.address,
    },
  });
  console.log("Deploying aggregator...");
  const aggregator = await Aggregator.deploy();
  await aggregator.deployed();
  console.log("aggregator deployed to:", aggregator.address);
};
