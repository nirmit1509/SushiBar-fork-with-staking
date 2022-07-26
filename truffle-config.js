// Import HDWalletProvider
const HDWalletProvider = require("@truffle/hdwallet-provider");

// Create a file named '.secret' in this sub-directory and store mnemonic in that file
const fs = require("fs");
const MNEMONIC = fs.readFileSync(".secret").toString().trim();

const path = require("path");
require("dotenv").config();

module.exports = {
  networks: {
    local: {
      host: "127.0.0.1",
      port: 8545,
      gas: 6000000,
      network_id: "*", // Match any network id
    },
    mumbai: {
      provider: () => new HDWalletProvider(MNEMONIC, process.env.mumbaiRPC),
      network_id: 80001,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true,
      gas: 6000000,
      gasPrice: 10000000000,
    },
  },
  compilers: {
    solc: {
      version: "0.8.9",
      settings: {
        optimizer: {
          enabled: true,
          runs: 1500,
        },
      },
    },
  },
  plugins: ["truffle-plugin-verify"],
  api_keys: {
    polygonscan: process.env.POLYGONSCAN_API_KEY,
    etherscan: process.env.ETHERSCAN_API_KEY,
  },
};
