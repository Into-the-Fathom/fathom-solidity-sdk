// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../interfaces/IProxyWalletRegistry.sol";
import "../interfaces/IProxyWallet.sol";
import "../interfaces/IToken.sol";

contract SDKMockV4 {
    //the goal here is to just open a position - V1
    //next step is to try to borrow. - V2
    //next step is to try to pay back. - V3
    //partial closure - V4
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
    ) {
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

    function closePositionPartial(
        uint256 _positionId,
        uint256 _collateralAmount,
        uint256 _stablecoinAmount
    ) external payable {
        IToken(FXDAddress).approve(
            ProxyWallet,
            IToken(FXDAddress).balanceOf(address(this))
        );
        bytes memory closePositionFullEncoding = abi.encodeWithSignature(
            "wipeAndUnlockXDC(address,address,address,uint256,uint256,uint256,bytes)",
            PositionManager,
            CollateralTokenAdapter,
            StablecoinAdapter,
            _positionId,
            _collateralAmount,
            _stablecoinAmount,
            bytes(hex"00")
        );
        IProxyWallet(ProxyWallet).execute{value: msg.value}(
            closePositionFullEncoding
        );
        // IToken(FXDAddress).transfer(
        //     msg.sender,
        //     IToken(FXDAddress).balanceOf(address(this))
        // );
        //send eth.
        (bool sent, ) = payable(msg.sender).call{value: address(this).balance}(
            ""
        );
        require(sent, "Failed to send Ether");
    }

    function closePositionFull(
        uint256 _positionId,
        uint256 _collateralAmount
    ) external payable {
        // IToken(FXDAddress).transferFrom(
        //     msg.sender,
        //     address(this),
        //     IToken(FXDAddress).balanceOf(msg.sender)
        // );
        // instead of trasnferFrom, let's make the owner of this contract just send
        //as much as FXD to spend,
        //of course then I need to add a function to withdraw FXD from this contract.
        IToken(FXDAddress).approve(
            ProxyWallet,
            IToken(FXDAddress).balanceOf(address(this))
        );
        // revert("Here/79"); came here
        bytes memory closePositionFullEncoding = abi.encodeWithSignature(
            "wipeAllAndUnlockXDC(address,address,address,uint256,uint256,bytes)",
            PositionManager,
            CollateralTokenAdapter,
            StablecoinAdapter,
            _positionId,
            _collateralAmount,
            bytes(hex"00")
        );
        IProxyWallet(ProxyWallet).execute{value: msg.value}(
            closePositionFullEncoding
        );
        //revert("Here/90"); didn't come here So it's the execute fn.
        //inefficient, better optimized later,
        //by getting rid of this, and approving only needed amount
        // IToken(FXDAddress).transfer(
        //     msg.sender,
        //     IToken(FXDAddress).balanceOf(address(this))
        // );
        //send eth.
        (bool sent, ) = payable(msg.sender).call{value: address(this).balance}(
            ""
        );
        require(sent, "Failed to send Ether");
    }

    function closePositionEncode(
        uint256 _positionId,
        uint256 _collateralAmount
    ) external view returns (bytes memory) {
        return
            abi.encodeWithSignature(
                "wipeAllAndUnlockXDC(address,address,address,uint256,uint256,bytes)",
                PositionManager,
                CollateralTokenAdapter,
                StablecoinAdapter,
                _positionId,
                _collateralAmount,
                bytes(hex"00")
            );
    }

    function execute(bytes memory _data) external payable {
        IProxyWallet(ProxyWallet).execute{value: msg.value}(_data);
    }

    function execute2(bytes memory _data) external payable {
        IToken(FXDAddress).approve(
            ProxyWallet,
            IToken(FXDAddress).balanceOf(address(this))
        );
        IProxyWallet(ProxyWallet).execute{value: msg.value}(_data);
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}
