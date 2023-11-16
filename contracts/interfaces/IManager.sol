// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IManager {
    // mapping(uint256 => List) public list;
    function list(
        uint256 _positionId
    ) external view returns (uint256 prev, uint256 next);

    // mapping(address => uint256) public ownerFirstPositionId;
    function ownerFirstPositionId(
        address _proxyWalletAddress
    ) external view returns (uint256 positionId);

    // mapping(address => uint256) public ownerLastPositionId;
    function ownerLastPositionId(
        address _proxyWalletAddress
    ) external view returns (uint256 positionId);

    // mapping(address => uint256) public ownerPositionCount;

    function ownerPositionCount(
        address _proxyWalletAddress
    ) external view returns (uint256 positionCount);

    // mapping(uint256 => address) public override positions;
    function positions(
        uint256 _positionId
    ) external view returns (address positionAddress);
}
