![Coverage](https://img.shields.io/badge/Coverage-100%25-brightgreen)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

# 🔐FlexiWhitelist (Day 22 Project B - 30 Days Of Solidity) 👑

This modular contract allows users to register to be whitelisted, unregister when no longer interested, retrieve registration & whitelist status and claim ETH mistakenly sent to the contract. While king (deployer) can whitelist, revoke and retrieve registered and whitelisted users. This contract is well gas optimized and built with security in mind. 

### 📑 Table of Contents

- [FlexiWhitelist (Day 22 Project B - 30 Days Of Solidity)](https://github.com/BuildsWithKing/21-30-foundry-test-deploy/tree/main/Day022B-FlexiWhitelist#flexiwhitelist-day-22-project-b---30-days-of-solidity-)
- [Features](https://github.com/BuildsWithKing/21-30-foundry-test-deploy/tree/main/Day022B-FlexiWhitelist#-features)
- [Project Summary](https://github.com/BuildsWithKing/21-30-foundry-test-deploy/tree/main/Day022B-FlexiWhitelist#%EF%B8%8F-project-summary)
- [Project Structure](https://github.com/BuildsWithKing/21-30-foundry-test-deploy/tree/main/Day022B-FlexiWhitelist#-project-structure)
- [Usage](https://github.com/BuildsWithKing/21-30-foundry-test-deploy/tree/main/Day022B-FlexiWhitelist#-usage)
- [Contract Deployment](https://github.com/BuildsWithKing/21-30-foundry-test-deploy/tree/main/Day022B-FlexiWhitelist#-contract-deployment)
- [Tools Used](https://github.com/BuildsWithKing/21-30-foundry-test-deploy/tree/main/Day022B-FlexiWhitelist#%E2%80%8D-tools-used)
- [Testing](https://github.com/BuildsWithKing/21-30-foundry-test-deploy/tree/main/Day022B-FlexiWhitelist#-testing)
- [Local Development](https://github.com/BuildsWithKing/21-30-foundry-test-deploy/tree/main/Day022B-FlexiWhitelist#%E2%80%8D-local-development)
- [Deployment](https://github.com/BuildsWithKing/21-30-foundry-test-deploy/tree/main/Day022B-FlexiWhitelist#deployment)
- [License](https://github.com/BuildsWithKing/21-30-foundry-test-deploy/tree/main/Day022B-FlexiWhitelist#-license)
- [Audit-Lite](https://github.com/BuildsWithKing/21-30-foundry-test-deploy/tree/main/Day022B-FlexiWhitelist#-audit-lite)
- [Author](https://github.com/BuildsWithKing/21-30-foundry-test-deploy/tree/main/Day022B-FlexiWhitelist#%E2%80%8D-author)
- [Project Journey](https://github.com/BuildsWithKing/21-30-foundry-test-deploy/tree/main/Day022B-FlexiWhitelist#%EF%B8%8F-project-journey)

## ✅ Features

- Users 
  - Register for whitelist
  - Unregister for whitelist
  - Withdraw ETH mistakenly sent 
  - Check personal registration status
  - Check personal whitelist status
  - Check if whitelisted (Callable by everyone)
  - Check personal balance
  - Check contract balance
  - Is contract active
  - Get Existing users count
  - Get Life time users

- King
  - Whitelist user address
  - Revoke user whitelist
  - Activate contract 
  - Pause contract 
  - Get registered users
  - Get whitelisted users

## ✍️ Project Summary
This project demonstrates core Solidity principles, including:

- Structs
- Mappings
- Custom errors
- Events
- Modifiers and helper functions
- Access Control (onlyKing, isActive, onlyRegistered)
- Ownership Transfer & renouncement
- Pause and Activate contract
- Receive & Fallback functions
- Kingable security module
- Reentrancy guard (nonReentrant)

> Note: Once kingship is renounced, all king-only actions are locked (the owner is set to the zero address)

## 📂 Project Structure

```
|── Day022B-FlexiWhitelist      #Project Folder
|
|   ├── Script
|   ├── DeployFlexiWhitelist.s.sol    
|
├── src
│   ├── Types.sol           # Centralized type definitions (variables, structs, enums, mappings)
│   ├── Utils.sol           # Custom errors, events, modifiers, Internal helper functions, receive and fallback.
|   |── WhitelistManager.sol  # Handles users and king CRUD operation (Internally)
│   ├── FlexiWhitelist.sol    # Main contract with users and king CRUD logic (Externally). 
│  
│
└── test
|   ├── UnitTest
|           |── BaseTest.t.sol      # Main test contract with variables, modifiers, setUp and users write functions. 
|           |── WhitelistTest.t.sol  # Unit test contract for users read functions. 
|           |── KingUtilsTest.t.sol  # Unit test contract for King's write, read, receive and fallback function. 
|           |── RejectETHTest.t.sol  # Unit test contract to simulate failed ETH withdrawal.
|          
|    |──FuzzTest
|           |── FlexiWhitelistFuzzTest.t.sol   # Fuzz test contract for flexi whitelist contract.  
|   
|── ReadMe.md                          # This file.
```

## 🧪 Usage
### Step 1: Clone repo on [Remix](https://remix.ethereum.org/) 

### Step 2: Deploy contract with the first address on remix as king. See example below 👇 

```soldity
0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
```

### Step 3: Register with any of the addresses on remix 
```solidity
registerForWhitelist();
```

### Step 4: Use king's address to whitelist any registered user. 
```solidity
whitelistUserAddress(
    0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
);
```

### Step 5: Use king's address to get registered users address
```solidity
getRegisteredUsers(
    0,2
);
```
### Step 6: Use king's address to get whitelisted users address
```solidity
getWhitelistedUsers(
    0,2
);
```

### Step 7: Use king's address to pause contract
```solidity
pauseContract();
```

### Step 8: Use king's address to activate contract
```solidity
activateContract();
```

## 💻 Contract Deployment

- Network: Sepolia Testnet
- Contract Address: 0xC6AB390D59b177eE17B002a69bd6C6d3b90Fd196
- Status: [Verified](https://sepolia.etherscan.io/address/0xC6AB390D59b177eE17B002a69bd6C6d3b90Fd196) ✅

## 🛠 Tools Used 
- Language: Solidity `0.8.30`
- IDE: [Remix](https://remix.ethereum.org/) & Visual Studio Code
- FrameWork: Foundry
- Version Control: Git + GitHub (SSH)

## 🧪 Testing
This project includes full unit and fuzz test coverage:
- Register, unregister, whitelist, revoke, etc. 
- Custom error reverts
- Events emissions
- King-only access restrictions
- Receive and fallback behaviour

## Coverage: 100%
![alt text](Screenshot/image.png)

## 👨‍💻 Local Development
To run this project locally:
- Clone this repo
- Install Foundry
- Run:

```
forge install
```
 
### Compile project
```
forge compile 
forge build
```

### Run tests
```
forge test
```

### Check Coverage with:
```
forge coverage
```

### Gas snapshot
```
forge snapshot
```

## Deployment
Deployed via Foundry script:

```
forge script script/DeployFlexiWhitelist.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
```
> Note: Remapping enabled in foundry.toml 
```
remappings = [
    "buildswithking-security/=lib/buildswithking-security/contracts/access/"
]
```

## 🪪 License
MIT License - Feel free to fork, learn, remix and build with it. 

## 🔍 Audit-Lite

This project went through a self-review and audit-lite process to catch common Solidity risks:

- ✅ No reentrancy vulnerabilities found  
- ✅ Proper access control with onlyKing modifier  
- ✅ Fuzz + unit tests cover whitelist & registration logic  
- ⚠ Minor gas optimizations possible in storage read operations.   

For a detailed breakdown, see the full [AUDIT-LITE.md](./AUDIT-LITE.md).

## 👨‍💻 Author

Built with 🔥 by [Michealking](github.com/BuildsWithKing)

Part of my [30 Days of Solidity Challenge](https://github.com/BuildsWithKing/30-days-solidity-challenge)

## ✍️ Project Journey

While building this contract, i explored the feature `withdrawMistakenETH` which enables users claim ETH mistakenly sent to contract without the need of any third party (king) and it was a success. I got really excited when it worked successfully. 

--- 
### Kindly give credit ⭐ if this inspired your learning journey.
---

✅ Day 22 Project B Completed!
