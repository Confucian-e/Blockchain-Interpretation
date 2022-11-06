# Uniswap v1 证明了AMM的可能

参考 [Uniswap官方文档](https://docs.uniswap.org/protocol/V1/introduction) 并结合自己的理解。

## Uniswap 一骑绝尘

在 Uniswap 出现前，DEX 领域里有多个挑战者。然而随着 Uniswap 的 AMM 提出，直接颠覆了整个 DeFi 行业。Uniswap 也因此稳稳占据了 DEX 的绝大市场份额。

## 什么是 AMM

AMM(Automated Market Maker) 自动做市商

所谓“做市商”也叫“流动性提供者”，他们负责为交易所提供流动性，促进买卖单的成交，自己赚取相关交易的一定手续费。AMM 使用算法模拟市场中的价格行为，不需要用户去挂单，而是直接计算两个或多个资产间交易的汇率，使得用户可以不用等待，能够即时交易。流动性池子中资产越多，流动性越好，滑点越低。这也是 DEX 都鼓励用户添加流动性(LP)的原因。

## 原理

Uniswap v1 背后的做市原理很简单——恒定积公式：**x * y = k** 即交易前的代币数量积等于交易后的代币数量积。

## 限制

Uniswap v1 只开通了 ETH-ERC20 交易对，这使得 ERC20-ERC20 间的交易必须通过 ETH 作为中介来实现，费时费钱。初期流动性池子深度不足，价格变化大。

## 代码解读

由于 Uniswap v1 诞生于早期，合约所使用的编程语言为 Vyper 而后续 v2 v3 转回 Solidity 所以这里不对 v1 的合约代码进行详细分析，主要了解所用的恒定积公式即可。

## 总结

Uniswap v1 协议的出现证明了 AMM 的可能，极大程度促进了 DEX 的发展，随着后续 v2 v3 的推出，Uniswap 毫无争议地坐实了 DeFi 龙头。

