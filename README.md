# starknet_web3_style_oracle

A minimal StarkNet (Cairo 1) smart contract that classifies a Web3 project into one of three conceptual architectures inspired by Aztec-style zk rollups, Zama-style FHE compute stacks, and soundness-first protocol labs.  
The contract takes three preference scores and outputs a single on-chain style index.


# 1. Repository Structure

This repository contains exactly two files:

1. app.cairo – the Cairo 1 smart contract implementing the style oracle  
2. README.md – this documentation


# 2. Overview

starknet_web3_style_oracle is a simple classification oracle.  
You provide three integer preferences:

privacy  
fhe  
soundness

The contract computes three weighted scores corresponding to:

Aztec-style zk privacy rollup  
Zama-style FHE compute stack  
Soundness-first protocol lab  

The highest score determines the output.  
The result is stored on-chain, emitted as an event, and can be queried later.


# 3. Conceptual Background

## 3.1 Aztec-Style zk Privacy Rollups  
Systems with encrypted balances, private transactions, and zk circuits.  
High emphasis on privacy and verifiable correctness.

## 3.2 Zama-Style FHE Compute  
Systems based on fully homomorphic encryption (FHE) that support encrypted compute.  
High emphasis on privacy and FHE-specific compute paths.

## 3.3 Soundness-First Protocol Labs  
Systems built around strict specifications, formal proofs, and correctness-first designs.  
Emphasis on soundness, security audits, and governance clarity.

The contract does not represent real systems but uses these categories as conceptual benchmarks.


# 4. Smart Contract Functions

## 4.1 choose_style(privacy, fhe, soundness)  
External function.  
Returns a style index (0, 1, or 2).  
Stores the result in contract storage.  
Emits an event with the caller and selected style.

## 4.2 get_last_style()  
View function.  
Returns the last caller address and last selected style index.


# 5. Scoring Logic

The three input values (0–10 recommended) are converted to u16 and used to compute three internal scores:

Aztec score  
Strong weight on privacy and moderate on soundness.  
Equation: privacy*3 + soundness*2

Zama score  
Strong weight on privacy and strong weight on FHE.  
Equation: privacy*3 + fhe*3

Soundness-first score  
Very high weight on soundness plus a smaller privacy weight.  
Equation: soundness*4 + privacy

The largest score determines the output index:

0 → Aztec-style  
1 → Zama-style  
2 → Soundness-first  


# 6. Installation Requirements

To compile and deploy this contract you need:

Cairo 1 compiler  
StarkNet-compatible tooling (Scarb or Starknet Foundry)  
StarkNet CLI or an equivalent client  
A StarkNet RPC endpoint (devnet, testnet, or mainnet)  


# 7. Project Setup

Create a new StarkNet project using your preferred toolchain.  
Copy app.cairo into your project directory (usually `src/`).  
Add the contract to your project manifest file (e.g., Scarb.toml).  
Compile the project to ensure app.cairo builds successfully.


# 8. Deployment Steps (Conceptual)

Compile the contract into Sierra and Casm artifacts.  
Deploy it to the desired StarkNet network.  
Record the deployed contract address.  
Use your wallet or StarkNet CLI to interact with choose_style.  


# 9. Using choose_style

choose_style(privacy, fhe, soundness) → style index

Example interpretations:

High privacy + medium FHE + high soundness → likely Aztec-style (0)  
High privacy + high FHE + medium soundness → likely Zama-style (1)  
Medium privacy + low FHE + very high soundness → likely Soundness-first (2)

The contract stores this result and emits a StyleChosen event.


# 10. Querying Stored Results

Call get_last_style() to retrieve:

the most recent caller address  
the most recent selected style  

This allows dashboards, analytics tools, or configuration systems to track which styles are being chosen on-chain.


# 11. Expected Output Behavior

For any input, you should expect:

One of the indices: 0, 1, or 2  
A StyleChosen event emitted  
The storage updated with the caller and selected style  

This pattern enables on-chain decision logs, verifiable preference signaling, and protocol-level meta-configuration.


# 12. Example Use Cases

Classification of deployments  
Feature-flag systems  
Developer dashboards  
Teaching demonstrations  
Web3 architecture experiments integrating zk, FHE, or proof-heavy design ideas  


# 13. Notes and Limitations

This contract is intentionally simple.  
It is not a formal classifier or security tool.  
The scoring model is illustrative and subjective.  
Real Aztec, Zama, or soundness-driven systems involve far more complexity.  
You are encouraged to modify scoring weights or extend the architecture categories.  


# 14. Extending the Repository

You may extend app.cairo to:

Add more style categories  
Store per-caller scores or historical logs  
Compute weighted averages over time  
Expose configuration-dependent behavior based on selected style  


# 15. Summary

starknet_web3_style_oracle demonstrates:

How Cairo 1 smart contracts can encode decision logic  
How simple zk-inspired architectural choices can be made verifiable  
How Web3 concepts like privacy (Aztec), FHE compute (Zama), and soundness-first design can be represented in a small on-chain tool

This repository provides a compact and illustrative example of combining Web3 reasoning with StarkNet smart contract capabilities.
