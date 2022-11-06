// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "IERC20.sol";

interface IERC20Metadata is IERC20 {
    /// @dev 代币名称
    function name() external view returns (string memory);
    /// @dev 代币符号
    function symbol() external view returns (string memory);
    /// @dev 小数点后位数
    function decimals() external view returns (uint8);
}