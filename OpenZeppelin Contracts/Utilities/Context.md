# Context

Context 合约经常用来被继承

```solidity
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
```

Context 合约包装了 2 个函数 `_msgSender()` 和 `_msgData()` 来替换全局属性 `msg.sender` 和 `msg.data` 

这样做的**好处**是：如果以后 solidity 版本更新对 `msg.sender` 和 `msg.data` 进行了名字上的修改，比如新版本用 `msg.xx` 表示现在 `msg.sender` 的含义，那么继承了 Context 合约的派生合约只需要修改 Context 合约里的 `_msgSender()` 函数就好（因为你的合约里可能用到了很多次 `msg.sender` ，逐一修改效率很低）