import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { config } from "../../configs/config";

const ETHStakingModule = buildModule("ETHStakingModule", (m) => {
  const admin = m.getParameter("owner", config.owner);
  const annualInterestPercent = m.getParameter("annualInterestPercent", 10);
  const maxDuration = m.getParameter("maxDuration", 365);

  const EthStaking = m.contract("ETHStaking", [
    annualInterestPercent,
    maxDuration,
    admin,
  ]);

  return {
    EthStaking,
  };
});

export default ETHStakingModule;

