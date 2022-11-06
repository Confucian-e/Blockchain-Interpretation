# Hardhat Tutorial

## 前言

参考 Hardhat tutorial 文档：https://hardhat.org/tutorial

所需环境：

- Node.js

- yarn

- MetaMask(浏览器插件)

预备知识：

- 区块链基础知识

- 智能合约基础知识

- NPM

- Javascript

- Solidity

## 正文

### 初始化项目

创建一个文件夹作为你的项目存放路径（我取名 demo）后面所有命令皆在项目根目录下。

在项目文件夹下初始化 npm 项目：

```Shell
yarn init -y
```

### 安装 hardhat 依赖

```Shell
yarn add --dev hardhat
```

运行 `npx hardhat` 并选择 `Create an empty hardhat.config.js`

```Shell
$ npx hardhat
888    888                      888 888               888
888    888                      888 888               888
888    888                      888 888               888
8888888888  8888b.  888d888 .d88888 88888b.   8888b.  888888
888    888     "88b 888P"  d88" 888 888 "88b     "88b 888
888    888 .d888888 888    888  888 888  888 .d888888 888
888    888 888  888 888    Y88b 888 888  888 888  888 Y88b.
888    888 "Y888888 888     "Y88888 888  888 "Y888888  "Y888

👷 Welcome to Hardhat v2.9.9 👷

? What do you want to do? …
  Create a JavaScript project
  Create a TypeScript project
❯ Create an empty hardhat.config.js
  Quit
```

这时在你的项目路径下会创建一个 `hardhat.config.js` 文件：

```JavaScript
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
};
```

里面指定了 solidity 编译器版本。

我们还需要安装一些后面要用的插件：

```Shell
yarn add --dev @nomicfoundation/hardhat-toolbox @nomicfoundation/hardhat-network-helpers @nomicfoundation/hardhat-chai-matchers @nomiclabs/hardhat-ethers @nomiclabs/hardhat-etherscan chai ethers hardhat-gas-reporter solidity-coverage @typechain/hardhat typechain @typechain/ethers-v5 @ethersproject/abi @ethersproject/providers
```

### 编写智能合约

创建 `contracts` 文件夹，并在其路径下创建 `Token.sol` 智能合约文件。

复制下方代码到 `Token.sol` 文件里：

```Solidity
//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

contract Token {
    // 代币的名字和简称
    string public name = "My Hardhat Token";
    string public symbol = "MHT";

    // 总供应量
    uint256 public totalSupply = 1000000;

    // 合约所有者
    address public owner;

    // address 到 uint 的映射，用来记录地址的代币余额
    mapping(address => uint256) balances;

    // 代币转账事件
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // 部署合约时，为部署地址铸造总供应量代币，并设置为合约所有者
    constructor() {
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    // 转账函数
    function transfer(address to, uint256 amount) external {
        // 检查调用者余额是否满足转账金额
        require(balances[msg.sender] >= amount, "Not enough tokens");

        // 转移数量
        balances[msg.sender] -= amount;
        balances[to] += amount;

        // 触发 Transfer 事件
        emit Transfer(msg.sender, to, amount);
    }

    // 查看指定账户的余额
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
}
```

#### 编译合约

可以通过 `npx hardhat compile` 命令来编译合约。

```Shell
$ npx hardhat compile
Compiling 1 file with 0.8.9
Compilation finished successfully
```

### 编写合约测试

> 合约测试非必需环节，可以跳过不写。

创建 `test` 文件夹，并在其路径下创建 `Token.js` 文件。

复制下方代码到 `Token.js` 文件里：

