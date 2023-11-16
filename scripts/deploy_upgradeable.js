const hre = require("hardhat");
const fs = require('fs');
const path = require('path');
const { ethers, upgrades } = hre;

async function main() {
  // Read addresses from JSON file
  const addressesPath = path.join(__dirname, '../addressesProd.json');
  const addresses = JSON.parse(fs.readFileSync(addressesPath, 'utf8'));

  const FathomProxyWalletOwner = await ethers.getContractFactory("FathomProxyWalletOwnerUpgradeable");

  const fathomProxyWalletOwner = await upgrades.deployProxy(
    FathomProxyWalletOwner,
    [
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
    { initializer: 'initialize' }
  );

  console.log("fathomProxyWalletOwner deployed at:", fathomProxyWalletOwner.address);

  const implementationAddress = await upgrades.erc1967.getImplementationAddress(fathomProxyWalletOwner.address);
  console.log("Implementation address:", implementationAddress);

  const proxyAdminAddress = await upgrades.admin.getInstance();
  console.log("ProxyAdmin address:", proxyAdminAddress);

  //then first implementation, proxyAdmin and proxy addresses show up in the hardhat node log.

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});



