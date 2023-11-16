notUpgradeable:
	npx hardhat run --network localhost scripts/deploy.js
upgradeable:
	npx hardhat run --network localhost scripts/deploy_upgradeable.js
apothem:
	npx hardhat deploy --tags ApothemDeployment --network apothem --reset
upgradeApothem:
	npx hardhat deploy --tags UpgradeApothem --network apothem --reset
transferOwnership:
	npx hardhat run --network localhost scripts/setup/1_a_decentOn.js
	npx hardhat run --network localhost scripts/setup/1_b_transfer_proxyAdminOwnership.js
	npx hardhat run --network localhost scripts/setup/1_c_grantRole.js
node:
	npx hardhat node