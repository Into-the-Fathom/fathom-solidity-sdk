
# **Technical Documentation for FathomProxyWalletOwnerUpgradeable Smart Contract**
As of Nov 16th 2023

![Alt text](FXD_programmable_money.webp)

## Overview
The FathomProxyWalletOwnerUpgradeable contract is designed for interaction with the Fathom stablecoin protocol on the XDC blockchain. It facilitates the management of collateralized debt positions using FXD, the protocol's native stablecoin. The contract includes functionalities for opening and closing positions, managing FXD stablecoins, and handling collateral in XDC.
## Contract Details
Pragma Solidity: 0.8.17 (Same as FXD contracts)
License: MIT
Inheritance: Inherits from OwnableUpgradeable from OpenZeppelin's contracts-upgradeable library. "^4.7.3"

## Key Components
### State Variables:
ProxyWalletRegistry, BookKeeper, CollateralPoolConfig, StablecoinAddress, PositionManager, StabilityFeeCollector, CollateralTokenAdapter, StablecoinAdapter, ProxyWallet: Addresses of various components of the Fathom protocol.
Collateral_pool_id: Identifier for the collateral pool. From the string of ‘XDC’, padded to fit bytes32.
RAY: A constant used for precision in calculations, set to 10^27
### Events:
OpenPosition, ClosePosition, WithdrawStablecoin, WithdrawXDC, Received: Events for logging contract activities.
### Functions
**initialize()**: Initializes the contract with necessary parameters and addresses. This is the contract's constructor equivalent in an upgradeable contract pattern.
#### Position Management Functions:
**ownerFirstPositionId()**, **ownerLastPositionId()**, **ownerPositionCount()**: Functions to query position IDs and count associated with the owner's proxy wallet.
**getActualFXDToRepay(uint256 _positionId)**: Calculates the actual FXD amount to repay for a given position. It calculates debtValue which is the product of debtAccumulateRate of a certain collateral type and debtShare of a certain position.
**getDebtAccumulatedRate()**: Retrieves the current debt accumulated rate for the collateral pool.
**getPositionAddress(uint256 _positionId)**: Gets the address associated with a specific position. 
**positions(uint256 _positionId)**: Returns position data for a given position ID. It returns lockedCollateral amount and debtShare.
**list(uint256 _positionId)**: Lists the details of a position. by showing previous and the next position that the proxyWalletOwner contract owns. It is a linked list. For example, if 3 positions are created; 181, 183, 199. Calling list() fn with arg of 181 will return 0, 183. Meaning there was no position made prior to 181, and also the next position made for was positionId 183. list(183) will return 181, 199. And list(199) will return 183,0 since it is the last position.
#### Proxy Wallet Functions:
FXD balance must be provided to the FathomProxyWalletOwnerUpgradeable before calling any position closure functions.
**buildProxyWallet()**: Builds a new proxy wallet which is the entry point to Fathom protocol.
**openPosition(uint256 _stablecoinAmount)**: Opens a new position by locking XDC and drawing FXD.
**closePositionPartial(uint256 _positionId, uint256 _collateralAmount, uint256 _stablecoinAmount)**: Partially closes a position to partially close. athomProxyWalletOwnerUpgradeable must have enough FXD to close the position partially.
**closePositionFull(uint256 _positionId)**: Fully closes a position. FathomProxyWalletOwnerUpgradeable must have enough FXD to close the whole position.
#### Withdrawal Functions:
**withdrawStablecoin()**: Withdraws FXD stablecoins to the contract owner.
**withdrawXDC()**: Withdraws XDC to the contract owner.
#### Internal Utility Functions:
**_validateAddress(address _address)**: Validates that an address is not the zero address.
**_validateUint(uint256 _uintValue)**: Validates that a uint256 is not zero.
**_successfullXDCTransfer(bool _sent)**: Ensures successful transfer of XDC.
#### Fallback Function:
**receive()**: Allows the contract to receive XDC and emits the Received event.
### Error Handling
Custom errors (InvalidAddress, InvalidUint, EtherTransferFailed, PositionAlreadyClosed) are defined to handle specific erroneous situations, providing clear and gas-efficient error messages.
## Usage Instructions
To interact with this contract for testing purposes, deploy it on the XDCForked hardhat node or apothem.

### Deployment prep

First, create an .env file and fill the content like below. .env file is used to keep the privateKeys.
```.env
mainnetDeployer=Private-Key-without-0x-prefix
apothemDeployer=Private-Key-without-0x-prefix
localhostDeployer=Private-Key-without-0x-prefix
```

localhostDeployer is recommended to be the PK of hardhat node's first account, if you wish to test the contract locally.

Second, make sure that compilation works by running compilation command below

```cli
$ npx hardhat compile
```

### Deployment on XDCForked hardhat node

Since current hardhat project uses hardhat-deploy plugin for smooth deployment on apothem, running hardhat node will automatically run all the deployment scripts in deploy folder. If you wish to focus on hardhat node testing, please empty the folder or rename deploy to other names.

First, run XDCForked hardhat node with below command

```cli
$ npx hardhat node
```

Second, run XDCForked hardhat node with below command

```cli
$ make transferOwnership
```

The above script transfers ownership of the Fathom protocol to the first account of hardhat node and makes sure that the protocol gets decentralized, meaning anyone can open positions.

Third, deploy contracts to hardhat node.

below command will deploy the non-upgradeable version of the contract.

```cli
$ npx hardhat run --network localhost scripts/deploy.js
```

below command will deploy the upgradeable version of the contract.

```cli
npx hardhat run --network localhost scripts/deploy_upgradeable.js
```

unfortunately, logging of the deployed contracts do not work well with XDCforked hardhat node. Please carefully observe the hardhat node's console. The first contract that's deployed will be the implementation and it will be obvious since the contract name will be shown. The next contract deployed after the implementation will be ProxyAdmin. And the last contract will be the Proxy contract. To communicate with the upgradeable version, please communicate with the Proxy contract.


### Deployment on apothem

To deploy non-upgradeable version of the contract, please run 
```cli
$ npx hardhat deploy --tags ApothemDeployment --network apothem --reset
```

To deploy upgradeable version of the contract, please run 
```cli
$ npx hardhat deploy --tags UpgradeApothem --network apothem --reset
```


## Conclusion
This contract acts as a gateway for easy and efficient interaction with the Fathom stablecoin protocol, enabling users to manage collateralized debt positions with FXD stablecoins on the XDC chain.

