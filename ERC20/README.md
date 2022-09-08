# ERC20解读

参考 [OpenZepplin文档](https://docs.openzeppelin.com/contracts/4.x/erc20) 和 [以太坊官方开发者文档](https://ethereum.org/en/developers/docs/standards/tokens/erc-20/)，结合自己的理解。

## 什么是ERC20

ERC20（Ethereum Request for Comments 20）一种代币标准。[EIP-20](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md) 中提出。

ERC20 代币合约追踪同质化（可替代）代币：任何一个代币都完全等同于任何其他代币；没有任何代币具有与之相关的特殊权利或行为。这使得 ERC20 代币可用于交换货币、投票权、质押等。

## 为什么要遵守ERC20

EIP-20 中的动机：

> 允许以太坊上的任何代币被其他应用程序（从钱包到去中心化交易所）重新使用的标准接口。

以太坊上的所有应用都默认支持 ERC20 ，如果你想自己发币，那么你的代码必须遵循 ERC20 标准，这样钱包（如MetaMask）等应用才能将你的币显示出来。

## 代码实现

需要实现以下函数和事件：

```solidity
function name() public view returns (string)
function symbol() public view returns (string)
function decimals() public view returns (uint8)
function totalSupply() public view returns (uint256)
function balanceOf(address _owner) public view returns (uint256 balance)
function transfer(address _to, uint256 _value) public returns (bool success)
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)
function approve(address _spender, uint256 _value) public returns (bool success)
function allowance(address _owner, address _spender) public view returns (uint256 remaining)

event Transfer(address indexed _from, address indexed _to, uint256 _value)
event Approval(address indexed _owner, address indexed _spender, uint256 _value)
```

使用 OpenZeppllin 提供的库能够轻松快速地构建 ERC20 Token 。

### 快速构建

这是一个 GLD token 。

```solidity
// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract GLDToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("Gold", "GLD") {
        _mint(msg.sender, initialSupply);
    }
}
```

通常，我们定义代币的发行量和代币名称及符号。

### IERC20

先来看下 ERC20 的接口（IERC20），这方便我们在开发中直接定义 ERC20 代币。

同样地，OpenZepplin 为我们提供了相应的库，方便开发者导入即用。

```solidity
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
```

**EIP 中定义的 ERC20 标准接口：**

```solidity
pragma solidity ^0.8.0;

interface IERC20 {
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
	
	function totalSupply() external view returns (uint256);
	function balanceOf(address account) external view returns (uint256);
	function transfer(address to, uint256 amount) external returns (bool);
	function allowance(address owner, address spender) external view returns (uint256);
	function approve(address spender, uint256 amount) external returns (bool);
	function transferFrom(
		address from,
		address to,
		uint256 amount
	) external returns (bool);
}
```

#### 逐一分析

函数：

- `totalSupply()` ：返回总共的代币数量。
- `balanceOf(address account)` ：返回 `account` 地址拥有的代币数量。
- `transfer(address to, uint256 amount)` ：将 `amount` 数量的代币发送给 `to` 地址，返回布尔值告知是否执行成功。触发 `Transfer` 事件。
- `allowance(address owner, address spender)` ：返回授权花费者 `spender` 通过 `transferFrom` 代表所有者花费的剩余代币数量。默认情况下为零。当 `approve` 和 `transferFrom` 被调用时，值将改变。
- `approve(address spender, uint256 amount)` ：授权 `spender` 可以花费 `amount` 数量的代币，返回布尔值告知是否执行成功。触发 `Approval` 事件。
- `transferFrom(address from, address to, uint256 amount)` ：将 `amount` 数量的代币从 `from` 地址发送到 `to` 地址，返回布尔值告知是否执行成功。触发 `Transfer` 事件。

事件（定义中的 `indexed` 便于查找过滤）：

- `Transfer(address from, address to, uint256 value)` ：当代币被一个地址转移到另一个地址时触发。注意：转移的值可能是 0 。
- `Approval(address owner, address spender, uint256 value)` ：当代币所有者授权别人使用代币时触发，即调用 `approve` 方法。

#### 元数据

一般除了上述必须实现的函数外，还有一些别的方法：

- `name()` ：返回代币名称
- `symbol()` ：返回代币符号
- `decimals()` 返回代币小数点后位数

### ERC20

来看下 ERC20 代币具体是怎么写的。

同样，OpenZepplin 提供了现成的合约代码：

```solidity
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
```

这里贴一个GitHub源码链接 [OpenZepplin ERC20](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol)

#### 函数概览

```solidity
constructor(name_, symbol_)
name()
symbol()
decimals()
totalSupply()
balanceOf(account)
transfer(to, amount)
allowance(owner, spender)
approve(spender, amount)
transferFrom(from, to, amount)
increaseAllowance(spender, addedValue)
decreaseAllowance(spender, subtractedValue)
_transfer(from, to, amount)
_mint(account, amount)
_burn(account, amount)
_approve(owner, spender, amount)
_spendAllowance(owner, spender, amount)
_beforeTokenTransfer(from, to, amount)
_afterTokenTransfer(from, to, amount)
```

**事件（同 IERC20）**

```solidity
Transfer(from, to, value)
Approval(owner, spender, value)
```

#### 逐一分析

- `constructor(string name, string symbol)` ：设定代币的名称和符号。`decimals` 默认是 18 ，要修改成不同的值你应该重载它。这两个值是不变的，只在构造时赋值一次。
- `name()` ：返回代币的名称。
- `symbol()` ：返回代币的符号，通常是名称的缩写。
- `decimals()` ：返回小数点后位数，通常是 18 ，模仿 Ether 和 wei 。要更改就重写它。

`totalSupply()、balanceOf(address account)、transfer(address to, uint256 amount)、 allowance(address owner, address spender)、approve(address spender, uint256 amount)、transferFrom(address from, address to, uint256 amount)` 都参考 IERC20 。

- `increaseAllowance(address spender, uint256 addedValue)` ：以原子的方式增加 `spender` 额度。返回布尔值告知是否执行成功，触发 `Approval` 事件。

- `_transfer(address from, address to, uint256 amount)` ：转账。这个内部函数相当于 `transfer` ，可以用于例如实施自动代币费用，削减机制等。触发 `Transfer` 事件。

- `_mint(address account, uint256 amount)` ：铸造 `amount` 数量的代币给 `account` 地址，增加总发行量。触发 `Transfer` 事件，其中参数 `from` 是零地址。

- `_burn(address account, uint256 amount)` ：从 `account` 地址中烧毁 `amount` 数量的代币，减少总发行量。触发 `Transfer` 事件，其中参数 `to` 是零地址。

- `_approve(address owner, uint256 spender, uint256 amount)` ：设定允许 `spender` 花费 `owner` 的代币数量。这个内部函数相当于 `approve` ，可以用于例如为某些子系统设置自动限额等。

- `spendAllowance(address owner, address spender, uint256 amount)` ：花费 `amount` 数量的 `owner` 授权 `spender` 的代币。在无限 allowance 的情况下不更新 allowance 金额。如果没有足够的余量，则恢复。可能触发 `Approval` 事件。

- `_beforeTokenTransfer(address from, address to, uint256 amount)` ：在任何代币转账前的 Hook 。它包括铸币和烧毁。调用条件：
  - 当 `from` 和 `to` 都不是零地址时，`from` 手里 `amount` 数量的代币将发送给 `to` 。
  - 当 `from` 是零地址时，将给 `to` 铸造 `amount` 数量的代币。
  - 当 `to` 是零地址时，`from` 手里 `amount` 数量的代币将被烧毁。
  - `from` 和 `to` 不能同时为零地址。
- `_afterTokenTransfer(address from, address to, uint256 amount)` ：在任何代币转账后的 Hook 。它包括铸币和烧毁。调用条件：
  - 当 `from` 和 `to` 都不是零地址时，`from` 手里 `amount` 数量的代币将发送给 `to` 。
  - 当 `from` 是零地址时，将给 `to` 铸造 `amount` 数量的代币。
  - 当 `to` 是零地址时，`from` 手里 `amount` 数量的代币将被烧毁。
  - `from` 和 `to` 不能同时为零地址。

#### 小结

ERC20 代码中的 `_transfer`、`_mint`、`_burn`、`_approve`、`_spendAllowance`、`_beforeTokenTransfer`、`_afterTokenTransfer` 都是 `internal` 函数（其余为 `public` ），也就是说它们只能被派生合约调用。

## 从零开始，自己动手

### 1.编写IERC20

[IERC20.sol](https://github.com/Blockchain-Engineer-Learning/Contract-Interpretation/blob/main/ERC20/IERC20.sol)

```solidity
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
```

### 2.加上Metadata

[IERC20Metadata.sol](https://github.com/Blockchain-Engineer-Learning/Contract-Interpretation/blob/main/ERC20/IERC20Metadata.sol)

```solidity
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
```

### 3.编写ERC20

[ERC20.sol](https://github.com/Blockchain-Engineer-Learning/Contract-Interpretation/blob/main/ERC20/IERC20.sol)

```solidity
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IERC20Metadata.sol";

contract ERC20 is IERC20, IERC30Metadata {
    // 地址余额
    mapping(address => uint256) private _balances;
    // 授权地址余额
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /// @dev 设定代币名称符号
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /// @dev 小数点位数一般为 18
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual  override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 substractedValue) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= substractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approval(owner, spender, currentAllowance - substractedValue);
        }
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve  to the zero address");

        _allowances[owner][spender];
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
```

## 总结

ERC20 其实就是一种最常见的代币标准，它明确了同质化代币的经典功能并规范了开发者编写 token 时的代码，从而方便各种应用适配。
