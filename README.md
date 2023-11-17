
# **Technical Documentation for FathomProxyWalletOwnerUpgradeable Smart Contract**
As of Nov 16th 2023

![FXD_programmable_money](FXD_programmable_money.webp)

## Overview
The FathomProxyWalletOwnerUpgradeable contract is designed for interaction with the Fathom stablecoin protocol on the XDC blockchain. It facilitates the management of collateralized debt positions using FXD, the protocol's native stablecoin. The contract includes functionalities for opening and closing positions, managing FXD stablecoins, and handling collateral in XDC.
## Contract Details
Pragma Solidity: 0.8.17 (Same as FXD contracts)<br>
License: MIT<br>
Inheritance: Inherits from OwnableUpgradeable from OpenZeppelin's contracts-upgradeable library. "^4.7.3"<br>

## How to use the contract

Below interface include the setter/getter fns to communicate with ProxyWalletOwner contract. You can use below interface in remix to communicate with the deployed contract easily.

```.sol
// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.17;

interface IFathomProxyWalletOwner {

    struct List {
        uint256 prev;
        uint256 next;
    }
    
    struct Position {
        uint256 lockedCollateral; // Locked collateral inside this position (used for minting)                  [wad]
        uint256 debtShare; // The debt share of this position or the share amount of minted Fathom Stablecoin   [wad]
    }
    
    function openPosition(uint256 _stablecoinAmount) external payable;
    
    function closePositionPartial(
        uint256 _positionId,
        uint256 _collateralAmount,
        uint256 _stablecoinAmount
    ) external;
    
    function closePositionFull(
        uint256 _positionId
    ) external;
    
    function withdrawStablecoin() external;
    
    function withdrawXDC() external;
    
    function proxyWalletRegistry() external view returns(address);

    function proxyWallet() external view returns (address);

    function buildProxyWallet() external returns (address payable);

    // mapping(uint256 => List) public list;
    function list(uint256 _positionId) external view returns (List memory list);

    // mapping(address => uint256) public ownerFirstPositionId;
    function ownerFirstPositionId() external view returns (uint256 positionId);

    // mapping(address => uint256) public ownerLastPositionId;
    function ownerLastPositionId() external view returns (uint256 positionId);

    // mapping(address => uint256) public ownerPositionCount;

    function ownerPositionCount() external view returns (uint256 positionCount);

    function getActualFXDToRepay(
        uint256 _positionId
    ) external view returns (uint256);
    
    function getDebtAccumulatedRate() external view returns (uint256);
    
    function getPositionAddress(
        uint256 _positionId
    ) external view returns (address positionAddress);

    function positions(
        uint256 _positionId
    ) external view returns (Position memory position);

    function owner() external view returns (address);
}

```


### 1. Create ProxyWallet

ProxyWallet is an entry point to the fathom protocol. Any address, whether it is an EOA or a contract address, must create a helper contract called *ProxyWallet*, and then via the ProxyWallet, user can open to borrow FXD and close positions to get the collateral back.<br>


to make a ProxyWallet, call
```.sol
    function buildProxyWallet() external returns (address payable);
```

then proxyWallet for the FathomProxyWalletOwner contract will be created. You can check the proxyWallet address with the getter function below.

```.sol
    function proxyWallet() external view returns (address);
```

### 2. Open a position

Once you have the proxyWallet created, you can open a position using the fn below. 

```.sol
    function openPosition(uint256 _stablecoinAmount) external payable;
```

You must call the fn above with some amount of msg.value. The amount of XDC you send when calling the function above will be collateralized. And _stablecoinAmount which is the amount of FXD to borrow needs to be in the wei unit(10^18). If you wish to collateralize 800 XDC and borrow 15 FXD, send 800 XDC while calling openPosition fn with arg of 15000000000000000000. <br>

Once your tx successfully goes through, then the owner/deployer of the ProxyWalletOwner contract will receive FXD. Try to check the position information. 

### 3. Check position info

You can check the first positionId that the proxyWalletOwner contract created with ownerFirstPositionId. <br>

```.sol
    // mapping(address => uint256) public ownerFirstPositionId;
    function ownerFirstPositionId() external view returns (uint256 positionId);
```

You can check the last positionId  that the proxyWalletOwner contract created with ownerLastPositionId. <br>

```.sol
    // mapping(address => uint256) public ownerLastPositionId;
    function ownerLastPositionId() external view returns (uint256 positionId);
```

You can check the number of positions created from proxyWalletOwner contract by calling

```.sol
    // mapping(address => uint256) public ownerPositionCount;

    function ownerPositionCount() external view returns (uint256 positionCount);
```

You can check how much collateral was locked and debt is to be repaid by calling

```.sol
    function positions(
        uint256 _positionId
    ) external view returns (Position memory position);
```

Please note that the debtShare that is returned from the above function does not represent how much FXD needs to be paid to fully close the position. To get more precise calculation on how much FXD needs to be paid back to fully close the position, please call below fn.

```.sol
    function getActualFXDToRepay(
        uint256 _positionId
    ) external view returns (uint256);
```

You can check the the previous and the next positions, given a positionId made by the proxyWalletOwner with the below function.
```.sol
    // mapping(uint256 => List) public list;
    function list(uint256 _positionId) external view returns (List memory list);
```
For example, if 3 positions are created; 181, 183, 199. Calling list() fn with arg of 181 will return 0, 183. Meaning there was no position made prior to 181, and also the next position made for was positionId 183. list(183) will return 181, 199. And list(199) will return 183,0 since it is the last position.

