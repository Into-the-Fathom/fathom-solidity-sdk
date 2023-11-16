const hre = require("hardhat");
const fs = require('fs');
const path = require('path');

module.exports = async () => {
  const { deploy } = hre.deployments;
  const [signer] = await ethers.getSigners();
  const { deployer } = await hre.getNamedAccounts();

  // Read addresses from JSON file
  const addressesPath = path.join(__dirname, '../addressesDev.json');
  const addresses = JSON.parse(fs.readFileSync(addressesPath, 'utf8'));

  const fathomProxyWalletOwner = await deploy('FathomProxyWalletOwnerUpgradeable', {
    from: deployer,
    args: [],
    log: true,
  });

  console.log("fathomProxyWalletOwner implementation deployed to:", fathomProxyWalletOwner.address);

  const walletOwnerProxyAdmin = await deploy('WalletOwnerProxyAdmin', {
    from: deployer,
    args: [],
    log: true,
  });

  console.log("walletOwnerProxyAdmin deployed to:", walletOwnerProxyAdmin.address);

  const walletOwnerProxy = await deploy('WalletOwnerProxy', {
    from: deployer,
    args: [fathomProxyWalletOwner.address, walletOwnerProxyAdmin.address, "0x"],
    log: true,
  });

  console.log("walletOwnerProxy deployed to:", walletOwnerProxy.address);

  const initializeAbi = [
    "function initialize(address _proxyWalletRegistry, address _bookKeeper, address _collateralPoolConfig, address _stablecoinAddress, address _positionManager, address _stabilityFeeCollector, address _collateralTokenAdapter, address _stablecoinAdapter, bytes32 _collateral_pool_id)"
  ];
  const contractInterfaceInit = new hre.ethers.Interface(initializeAbi);

  const dataInit = contractInterfaceInit.encodeFunctionData('initialize', [
    addresses.ProxyWalletRegistry,
    addresses.BookKeeper,
    addresses.CollateralPoolConfig,
    addresses.FXDAddress,
    addresses.PositionManager,
    addresses.StabilityFeeCollector,
    addresses.CollateralTokenAdapter,
    addresses.StablecoinAdapter,
    addresses.collateral_pool_id
  ]);

  await signer.sendTransaction({
    to: walletOwnerProxy.address,
    value: ethers.parseEther('0.0'),
    gasLimit: 1000000,
    gasPrice: ethers.parseUnits('15.0', 'gwei'),
    data: dataInit,
  });
};

module.exports.tags = ["UpgradeApothem"];
