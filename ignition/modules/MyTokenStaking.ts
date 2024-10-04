import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { config } from "../../configs/config";

const MyTokenStakingModule = buildModule("MyTokenStakingModule", (m) => {
  const admin = m.getParameter("owner", config.owner);
  const annualInterestPercent = m.getParameter("annualInterestPercent", 10);
  const maxDuration = m.getParameter("maxDuration", 365);

  const myTokenStaking = m.contract("MyTokenStaking", [config.myToken, annualInterestPercent, maxDuration, admin]);

  return {
    myTokenStaking,
  };
});

export default MyTokenStakingModule;