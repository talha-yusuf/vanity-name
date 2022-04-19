# Vanity Name Registration
## The system which is resistant to front running

[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)

Vanity registration system is deployed on rinkeby testnet for demo purpose,
Demo address is listed below...

```sh
Contract Address: 0x4f61FFA0B4b7Fe38eAFbDb74D1c85910e41f2a2C
```
## Defaults
```sh
Locking Amount: 1 Ether
Locking Period: 5 Minutes
```
## Features

- User will be able to resgiter a vanity name
- System will ensure to protect user from frontrunning
- User can renew the registration upon vanity name duration expiry
- User can reserve the vanity name before registration
- System allows the user to withdraw registration fee securely



## Installation

Recommended versions of the tools are listed below
```sh
Truffle v5.3.0 (core: 5.3.0)
Solidity - 0.8.0 (solc-js)
Node v14.15.3
Web3.js v1.2.9
```
Install the dependencies and devDependencies.

```sh
npm i
```

For deployment and contract verification on rinkeby...
- Paste the private in truffle-config file

```sh
npm run test-deploy
```
- Once the deployment is completed, contracts verification is required
```sh
npm run verify
``` 
## Usage
- User needs to get the hash of vanity name by quering following functions under Read Contract tab
```sh
getHash(VanityName)
```
- Copy that hash, now need to reserve the hash before registration by query following function under Write Contract tab
```sh
reserveHash(nameHash)
```
- Once reserve hash transaction is completed, user needs to generate another transaction with original vanity name by calling
```sh
registerVanityName(VanityName)
```
- Once the locking period is completed, ownership of the vanity and reservation of the hash will be automatically revoked
## Sources
Following resources are used to study the front running prevention techniques.
In many techniques, the example has utilized the strategy of splitting the transaction in two parts.
### Part 1
- Hash of the vanity name is reserved to keep the original data hidden.
### Part 2
- Person who reserved the hash, will be able to send the original data and submit registration fee


| References |
| ------ |
| https://ethereum.stackexchange.com/questions/73570/what-is-the-pre-commit-scheme-to-defeat-frontrunning-attack |
| https://consensys.github.io/smart-contract-best-practices/attacks/frontrunning/#mitigations |
| https://www.securing.pl/en/front-running-attack-in-defi-applications-how-to-deal-with-it |
| https://medium.com/degate/an-analysis-of-ethereum-front-running-and-its-defense-solutions-34ef81ba8456 |
| https://forum.openzeppelin.com/t/protecting-against-front-running-and-transaction-reordering/1314 |




## License

MIT
