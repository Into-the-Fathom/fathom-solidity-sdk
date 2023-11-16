// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../interfaces/IProxyWalletRegistry.sol";
import "../interfaces/IProxyWallet.sol";
import "../interfaces/IToken.sol";

contract SDKMockV2 {
    //the goal here is to just open a position - V1
    //next step is to try to borrow. - V2
    //next step is to try to pay back. - V3
    address public ProxyWalletRegistry;
    address public ProxyWallet;
    address public FXDAddress;
    address public PositionManager;
    address public StabilityFeeCollector;
    address public CollateralTokenAdapter;
    address public StablecoinAdapter;
    bytes32 public collateral_pool_id;
    event Received(address _sender, uint256 _amount);

    constructor(
        address _ProxyWalletRegistry,
        address _FXDAddress,
        address _PositionManager,
        address _StabilityFeeCollector,
        address _CollateralTokenAdapter,
        address _StablecoinAdapter,
        bytes32 _collateral_pool_id
    ) payable {
        ProxyWalletRegistry = _ProxyWalletRegistry;
        FXDAddress = _FXDAddress;
        PositionManager = _PositionManager;
        StabilityFeeCollector = _StabilityFeeCollector;
        CollateralTokenAdapter = _CollateralTokenAdapter;
        StablecoinAdapter = _StablecoinAdapter;
        collateral_pool_id = _collateral_pool_id;
    }

    function buildProxyWallet() external {
        ProxyWallet = IProxyWalletRegistry(ProxyWalletRegistry).build(
            address(this)
        );
    }

    function setAuthority() external {}

    function openPosition(uint256 _stablecoinAmount) external payable {
        bytes memory openPositionEncoding = abi.encodeWithSignature(
            "openLockXDCAndDraw(address,address,address,address,bytes32,uint256,bytes)",
            PositionManager,
            StabilityFeeCollector,
            CollateralTokenAdapter,
            StablecoinAdapter,
            collateral_pool_id,
            _stablecoinAmount,
            bytes(hex"00")
        );
        IProxyWallet(ProxyWallet).execute{value: msg.value}(
            openPositionEncoding
        );
        IToken(FXDAddress).transfer(
            msg.sender,
            IToken(FXDAddress).balanceOf(address(this))
        );
    }

    function openPositionEncode(
        uint256 _stablecoinAmount
    ) external view returns (bytes memory) {
        // bytes4 selector = bytes4(
        //     keccak256(
        //         "openLockXDCAndDraw(address,address,address,address,bytes32,uint256,bytes)"
        //     )
        // );

        // return
        //     abi.encode(
        //         selector,
        //         PositionManager,
        //         StabilityFeeCollector,
        //         CollateralTokenAdapter,
        //         StablecoinAdapter,
        //         collateral_pool_id,
        //         _stablecoinAmount,
        //         bytes(hex"00") // or however you are representing the last parameter in JS
        //     );

        return
            abi.encodeWithSignature(
                "openLockXDCAndDraw(address,address,address,address,bytes32,uint256,bytes)",
                PositionManager,
                StabilityFeeCollector,
                CollateralTokenAdapter,
                StablecoinAdapter,
                collateral_pool_id,
                _stablecoinAmount,
                bytes(hex"00")
            );
    }

    function execute(bytes memory _data) external payable {
        IProxyWallet(ProxyWallet).execute{value: msg.value}(_data);
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}
