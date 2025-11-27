# starknet_web3_style_oracle

starknet_web3_style_oracle is a minimal Cairo 1 smart contract for StarkNet (zk-rollup / ZK-L2). It acts as a tiny “style oracle” for Web3 architectures and is conceptually inspired by:

Aztec-style zk privacy rollups (encrypted balances, zk circuits over L1)
Zama-style FHE compute stacks (fully homomorphic encryption with Web3 anchoring)
Soundness-first protocol labs (formal specifications and correctness-first design)

The contract takes three small preference scores as input and returns a single on-chain style index that can be consumed by other StarkNet contracts or off-chain tooling.


Repository structure

There are exactly two files in this repository.

1. app.cairo – the StarkNet contract (Cairo 1) with the main logic
2. README.md – this documentation, including installation, usage, expected result and notes


High-level behaviour

The contract exposes two interfaces:

External function

choose_style(privacy: u8, fhe: u8, soundness: u8) -> u8

View function

get_last_style() -> (ContractAddress, u8)

Inputs to choose_style

privacy (0–10 recommended range)
How important strong privacy and encryption are for this project.
Higher values suggest Aztec-style or Zama-style designs.

fhe (0–10 recommended range)
How important fully homomorphic encryption (FHE) is.
Higher values push toward Zama-style FHE compute stacks.

soundness (0–10 recommended range)
How important strong soundness, proofs and formal reasoning are.
Higher values push toward soundness-first protocol lab designs.

Output from choose_style

A single u8 style index with the following meaning:

0 – Aztec-style zk privacy rollup
1 – Zama-style FHE compute stack
2 – Soundness-first protocol lab

In addition, the contract stores in its storage:

last_caller – the address of the account or contract that last called choose_style
last_style – the last style index that was computed

The view function get_last_style returns both values so that anyone can query the most recent decision.


Conceptual scoring logic

The contract converts each u8 input into u16 values and computes three internal scores:

Aztec-style score
Weighted heavily toward privacy and moderately toward soundness.
Reflects a rollup like Aztec, where zk-powered privacy is the core product and soundness is an essential safety property.

Zama-style score
Weighted strongly toward both privacy and FHE.
Represents a stack where encrypted compute and FHE pipelines are first-class citizens, while still existing in a Web3 context.

Soundness-first score
Weighted most heavily toward soundness, with a secondary weight on privacy.
Fits research-heavy or lab-style protocols where formal proofs and clearly specified semantics matter most.

The style with the highest score is chosen and returned. In case of ties, the earlier style in the evaluation order wins (Aztec first, then Zama, then soundness).


Installation prerequisites

To build and deploy this contract you need:

Cairo 1 toolchain compatible with StarkNet
StarkNet CLI or a modern equivalent (for example, Starknet Foundry / Scarb plus associated tooling)
An RPC endpoint or gateway to a StarkNet network (local devnet, testnet, or mainnet)
Basic familiarity with compiling and deploying StarkNet contracts

The exact installation commands depend on your chosen toolchain (Scarb, Starknet Foundry, or older cairo-lang). Refer to the official StarkNet and Cairo 1 documentation to install:

Rust and Cargo (if required by your toolchain)
The Cairo 1 compiler
Project management tooling such as Scarb
StarkNet deployment tools


Project setup

Create a new StarkNet / Cairo 1 project using your chosen toolchain.
Place app.cairo into the src or contracts directory according to your project layout.
Update your project manifest (for example, Scarb.toml) so that web3_style_oracle is included in the list of contracts to build.
Compile the project using the appropriate build command for your tooling to verify that the contract compiles successfully.


Deployment (conceptual)

The detailed deployment process depends on the current StarkNet toolchain you use, but the general steps are:

Connect your wallet or key management system to your chosen StarkNet network (local devnet, testnet, or mainnet).
Use the compile output (Sierra/Casm artifacts) from your project to deploy web3_style_oracle.aleo (contract name web3_style_oracle).
Make note of the deployed contract address on StarkNet.
Use your wallet or client to invoke the external function choose_style on the deployed contract.


How to use choose_style in practice

When calling choose_style you pass three integers for privacy, fhe and soundness. A typical flow could look like this (described conceptually rather than as shell commands):

Decide your project priorities. For example:

Example A (privacy-heavy zk rollup like Aztec):
privacy = 9
fhe = 2
soundness = 8

Example B (FHE-centric analytics stack like Zama-inspired designs):
privacy = 9
fhe = 9
soundness = 6

Example C (pure protocol research with strong proofs):
privacy = 5
fhe = 1
soundness = 10

Call choose_style with your chosen triple on StarkNet.
The contract computes the scores, chooses the best style index, stores it in storage, emits a StyleChosen event, and returns the style index to the caller.
You can read the on-chain event logs or use the return value directly in your client.

Later, anyone can call get_last_style to see the last caller address and last style index.


Expected results for conceptual examples

For the given conceptual examples (actual results depend only on the arithmetic coded in app.cairo):

Example A: privacy 9, fhe 2, soundness 8
Likely output: 0
Interpretation: The oracle suggests an Aztec-style zk privacy rollup best matches these preferences.

Example B: privacy 9, fhe 9, soundness 6
Likely output: 1
Interpretation: The oracle suggests a Zama-style FHE compute stack is the best fit.

Example C: privacy 5, fhe 1, soundness 10
Likely output: 2
Interpretation: The oracle suggests a soundness-first protocol lab design.

These are not guarantees about any real system. They simply reflect the weights inside compute_style.


Potential integrations in Web3

Some ideas for integrating starknet_web3_style_oracle inside broader Web3 and StarkNet tooling:

Configuration gating
Other StarkNet contracts can query the oracle and adjust behaviour based on the returned style index. For example:
If style = 0, default to privacy-heavy paths, more aggressive zk proof aggregation, or Aztec-like UX patterns.
If style = 1, emphasize FHE compatibility and off-chain encrypted compute pipelines.
If style = 2, require additional soundness checks, such as extra governance steps or proof verification options.

Developer dashboards
Off-chain services can call get_last_style and display the last recorded preferences and style classification in a dashboard that compares Aztec-style, Zama-style, and soundness-first projects.

Research and teaching
The contract can be used as a teaching example for:
Mapping abstract Web3 design trade-offs into concrete StarkNet state and events.
Discussing how zk-rollups (like StarkNet and Aztec) and FHE stacks (like Zama) relate to high-level architectural choices.


Notes, limitations and safety

This contract is intentionally minimal and uses simple integer arithmetic. It is not a formal advisor, classifier, or threat modeling engine. Do not use it as the sole basis for economic or security decisions.

The style mapping is opinionated and generic. Real projects in the Aztec or Zama ecosystems or in soundness-focused research labs may not fit neatly into the three categories.

If you intend to extend or reuse this repository:

You can adjust the scoring weights in compute_style to reflect your own view of privacy, FHE, and soundness priorities.
You can add more categories (for example, performance-first or UX-first) and extend the style index beyond 0, 1 and 2.
You can store more metadata in storage, such as per-caller preferences or aggregated statistics.

Always perform thorough security reviews and protocol analysis for real Web3, Aztec-style, Zama-style, or soundness-first deployments. This repository is designed as a small, didactic StarkNet example tying Cairo 1 contracts to the conceptual space of zk-rollups, FHE systems and soundness-driven protocol design.
::contentReference[oaicite:0]{index=0}
