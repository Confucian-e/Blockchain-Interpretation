# ERC721解读

参考 [ERC 721 - OpenZeppelin Docs](https://docs.openzeppelin.com/contracts/4.x/api/token/erc721) 结合自己的理解。

## 什么是ERC721

ERC20（Ethereum Request for Comments 721）一种**非同质化代币**标准。[EIP-721](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md) 中提出。

与ERC20同质化代币不同，每个ERC721代币都是独一无二的。

## 为什么要遵守ERC721

EIP-721 中的动机：

> A standard interface allows wallet/broker/auction applications to work with any NFT on Ethereum. We provide for simple ERC-721 smart contracts as well as contracts that track an *arbitrarily large* number of NFTs.

NFT合约的标准接口实现，便于追踪和转移NFT。

## 代码实现

需要实现以下函数和事件：

```solidity
function balanceOf(owner)
function ownerOf(tokenId)
function safeTransferFrom(from, to, tokenId, data)
function safeTransferFrom(from, to, tokenId)
function transferFrom(from, to, tokenId)
function approve(to, tokenId)
function setApprovalForAll(operator, _approved)
function getApproved(tokenId)
function isApprovedForAll(owner, operator)
function supportsInterface(interfaceId)    //IERC165

event Transfer(from, to, tokenId)
event Approval(owner, approved, tokenId)
event ApprovalForAll(owner, operator, approved)
```

### 快速构建

使用 OpenZeppelin 提供的库能够快速构建 NFT

```solidity
// contracts/GameItem.sol
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