### 4. Closing positions

There are two ways to close positions. Fully and partially. <br>

#### Position full closure
Fully closing a position means that you pay back all the debt borrowed from the position and get all the lockedCollateral back from the position.<br>
Please transfer FXD to proxyWalletOwner, so that the FXD will be used to close a position.<br>
Once it is certain that there is enough FXD to close a position, please call fn below.

```.sol
    function closePositionFull(
        uint256 _positionId
    ) external;
```

#### Position partial closure

Partially closing a position means that you pay back part of the debt borrowed from the position and get part of the lockedCollateral back from the position.<br>
Please transfer FXD to proxyWalletOwner, so that the FXD will be used to partially close a position.<br>
Once it is certain that there is enough FXD to partially close a position, please call fn below.

```.sol
    function closePositionPartial(
        uint256 _positionId,
        uint256 _collateralAmount,
        uint256 _stablecoinAmount
    ) external;
```


_collateralAmount and _stablecoinAmount are in unit of Wei(10^18). When closing a position partially, the value of collateral and value of debt in a position should stay balanced so that the position is not under the water.

## Key Components
### State Variables:
proxyWalletRegistry, bookKeeper, collateralPoolConfig, stablecoinAddress, positionManager, stabilityFeeCollector, collateralTokenAdapter, stablecoinAdapter, proxyWallet: Addresses of various components of the Fathom protocol.
Collateral_pool_id: Identifier for the collateral pool. From the string of ‘XDC’, padded to fit bytes32.
RAY: A constant used for precision in calculations, set to 10^27
### Events:
OpenPosition, ClosePosition, WithdrawStablecoin, WithdrawXDC, Received: Events for logging contract activities.
### Functions
**initialize()**: Initializes the contract with necessary parameters and addresses. This is the contract's constructor equivalent in an upgradeable contract pattern.
#### Position Management Functions:
**ownerFirstPositionId()**, **ownerLastPositionId()**, **ownerPositionCount()**: Functions to query position IDs and count associated with the owner's proxy wallet.<br>
**getActualFXDToRepay(uint256 _positionId)**: Calculates the actual FXD amount to repay for a given position. It calculates debtValue which is the product of debtAccumulateRate of a certain collateral type and debtShare of a certain position.<br>
**getDebtAccumulatedRate()**: Retrieves the current debt accumulated rate for the collateral pool.<br>
**getPositionAddress(uint256 _positionId)**: Gets the address associated with a specific position. <br>
**positions(uint256 _positionId)**: Returns position data for a given position ID. It returns lockedCollateral amount and debtShare.<br>
**list(uint256 _positionId)**: Lists the details of a position. by showing previous and the next position that the proxyWalletOwner contract owns. It is a linked list. For example, if 3 positions are created; 181, 183, 199. Calling list() fn with arg of 181 will return 0, 183. Meaning there was no position made prior to 181, and also the next position made for was positionId 183. list(183) will return 181, 199. And list(199) will return 183,0 since it is the last position.<br>
#### Proxy Wallet Functions:
FXD balance must be provided to the FathomProxyWalletOwnerUpgradeable before calling any position closure functions.
**buildProxyWallet()**: Builds a new proxy wallet which is the entry point to Fathom protocol.<br>
**openPosition(uint256 _stablecoinAmount)**: Opens a new position by locking XDC and drawing FXD.<br>
**closePositionPartial(uint256 _positionId, uint256 _collateralAmount, uint256 _stablecoinAmount)**: Partially closes a position to partially close. athomProxyWalletOwnerUpgradeable must have enough FXD balance to close the position partially.<br>
**closePositionFull(uint256 _positionId)**: Fully closes a position. FathomProxyWalletOwnerUpgradeable must have enough FXD balance to close the whole position.<br>
#### Withdrawal Functions:
**withdrawStablecoin()**: Withdraws FXD stablecoins to the contract owner.<br>
**withdrawXDC()**: Withdraws XDC to the contract owner.
#### Internal Utility Functions:
**_validateAddress(address _address)**: Validates that an address is not the zero address.<br>
**_validateUint(uint256 _uintValue)**: Validates that a uint256 is not zero.<br>
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

#### To deploy non-upgradeable version of the contract, please run 
```cli
$ npx hardhat deploy --tags ApothemDeployment --network apothem --reset
```

#### The address of the deployed contract will be logged in the console.
```cli
$ npx hardhat deploy --tags UpgradeApothem --network apothem --reset
```
The addresses of the implementation, proxyAdmin, proxy will be logged in the console. Communicate with the proxy to use the contract, not the implementation nor the proxyAdmin.


## Possible use cases of the SDK contract

0) Tokenized positions when inherited to ERC721. It would be possible to tokenize a multiple FXD positions if the SDK contract will be inherited to an ERC721. Then the owner of the ERC721 contract will be the owner of the positions created via FathomProxyWalletOwner(which is the NFT itself). If you transfer an NFT, you transfer the ownership of a basket of FXD positions.

1) Onchain investment fund when inherited to ERC4626 and DAO contracts. It would be possible to distribute ownership of the tokenized FXD positions and also the profit generated from the borrowed FXD. Distribution of ownership with ERC4626 and community based investment decision making can be done by DAO contract.

## Conclusion
This contract acts as a gateway for easy and efficient interaction with the Fathom stablecoin protocol, enabling users to manage collateralized debt positions with FXD stablecoins on the XDC chain.


