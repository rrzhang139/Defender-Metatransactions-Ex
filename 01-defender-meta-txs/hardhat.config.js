require('dotenv').config();

require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");

task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.0"
      },
      {
        version: "0.7.4"
      }
    ]
  },
  defaultNetwork: "rinkeby",
  networks: {
    local: {
      url: 'http://localhost:8545'
    },
    // xdai: {
    //   url: 'https://dai.poa.network',
    //   accounts: [process.env.PRIVATE_KEY],
    // },
    rinkeby: {
      url: "[ENTER API URL]",
      accounts: [process.env.PRIVATE_KEY],
      gas: 2100000,
      gasPrice: 8000000000
    },
    mumbai: {
      url: "",
      accounts: [process.env.PRIVATE_KEY],
      gas: 2100000,
      gasPrice: 8000000000
    }
  }
};
