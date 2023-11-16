const hre = require("hardhat");
const fs = require('fs');
const path = require('path');

module.exports = async () => {
  const { deploy } = hre.deployments;
  const { deployer } = await hre.getNamedAccounts();

  // Read addresses from JSON file
  const addressesPath = path.join(__dirname, '../addressesDev.json');
  const addresses = JSON.parse(fs.readFileSync(addressesPath, 'utf8'));

  const fathomProxyWalletOwner = await deploy('FathomProxyWalletOwner', {
    from: deployer,
    args: [
      addresses.ProxyWalletRegistry,
      addresses.BookKeeper,
      addresses.CollateralPoolConfig,
      addresses.FXDAddress,
      addresses.PositionManager,
      addresses.StabilityFeeCollector,
      addresses.CollateralTokenAdapter,
      addresses.StablecoinAdapter,
      addresses.collateral_pool_id
    ],
    log: true,
  });

  console.log("fathomProxyWalletOwner deployed to:", fathomProxyWalletOwner.address);
};

module.exports.tags = ["ApothemDeployment"];