```JavaScript
const { expect } = require("chai");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("Token contract", function () {
  
  async function deployTokenFixture() {
    
    const Token = await ethers.getContractFactory("Token");
    const [owner, addr1, addr2] = await ethers.getSigners();

    const hardhatToken = await Token.deploy();

    await hardhatToken.deployed();
    
    return { Token, hardhatToken, owner, addr1, addr2 };
  }
  
  describe("Deployment", function () {

    it("Should set the right owner", async function () {
      
      const { hardhatToken, owner } = await loadFixture(deployTokenFixture);

      expect(await hardhatToken.owner()).to.equal(owner.address);
    });

    it("Should assign the total supply of tokens to the owner", async function () {
      const { hardhatToken, owner } = await loadFixture(deployTokenFixture);
      const ownerBalance = await hardhatToken.balanceOf(owner.address);
      expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
    });
  });

  describe("Transactions", function () {
    it("Should transfer tokens between accounts", async function () {
      const { hardhatToken, owner, addr1, addr2 } = await loadFixture(
        deployTokenFixture
      );
      
      await expect(
        hardhatToken.transfer(addr1.address, 50)
      ).to.changeTokenBalances(hardhatToken, [owner, addr1], [-50, 50]);

      await expect(
        hardhatToken.connect(addr1).transfer(addr2.address, 50)
      ).to.changeTokenBalances(hardhatToken, [addr1, addr2], [-50, 50]);
    });

    it("should emit Transfer events", async function () {
      const { hardhatToken, owner, addr1, addr2 } = await loadFixture(
        deployTokenFixture
      );

      await expect(hardhatToken.transfer(addr1.address, 50))
        .to.emit(hardhatToken, "Transfer")
        .withArgs(owner.address, addr1.address, 50);

      await expect(hardhatToken.connect(addr1).transfer(addr2.address, 50))
        .to.emit(hardhatToken, "Transfer")
        .withArgs(addr1.address, addr2.address, 50);
    });

    it("Should fail if sender doesn't have enough tokens", async function () {
      const { hardhatToken, owner, addr1 } = await loadFixture(
        deployTokenFixture
      );
      const initialOwnerBalance = await hardhatToken.balanceOf(owner.address);

      await expect(
        hardhatToken.connect(addr1).transfer(owner.address, 1)
      ).to.be.revertedWith("Not enough tokens");

      expect(await hardhatToken.balanceOf(owner.address)).to.equal(
        initialOwnerBalance
      );
    });
  });
});
```

测试文件涉及了 `ether.js` (合约交互库)和一些测试库(chai，hardhat)。

#### 测试合约

可以运行 `npx hardhat test` 来对合约进行测试。

```Shell
$ npx hardhat test

  Token contract
    Deployment
      ✓ Should set the right owner
      ✓ Should assign the total supply of tokens to the owner
    Transactions
      ✓ Should transfer tokens between accounts (199ms)
      ✓ Should fail if sender doesn’t have enough tokens
      ✓ Should update balances after transfers (111ms)


  5 passing (1s)
```

### 部署合约

我们已经完成了合约的编写和测试，接下来将合约部署到链上。

#### 编写部署脚本

创建 `scripts` 文件夹，并在其路径下创建 `deploy.js` 文件。

复制下方代码到 `deploy.js` 文件里：

```JavaScript
async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const Token = await ethers.getContractFactory("Token");
  const token = await Token.deploy();

  console.log("Token address:", token.address);
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
```

#### 部署合约

可以运行 `npx hardhat run scripts/deploy.js --network <network-name>` 来部署合约到指定的链(network)。

但我们需要先配置下链(网络)信息。

#### 配置链(网络)信息

> 由于以太坊Goerli测试网太堵，我们使用Matic链的mumbai测试网

修改 `hardhat.config.js` 文件如下：

```JavaScript
require("@nomicfoundation/hardhat-toolbox");

// 下面这行写你的开发钱包私钥
const PRIVATE_KEY = "YOUR GOERLI PRIVATE KEY";
module.exports = {
  solidity: "0.8.9",
  networks: {
      mumbai: {
            // 将你的 API URL 写到下面这行
            url: "YOUR API URL",
            accounts: [PRIVATE_KEY]
      }
  }
};
```

注意：开发钱包内不要有主网币，避免丢失。

##### 获得 API URL

我们需要用 API URL 来连接到节点进而发出交易。

有2种主流的 provider 网站：

https://infura.io/

https://www.alchemy.com/

进入对应网页注册好账号后即可获取 API URL

