// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface ICollateralPoolConfig {
    function getDebtAccumulatedRate(
        bytes32 _collateralPoolId
    ) external view returns (uint256);
}
