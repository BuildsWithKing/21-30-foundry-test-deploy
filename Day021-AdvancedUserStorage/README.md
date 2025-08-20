# 🧑‍🤝‍🧑 AdvancedUserStorage (Day 21 Project A - 30 Days Of Solidity)
A modular, test-driven Solidity project showcasing advanced concepts like structs, mappings, modifiers, custom errors, helper utilities, and rejection simulations.
Built with Foundry for modern Ethereum smart contract development.

## 🚀 Project Summary
This project demonstrates core Solidity principles, including:
- Structs
- Mappings
- Custom Errors
- Events
- Access Control (OnlyOwner)
- Receive & Fallback Functions
- ETH Withdrawal Logic

### ✅ Features
- Store user data
- Update user data
- Retrieve personal data
- Retrieve global data (by owner)
- Delete personal
- Delete global data (by owner)
- ETH deposit (Receive & Fallback) and withdrawal
- Custom errors for optimized gas usage

## 💻 Contract Deployment

- *Network*: Sepolia Testnet
- *Contract Address*: 0x8A536142B0401F08d8Eee77F0983E09A3af5b229
- *Status*: Verified✅

## 🛠 Tools Used

- Language: Solidity `^0.8.30`
- IDE: [Remix](https://remix.ethereum.org/) + Visual Studio Code  
- Version Control: Git + GitHub (SSH)
- Foundry


## 🧪 Testing

The project includes a full Foundry test suite covering:

- User data storage, update, retrieval, and deletion

- Custom error reverts

- Owner-only access restrictions

- ETH deposits and withdrawals

---
Coverage: 100%

![alt text](<Screenshot/WhatsApp Image 2025-08-19 at 20.36.21_e6fe3d60.jpg>)

---

## 🧪 Local Development

To run this project locally:

- Clone the repo  
- Install Foundry  
- Run the following commands:


## 🛠 Installation

Make sure you have Foundry installed.

### Install dependencies
```
forge install
```
### Build project
```
forge build
```
### Run tests
```
forge test -vvv
```
### Check Coverage with:
```
forge coverage 
```

## 🛠 Deployment

Deployed via Foundry script:

```
forge script script/DeployAdvancedUserStorage.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
```


### 📂 Project Structure

```
├── script
|   ├── DeployAdvancedUserStorage.s.sol    
|
├── src
│   ├── Types.sol                 # Centralized type definitions (structs, enums, errors)
│   ├── Utils.sol                 # Internal helper functions (validation, address checks)
│   ├── AdvancedUserStorage.sol   # Main contract with CRUD logic for user data
│   ├── RejectETH.sol             # Rejects ETH to simulate failed withdrawals
│
└── test
    ├── AdvancedUserStorageTest.t.sol # Full test suite for AdvancedUserStorage.
    └── UtilsTest.t.sol             # Full test suite for Utils. 
```

## 📌 Contracts

- Types.sol → Central hub for structs and enums.

- Utils.sol → Validation & helper functions.

- AdvancedUserStorage.sol → Core CRUD functionality for user data.

- RejectETH.sol → Simulates failed ETH transfers.

- AdvancedUserStorageTest.sol → Main test suite.

- UtilsTest.t.sol → Unit tests for utilities.

---

## 📦Use Cases

This contract could be used for decentralized user profiles, on-chain identity systems, or permissioned data registries.

## 📄 License

MIT License – Feel free to learn, remix, and build with it.

---

## ✍ Author

Built with 🔥 by [@BuildsWithKing](https://github.com/BuildsWithKing)   
Part of the [30 Days of Solidity Challenge](https://github.com/BuildsWithKing/30-days-solidity-challenge)

---

## 🚀 Project Journey  

I dedicated *7 days of intense building* to create this project.  
Every day came with new challenges, from debugging hidden edge cases to refining the structure.  
This marks a milestone in my 30 Days Solidity Challenge.

---

🙏 Kindly give credit ⭐ if this inspired your learning journey.

---

## ✅ Day 21 (Project A) Completed!