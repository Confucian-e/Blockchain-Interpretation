# Context

Context 合约经常用来被继承，代码很好理解

## 代码

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

Context 合约包装了 2 个函数 `_msgSender()` 和 `_msgData()` 来返回内置全局属性 `msg.sender` 和 `msg.data` 

## 意义

这样做的**好处**是：如果以后 solidity 版本更新对 `msg.sender` 和 `msg.data` 进行了名字上的修改，比如新版本用 `msg.xx` 表示现在 `msg.sender` 的含义，那么继承了 Context 合约的派生合约只需要修改 Context 合约里的 `_msgSender()` 函数就好（将 `_msgSender()` 的内容改为 `return msg.xx;` ）

通常在一个合约中会多次用到 `msg.sender` ，所以不继承 Context 合约的话可能会修改多处，这样效率很低；但继承 Context 的话，只需要修改 Context 合约这一处就 OK 