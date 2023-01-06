# Foundry Tutorial

## 介绍

foundry 是一个由 Rust 编写的合约开发测试框架，笔者尝试了下发现比 hardhat 要强大很多。

## 安装

对于 Linux 和 MacOS 用户来说，安装 foundry 会简单很多。Windows 用户请查阅官方文档哈哈。

在终端里运行下面这行命令：

```bash
$ curl -L https://foundry.paradigm.xyz | bash
```

这会下载 foundry 安装工具 foundryup，完成后可通过运行以下命令来安装 foundry ：

```shell
$ foundryup
```

如果运行成功，你将拥有三个模块：

- forge : 用于开发、部署、测试合约
- cast : 用于对兼容以太坊虚拟机（EVM）的区块链进行RPC调用
- anvil : 用于本地运行区块链节点

##  创建一个新项目

想要创建一个新的 foundry 项目，需要使用 `forge init` 命令。

```shell
$ forge init hello_foundry
```

这会创建一个名为 hello_foundry 的项目文件夹。目录结构如下：

```shell
.
├── foundry.toml
├── lib
├── script
├── src
└── test

4 directories, 1 file
```

- foundry.toml 是配置文件，如设置 solc 版本
- lib 文件夹下存放你编写合约需要引用的库
- script 文件夹下存放合约部署脚本
- src 文件下存放编写的合约
- test 文件下存放合约测试脚本

### 编译

使用 `forge build` 命令来编译合约

```shell
$ forge build
Compiling 10 files with 0.8.16
Solc 0.8.16 finished in 3.97s
Compiler run successful
```

### 测试

使用 `forge test` 命令来测试合约

```shell
$ forge test
No files changed, compilation skipped

Running 2 tests for test/Counter.t.sol:CounterTest
[PASS] testIncrement() (gas: 28312)
[PASS] testSetNumber(uint256) (runs: 256, μ: 27376, ~: 28387)
Test result: ok. 2 passed; 0 failed; finished in 24.43ms
```