#### 部署合约上链

配置好 `hardhat.config.js` 文件后，运行 `npx hardhat run scripts/deploy.js --network mumbai` 即可部署到链上。具体信息可通过 provider 的 dashboard 查询。

## 结语

以上就是使用hardhat部署简单合约上链的基本流程。

运行 `npx hardhat` 并选择 `Create an empty hardhat.config.js`

```Shell
$ npx hardhat
888    888                      888 888               888
888    888                      888 888               888
888    888                      888 888               888
8888888888  8888b.  888d888 .d88888 88888b.   8888b.  888888
888    888     "88b 888P"  d88" 888 888 "88b     "88b 888
888    888 .d888888 888    888  888 888  888 .d888888 888
888    888 888  888 888    Y88b 888 888  888 888  888 Y88b.
888    888 "Y888888 888     "Y88888 888  888 "Y888888  "Y888

👷 Welcome to Hardhat v2.9.9 👷

? What do you want to do? …
  Create a JavaScript project
  Create a TypeScript project
❯ Create an empty hardhat.config.js
  Quit
```

这时在你的项目路径下会创建一个 `hardhat.config.js` 文件：

```JavaScript
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
};
```

里面指定了 solidity 编译器版本。

我们还需要安装一些后面要用的插件：

```Shell
yarn add --dev @nomicfoundation/hardhat-toolbox @nomicfoundation/hardhat-network-helpers @nomicfoundation/hardhat-chai-matchers @nomiclabs/hardhat-ethers @nomiclabs/hardhat-etherscan chai ethers hardhat-gas-reporter solidity-coverage @typechain/hardhat typechain @typechain/ethers-v5 @ethersproject/abi @ethersproject/providers
```

### 编写智能合约

创建 `contracts` 文件夹，并在其路径下创建 `Token.sol` 智能合约文件。

复制下方代码到 `Token.sol` 文件里：

```Solidity
//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

contract Token {
    // 代币的名字和简称
    string public name = "My Hardhat Token";
    string public symbol = "MHT";

    // 总供应量
    uint256 public totalSupply = 1000000;

    // 合约所有者
    address public owner;

    // address 到 uint 的映射，用来记录地址的代币余额
    mapping(address => uint256) balances;

    // 代币转账事件
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // 部署合约时，为部署地址铸造总供应量代币，并设置为合约所有者
    constructor() {
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    // 转账函数
    function transfer(address to, uint256 amount) external {
        // 检查调用者余额是否满足转账金额
        require(balances[msg.sender] >= amount, "Not enough tokens");

        // 转移数量
        balances[msg.sender] -= amount;
        balances[to] += amount;

        // 触发 Transfer 事件
        emit Transfer(msg.sender, to, amount);
    }

    // 查看指定账户的余额
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
}
```

#### 编译合约

可以通过 `npx hardhat compile` 命令来编译合约。

```Shell
$ npx hardhat compile
Compiling 1 file with 0.8.9
Compilation finished successfully
```

### 编写合约测试

> 合约测试非必需环节，可以跳过不写。

创建 `test` 文件夹，并在其路径下创建 `Token.js` 文件。

复制下方代码到 `Token.js` 文件里：

