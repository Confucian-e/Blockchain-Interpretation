# Counters 计数器

> 参考 [OpenZepelin官方文档](https://docs.openzeppelin.com/contracts/4.x/api/utils#Counters) 结合自己的理解

一个只提供**增加**、**减少**、**重置**功能的计数器合约，用于追踪记录线性简单变化的元素数量。

## 代码

```solidity
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library Counters {
    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}
```

开篇定义一个 `Counter` 结构体，里面记录 `value` 字段，用于后续加减。

### 函数

入参都为存储在 `storage` 的 `Counter` 类型；但由于是库合约，所以通常以 `xx.current()` 的形式来调用。

- `current()` ：返回当前的 `value` 值
- `increment()` ：使 `value` 值加一
- `decrement()` ：使 `value` 值减一
- `reset()` ：重置 `value` 值，变为 `uint` 类型默认值 0

## 实际运用

在 ERC721 合约中就很适合使用 Counters 合约来记录 mint 的 tokenId

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract GameItem is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("GameItem", "ITM") {}

    function awardItem(address player, string memory tokenURI)
        public
        returns (uint256)
    {
        uint256 newItemId = _tokenIds.current();
        _mint(player, newItemId);
        _setTokenURI(newItemId, tokenURI);

        _tokenIds.increment();
        return newItemId;
    }
}
```

声明一个 Counters 合约中的 `Counter` 类型的结构体 `_tokenIds` ，每次 `mint` 后调用 `increment()` 函数来实现数量递增，将 `current()` 返回的值传给 ERC721 合约中的 `mint(address account, uint tokenId)` 函数。方便记录 mint 出的 NFT 数量。