// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    /// @dev 总发行量
    function totoalSupply() external view returns (uint256);
    /// @dev 查看地址余额
    function balanceOf(address account) external view returns (uint256);
    /// @dev 单地址转账
    function transfer(address account, uint256 amount) external returns (bool);
    /// @dev 查看被授权人代表所有者花费的代币余额
    function allowance(address owner, address spender) external view returns (uint256);
    /// @dev 授权别人花费你拥有的代币
    function approve(address spender, uint256 amount) external returns (bool);
    /// @dev 双地址转账
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /// @dev 发生代币转移时触发
    event Transfer(address indexed from, address indexed to, uint256 value);
    /// @dev 授权时触发
    event Approval(address indexed owner, address indexed spender, uint256 value);
}