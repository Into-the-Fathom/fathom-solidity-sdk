require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-ethers");
require('dotenv').config();
require('hardhat-deploy');
require('@openzeppelin/hardhat-upgrades');


/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200 // You can adjust the number of runs as needed
      }
    }
  },
  networks: {
    hardhat: {
      accounts: {
        // 1 million ETH in wei
        count: 3,
        initialBalance: '1000000000000000000000000',
      },
      forking: {
        url: "https://earpc.xinfin.network"
        // url: "https://erpc.xdcrpc.com",
        // url: "https://erpc.xinfin.network",
      }
    },
    mainnet: {
      url: "https://erpc.xinfin.network",
      // url: "https://erpc.xdcrpc.com	",

      accounts: [`0x${process.env.mainnetDeployer}`]
    },
    apothem: {
      // url: "https://apothem.xdcrpc.com",
      // url: "https://rpc.apothem.network",
      url: "https://erpc.apothem.network",
      // accounts: [`0x${process.env.apothemDeployer}`]
      accounts: [process.env.apothemDeployer]
    }
  },
  namedAccounts: {
    deployer: {
      default: 0, // Use the first account by default
    },
  },
};
