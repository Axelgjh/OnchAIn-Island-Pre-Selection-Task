# 🛡️ Simplified MultiSig Wallet (EIP-712 Compatible)

This repository contains a gasless-compatible MultiSig Wallet smart contract built for the OnchAIn Island Hackathon Challenge 1.

## 📜 Features

- Multi-signature transaction execution
- EIP-712 structured data support (dApp-side)
- Secure confirmation, execution, and revocation
- Event-driven architecture
- Simple and easy to integrate

## 🛠 Tech Stack

- Solidity ^0.8.20
- Compatible with EIP-712 (off-chain signing)
- Can integrate with a Forwarder for meta-transactions

## 🔧 Usage

Deploy with a list of owner addresses and the required confirmation count.

```solidity
new MultiSigWallet([owner1, owner2, owner3], 2)
```

## ✍️ Meta-Tx Signing (EIP-712)

The dApp layer must implement:

- `domainSeparator`
- `typedDataHash`
- Meta-signature recovery and replay protection

This repo focuses on the on-chain wallet. For full flow, integrate with a TrustedForwarder.

## 🔐 Security Notes

- Only owners can confirm/execute
- Transactions require minimum `required` confirmations
- Built-in replay protection via tx IDs

## 📄 License

MIT
