# Solidity 0.8版本前的常客-SafeMath

参考 [OpenZepplin文档](https://docs.openzeppelin.com/contracts/4.x/api/utils#SafeMath) 并结合自己的理解。

## “曾经的王者”

在 Solidity 0.8版本前，编译器是没有内置溢出检测的，所以数值的算数运算通常需要使用 `SafeMath.sol` 这个库，它包装了常见的算术运算逻辑。

> 但从0.8版本开始，编译器就内置了溢出检测，因此无需使用 SafeMath 。但市面上大部分项目的合约版本都在0.8之前，所有还是有必要学习下 SafeMath 。

## 快速使用

```solidity
import "@openzeppelin/contracts/utils/math/SignedSafeMath.sol";
```

注意：`SafeMath.sol` 是库(library)合约。

## 概览

5种算术运算逻辑：加、减、乘、除、模

整体分3大类，都是内部(internal)的纯(pure)函数。

- Try类（额外返回溢出标识）
  - `tryAdd(a, b)`
  - `trySub(a, b)`
  - `tryMul(a, b)`
  - `tryDiv(a, b)`
  - `tryMod(a, b)`
- 单纯运算类（只返回运算结果）
  - `add(a, b)`
  - `sub(a, b)`
  - `mul(a, b)`
  - `div(a, b)`
  - `mod(a, b)`
- errrorMessage类（溢出时返回自定义报错信息）
  - `sub(a, b, errorMessage)`
  - `div(a, b, errorMessage)`
  - `mod(a, b, errorMessage)`

## 分析

源码 [SafeMath.sol](https://github.com/Blockchain-Engineer-Learning/Contract-Interpretation/blob/main/SafeMath/SafeMath.sol)

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }


    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
```

### 逐类分析

因为每一类中不同运算的逻辑是通用的，所以每类只选取一个来详细分析。

#### Try类

> 注意：Try类函数是 solidity 3.4版本以上可用

```solidity
function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
	unchecked {
    	uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
}
```

使用 `unchecked` 让编译器不检查括住的内容，临时定义 `c` 作为 `a, b` 的和，随后进行判断。如果 `c` 小于 `a` 说明发生了溢出，返回 `false` 提示发生了溢出，并将运算结果设为0返回；否则返回 `true` 提示正常，并将正确运算结果 `c` 一并返回。

#### 单纯运算类

```solidity
function add(uint256 a, uint256 b) internal pure returns (uint256) {
	return a + b;
}
```

计算2个数的和，发生溢出则回滚(revert)。

#### errorMessage类

```solidity
function sub(
	uint256 a,
    uint256 b,
    string memory errorMessage
) internal pure returns (uint256) {
    unchecked {
    	require(b <= a, errorMessage);
        return a - b;
    }
}
```

在入参中多了一个自定义的报错信息，使用 `require` 在发生溢出时回滚并抛出自定义的报错信息。