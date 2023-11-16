// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IBookKeeper {
    // mapping(bytes32 => mapping(address => Position)) public override positions; // mapping of all positions by collateral pool id and position address
    function positions(
        bytes32 _collateralPoolId,
        address _positionAddress
    ) external view returns (uint256 lockedCollateral, uint256 debtShare);
}
