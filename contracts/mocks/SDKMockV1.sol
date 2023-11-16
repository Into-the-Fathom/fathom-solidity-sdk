// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../interfaces/IProxyWalletRegistry.sol";

contract SDKMockV1 {
    //the goal here is to just open a position - V1
    //next step is to try to borrow. - V2
    //next step is to try to pay back. - V3
    address public ProxyWalletRegistry;
    event Received(address _sender, uint256 _amount);

    constructor(address _proxyWalletRegistry) payable {
        ProxyWalletRegistry = _proxyWalletRegistry;
    }

    function getProxy() external view returns (address) {
        return IProxyWalletRegistry(ProxyWalletRegistry).proxies(msg.sender);
    }

    function buildProxyWallet() external returns (address payable) {
        return IProxyWalletRegistry(ProxyWalletRegistry).build(msg.sender);
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}
