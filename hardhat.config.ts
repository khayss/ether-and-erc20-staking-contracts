import { HardhatUserConfig, vars } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

// const LISK_SEPOLIA_RPC_URL = vars.get("LISK_SEPOLIA_RPC_URL");
const PRIVATE_KEY = vars.get("PRIVATE_KEY");

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  networks: {
    liskSepolia: {
      accounts: [PRIVATE_KEY],
      url: "https://rpc.sepolia-api.lisk.com",
    },
  },
  etherscan: {
    apiKey: {
      "lisk-sepolia": "empty",
    },
    customChains: [
      {
        network: "lisk-sepolia",
        chainId: 4202,
        urls: {
          apiURL: "https://sepolia-blockscout.lisk.com/api",
          browserURL: "https://sepolia-blockscout.lisk.com",
        },
      },
    ],
  },
};

export default config;
