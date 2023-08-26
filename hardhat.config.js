require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require("hardhat-deploy-ethers");
require("dotenv").config();
require("@starboardventures/hardhat-verify");

const PRIVATE_KEY = process.env.PRIVATE_KEY;
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
        details: { yul: false },
      },
    },
  },
  starboardConfig: {
    baseURL: "https://fvm-calibration-api.starboard.ventures",
    network: "Calibration", // if there's no baseURL, url will depend on the network.  Mainnet || Calibration
  },
  defaultNetwork: "calibrationnet",
  networks: {
    hardhat: {
      gas: 12000000,
      blockGasLimit: 0x1fffffffffffff,
      gasLimit: 5000000000,
      allowUnlimitedContractSize: true,
      timeout: 1800000,
    },
    localnet: {
      chainId: 31415926,
      url: "http://127.0.0.1:1234/rpc/v1",
      accounts: [PRIVATE_KEY],
    },
    calibrationnet: {
      chainId: 314159,
      url: "https://api.calibration.node.glif.io/rpc/v1",
      accounts: [PRIVATE_KEY],
    },
    filecoinmainnet: {
      chainId: 314,
      url: "https://api.node.glif.io",
      accounts: [PRIVATE_KEY],
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./tests",
    cache: "./cache",
    artifacts: "./artifacts",
  },
};
