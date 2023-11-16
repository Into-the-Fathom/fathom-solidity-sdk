const hre = require("hardhat");
const fs = require('fs');
const path = require('path');

async function main() {
  const initialDeposit = hre.ethers.parseEther("100");

  // Get the list of accounts
  const accounts = await hre.ethers.getSigners();

  // Read addresses from JSON file
  const addressesPath = path.join(__dirname, '../addressesProd.json');
  const addresses = JSON.parse(fs.readFileSync(addressesPath, 'utf8'));

  const FathomProxyWalletOwner = await hre.ethers.getContractFactory("FathomProxyWalletOwner");
  const fathomProxyWalletOwner = await FathomProxyWalletOwner.deploy(
    addresses.ProxyWalletRegistry,
    addresses.BookKeeper,
    addresses.CollateralPoolConfig,
    addresses.FXDAddress,
    addresses.PositionManager,
    addresses.StabilityFeeCollector,
    addresses.CollateralTokenAdapter,
    addresses.StablecoinAdapter,
    addresses.collateral_pool_id,
    {
      // value: initialDeposit, // Uncomment if needed
    }
  );

  await fathomProxyWalletOwner.waitForDeployment();

  console.log("fathomProxyWalletOwner deployed with address " + fathomProxyWalletOwner.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