```JavaScript
const { expect } = require("chai");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("Token contract", function () {
  
  async function deployTokenFixture() {
    
    const Token = await ethers.getContractFactory("Token");
    const [owner, addr1, addr2] = await ethers.getSigners();

    const hardhatToken = await Token.deploy();

    await hardhatToken.deployed();
    
    return { Token, hardhatToken, owner, addr1, addr2 };
  }
  
  describe("Deployment", function () {

    it("Should set the right owner", async function () {
      
      const { hardhatToken, owner } = await loadFixture(deployTokenFixture);

      expect(await hardhatToken.owner()).to.equal(owner.address);
    });

    it("Should assign the total supply of tokens to the owner", async function () {
      const { hardhatToken, owner } = await loadFixture(deployTokenFixture);
      const ownerBalance = await hardhatToken.balanceOf(owner.address);
      expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
    });
  });

  describe("Transactions", function () {
    it("Should transfer tokens between accounts", async function () {
      const { hardhatToken, owner, addr1, addr2 } = await loadFixture(
        deployTokenFixture
      );
      
      await expect(
        hardhatToken.transfer(addr1.address, 50)
      ).to.changeTokenBalances(hardhatToken, [owner, addr1], [-50, 50]);

      await expect(
        hardhatToken.connect(addr1).transfer(addr2.address, 50)
      ).to.changeTokenBalances(hardhatToken, [addr1, addr2], [-50, 50]);
    });

    it("should emit Transfer events", async function () {
      const { hardhatToken, owner, addr1, addr2 } = await loadFixture(
        deployTokenFixture
      );

      await expect(hardhatToken.transfer(addr1.address, 50))
        .to.emit(hardhatToken, "Transfer")
        .withArgs(owner.address, addr1.address, 50);

      await expect(hardhatToken.connect(addr1).transfer(addr2.address, 50))
        .to.emit(hardhatToken, "Transfer")
        .withArgs(addr1.address, addr2.address, 50);
    });

    it("Should fail if sender doesn't have enough tokens", async function () {
      const { hardhatToken, owner, addr1 } = await loadFixture(
        deployTokenFixture
      );
      const initialOwnerBalance = await hardhatToken.balanceOf(owner.address);

      await expect(
        hardhatToken.connect(addr1).transfer(owner.address, 1)
      ).to.be.revertedWith("Not enough tokens");

      expect(await hardhatToken.balanceOf(owner.address)).to.equal(
        initialOwnerBalance
      );
    });
  });
});
```

测试文件涉及了 `ether.js` (合约交互库)和一些测试库(chai，hardhat)。

#### 测试合约

可以运行 `npx hardhat test` 来对合约进行测试。

```Shell
$ npx hardhat test

  Token contract
    Deployment
      ✓ Should set the right owner
      ✓ Should assign the total supply of tokens to the owner
    Transactions
      ✓ Should transfer tokens between accounts (199ms)
      ✓ Should fail if sender doesn’t have enough tokens
      ✓ Should update balances after transfers (111ms)


  5 passing (1s)
```

### 部署合约

我们已经完成了合约的编写和测试，接下来将合约部署到链上。

#### 编写部署脚本

创建 `scripts` 文件夹，并在其路径下创建 `deploy.js` 文件。

复制下方代码到 `deploy.js` 文件里：

```JavaScript
async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const Token = await ethers.getContractFactory("Token");
  const token = await Token.deploy();

  console.log("Token address:", token.address);
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
```

#### 部署合约

可以运行 `npx hardhat run scripts/deploy.js --network <network-name>` 来部署合约到指定的链(network)。

但我们需要先配置下链(网络)信息。

#### 配置链(网络)信息

> 由于以太坊Goerli测试网太堵，我们使用Matic链的mumbai测试网

修改 `hardhat.config.js` 文件如下：

```JavaScript
require("@nomicfoundation/hardhat-toolbox");

// 下面这行写你的开发钱包私钥
const PRIVATE_KEY = "YOUR GOERLI PRIVATE KEY";
module.exports = {
  solidity: "0.8.9",
  networks: {
      mumbai: {
            // 将你的 API URL 写到下面这行
            url: "YOUR API URL",
            accounts: [PRIVATE_KEY]
      }
  }
};
```

注意：开发钱包内不要有主网币，避免丢失。

##### 获得 API URL

我们需要用 API URL 来连接到节点进而发出交易。

有2种主流的 provider 网站：

https://infura.io/

https://www.alchemy.com/

进入对应网页注册好账号后即可获取 API URL

#### 部署合约上链

配置好 `hardhat.config.js` 文件后，运行 `npx hardhat run scripts/deploy.js --network mumbai` 即可部署到链上。具体信息可通过 provider 的 dashboard 查询。

## 结语

以上就是使用hardhat部署简单合约上链的基本流程。

## TODO

- [ ] “编写合约测试”-代码文件写注释。