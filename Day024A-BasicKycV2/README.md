![Coverage](https://img.shields.io/badge/Coverage-100%25-brightgreen)
![Foundry](https://img.shields.io/badge/Foundry-blue)
![Stars](https://img.shields.io/github/stars/BuildsWithKing/21-30-foundry-test-deploy?style=social)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)


# 🧑‍🤝‍🧑 BasicKycV2 — Modular On-chain KYC System (Day 24 Project A - 30 Days Of Solidity Challenge) 👑

A modular and secure on-chain KYC (Know Your Customer) system that allows users to register, update, and view their identity data. Built with a layered architecture (BasicKycV2, KycManager, Utils, Types), full 100% test coverage, and strong access control between users, king and the admin. 

## Table Of Contents
- [BasicKycV2 — Modular On-chain KYC System (Day 24 Project A - 30 Days Of Solidity Challenge)](https://github.com/BuildsWithKing/21-30-foundry-test-deploy/blob/main/Day024A-BasicKycV2/README.md#-basickycv2-day-24-project-a---30-days-of-solidity-)
- [Features](https://github.com/BuildsWithKing/21-30-foundry-test-deploy/blob/main/Day024A-BasicKycV2/README.md#-features)
- [Project Summary](https://github.com/BuildsWithKing/21-30-foundry-test-deploy/blob/main/Day024A-BasicKycV2/README.md#️-project-summary)
- [Project Structure](https://github.com/BuildsWithKing/21-30-foundry-test-deploy/blob/main/Day024A-BasicKycV2/README.md#-project-structure)
- [Usage](https://github.com/BuildsWithKing/21-30-foundry-test-deploy/blob/main/Day024A-BasicKycV2/README.md#-usage)
- [Contract Deployment](https://github.com/BuildsWithKing/21-30-foundry-test-deploy/blob/main/Day024A-BasicKycV2/README.md#-contract-deployment)
- [Tools Used](https://github.com/BuildsWithKing/21-30-foundry-test-deploy/blob/main/Day024A-BasicKycV2/README.md#-tools-used)
- [Testing](https://github.com/BuildsWithKing/21-30-foundry-test-deploy/blob/main/Day024A-BasicKycV2/README.md#-testing)
- [Local Development](https://github.com/BuildsWithKing/21-30-foundry-test-deploy/blob/main/Day024A-BasicKycV2/README.md#️-local-development)
- [Deployment](https://github.com/BuildsWithKing/21-30-foundry-test-deploy/blob/main/Day024A-BasicKycV2/README.md#deployment)
- [License](https://github.com/BuildsWithKing/21-30-foundry-test-deploy/blob/main/Day024A-BasicKycV2/README.md#-license)
- [Author](https://github.com/BuildsWithKing/21-30-foundry-test-deploy/blob/main/Day024A-BasicKycV2/README.md#️-author)
## Features
- Users
  - RegisterMyData
  - UpdateMyData
  - UnregisterMyData
  - MyData
  - MyRegistrationStatus
  - MyRegistrationTimestamp
  - UserRegistrationStatus
  - UserRegistrationTimestamp
  - MyVerificationStatus
  - UserVerificationStatus
  - MyVerificationTimestamp
  - UserVerificationTimestamp
  - MyId
  - UserId
- King
  - AssignAdmin
- King and Admin
  - VerifyUser
  - VerifyManyUsers
  - UnverifyUser
  - UnverifyManyUsers
  - GetUserData
  - GetRegisteredUsers
  - GetVerifiedUsers
  
## Project Summary
BasicKycV2 builds on the previous BasicKyc architecture with testing coverage, modular design, and invariant safety guarantees.

This project demonstrates core Solidity principles, including:

- Structs
- Mappings
- Custom errors
- Events
- Modifiers and helper functions
- Access Control (onlyKing, whenActive, onlyKingAndAdmin)
- Pause and Activate contract
- Rejects ETH using KingRejectETH security module. 
- Kingable security module

> Note: Users can register, update, and unregister their data only when the contract is active.  

## Project Structure

```
|── Day024-BasicKycV2                  # Project Folder
|
|   ├── script
|       ├── DeployBasicKycV2.s.sol     # Foundry deployment script
|
├── src
│   ├── Types.sol                      # Structs, events, and data schema
│   ├── Utils.sol                      # Custom errors and modifier.
│   ├── KycManager.sol                 # Internal logic for registration, updates, verification
│   ├── BasicKycV2.sol                 # Main user-facing contract (extends KycManager)
│
└── test
|   ├── unit
|   |   ├── BasicKycV2UnitTest.t.sol   # Unit tests for user read/write functions
|   |   ├── KingAdminUnitTest.t.sol    # Unit tests for the king and admin read/write functions
|
|   ├── BaseTest.t.sol                 # Shared setup, variables, helper functions
|
|── README.md                          # This file
```

## Usage

### Step 1: Clone repo on [Remix](https://remix.ethereum.org/) 

click on `Import files with HTTPS` and paste the link below
```
https://github.com/BuildsWithKing/21-30-foundry-test-deploy/tree/main/Day024A-BasicKycV2
```
### Step 2: Deploy contract with the first address on Remix as the King and the second as the Admin.

Example:
```
0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
```
### Step 3: Register with any address as a user. 
```
registerMyData(0x1220e0b5c7a9f8d6e4c3b2a1f0e9d8c7b6a5d4c3b2a1f0e9d8c7b6a5d4c3b2a1);
```
### Step 4: View your registration data.
```
myData();
```
### Step 5: Use the Admin's address to verify your identity.
```
verifyUser(0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db);
```
### Step 6: Update your data.
```
updateMyData(0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890);
```
### Step 7: Unregister (remove your data).
```
unregisterMyData();
```
### Step 8: View your registration and verification status.
```
myRegistrationStatus();
myVerificationStatus();
```
### Step 9: View your registration and verification timestamps.
```
myRegistrationTimestamp();
myVerificationTimestamp();
```

## Contract Deployment

- Network: Sepolia and Base Testnet
- Sepolia Contract Address: 0xCEc169C7F500cE04AA1014903fcD984A63554d47
- Base Contract Address: 0xCe8b5D62Dcf6d10d8D4408E6ae91B54db628F295
- [Sepolia Verified](https://sepolia.etherscan.io/address/0xCEc169C7F500cE04AA1014903fcD984A63554d47) ✅
- [Base Verified](https://sepolia.basescan.org/address/0xce8b5d62dcf6d10d8d4408e6ae91b54db628f295) ✅

## Tools Used 
- Language: Solidity `0.8.30`
- IDE: [Remix](https://remix.ethereum.org/) & Visual Studio Code
- Framework: Foundry
- Version Control: Git + GitHub (SSH)

## Testing
Full unit test coverage (100%) for all logic paths:

- User write functions (registerMyData, updateMyData, unregisterMyData)

- User read functions (myData, myId, userVerificationStatus, etc.)

- Admin verification and data access

- Custom error reverts (AlreadyRegistered, SameData, NotRegistered, etc)

## Coverage: 100%
Here is the current test coverage. 
![Coverage](screenshot/coverage.png)

## Local Development
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
forge script script/DeployBasicKycV2.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify

forge script script/DeployBasicKycV2.s.sol --rpc-url $BASE_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
```
> Note: Remapping enabled in foundry.toml 
```
remappings = [
    "buildswithking-security/=lib/buildswithking-security/contracts/access/"
]
```

## License
MIT License - Feel free to fork, learn, remix and build with it. 

## Author

Built by [Michealking](github.com/BuildsWithKing)

Part of my [30 Days of Solidity Challenge](https://github.com/BuildsWithKing/30-days-solidity-challenge)

---

⭐ If this project inspires you, please give it a star on GitHub — it fuels open-source innovation!

---

✅ Day 24 Project A Completed — BasicKycV2 Achieved Full Coverage!


