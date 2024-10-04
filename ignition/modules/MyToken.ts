import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { config } from "../../configs/config";

const MyTokenModule = buildModule("MyTokenModule", (m) => {
  const owner = m.getParameter("owner", config.owner);
  const myToken = m.contract("MyToken", [owner]);

  return {
    myToken,
  };
});

export default MyTokenModule;
