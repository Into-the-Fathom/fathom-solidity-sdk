// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IBookKeeper {
    struct Position {
        uint256 lockedCollateral; // Locked collateral inside this position (used for minting)                  [wad]
        uint256 debtShare; // The debt share of this position or the share amount of minted Fathom Stablecoin   [wad]
    }

    // mapping(bytes32 => mapping(address => Position)) public override positions; // mapping of all positions by collateral pool id and position address
    function positions(
        bytes32 _collateralPoolId,
        address _positionAddress
    ) external view returns (Position memory);
}
