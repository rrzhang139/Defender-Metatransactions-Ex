require('dotenv').config();

require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");

task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});
// {
//   "MinimalForwarder": "0xeC73588880eA83152178844BC74819dce6AE6dd6",
//   "Registry": "0x4F73E2181605eEc40Bcc4ee8B7f2965E7eD745Db"
// }
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.3",
  networks: {
    local: {
      url: 'http://localhost:8545'
    },
    xdai: {
      url: 'https://dai.poa.network',
      accounts: [process.env.PRIVATE_KEY],
    },
    mumbai: {
      url: '',
      accounts: [process.env.PRIVATE_KEY],
    }
  }
};
