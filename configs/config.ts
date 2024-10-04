import { vars } from "hardhat/config"

const PRIVATE_KEY = vars.get("PRIVATE_KEY");
const LISK_SEPOLIA_RPC_URL = vars.get("LISK_SEPOLIA_RPC_URL");
const OWNER = vars.get("OWNER");

export const  config = {
    privateKey: PRIVATE_KEY,
    liskSepoliaRpcUrl:  LISK_SEPOLIA_RPC_URL,
    owner: OWNER,
    myToken: "0x7ddBaF96e3E076f747C48Be1863320CAb7E5F478"
}