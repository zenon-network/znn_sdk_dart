---
sidebar_position: 1
title: Embedded contracts
---

# EmbeddedApi

Accessed via `zenon.embedded`.

Embedded contracts are system contracts built into every Network of Momentum (NoM) node. They implement the core protocol features — Pillars, Sentinels, staking, plasma fusing, token issuance, the accelerator, the bridge, and more — and live at fixed, well-known addresses. Unlike user-deployed smart contracts on other networks, they are part of the node software itself.

`EmbeddedApi` (see `lib/src/api/embedded.dart`) is a thin container that groups one API object per contract. Each namespace exposes two kinds of members:

- **Query methods** — `async` methods that perform a JSON-RPC request against the connected node (for example `embedded.pillar.getAll`) and decode the response into typed models.
- **Contract methods** — synchronous builders that return an *unsigned* `AccountBlockTemplate` encoding a call to the contract's ABI. Nothing is sent to the network until you pass the template to `zenon.send(...)`, which autofills, attaches plasma or proof of work, signs, and publishes it. See [the transactions guide](/guides/transactions).

```dart
final zenon = Zenon();

// Query method: JSON-RPC request to the node
final pillars = await zenon.embedded.pillar.getAll();

// Contract method: build an unsigned block, then sign and publish it
final template = zenon.embedded.pillar.delegate('SomePillar');
await zenon.send(template);
```

## Namespaces

| Namespace | Contract | Page |
|---|---|---|
| `zenon.embedded.pillar` | Pillar registration, delegation, rewards | [Pillar](/api/embedded/pillar) |
| `zenon.embedded.sentinel` | Sentinel registration and rewards | [Sentinel](/api/embedded/sentinel) |
| `zenon.embedded.stake` | ZNN staking for QSR rewards | [Stake](/api/embedded/stake) |
| `zenon.embedded.plasma` | QSR fusing for plasma | [Plasma](/api/embedded/plasma) |
| `zenon.embedded.token` | ZTS token issuance and management | [Token](/api/embedded/token) |
| `zenon.embedded.accelerator` | Accelerator-Z project funding | [Accelerator](/api/embedded/accelerator) |
| `zenon.embedded.htlc` | Hashed timelock contracts | [HTLC](/api/embedded/htlc) |
| `zenon.embedded.bridge` | Cross-chain bridge | [Bridge](/api/embedded/bridge) |
| `zenon.embedded.liquidity` | Liquidity staking and rewards | [Liquidity](/api/embedded/liquidity) |
| `zenon.embedded.spork` | Protocol upgrade sporks | [Spork](/api/embedded/spork) |
| `zenon.embedded.swap` | Legacy swap (Alphanet migration) | [Swap](/api/embedded/swap) |

## Amounts

Token amounts throughout the embedded APIs are `BigInt` values in base units. ZNN and QSR both use `8` decimals (`coinDecimals` in `lib/src/utils/nom_constants.dart`), so `1` ZNN equals `100000000` base units. Use `AmountUtils.extractDecimals('1.5', 8)` to convert a decimal string to base units and `AmountUtils.addDecimals(amount, 8)` for the reverse (see `lib/src/utils/amount.dart`). Other ZTS tokens carry their own `decimals` value in the `Token` model.

## Shared RPC and ABI definitions

Several contracts (pillar, sentinel, stake) expose the same reward and QSR-deposit plumbing: `getUncollectedReward`, `getFrontierRewardByPage`, `getDepositedQsr`, and the `CollectReward`, `DepositQsr`, and `WithdrawQsr` contract methods. The SDK encodes these shared contract methods with the common ABI (`Definitions.common` in `lib/src/embedded/definitions.dart`).

:::note Changed in 1.0.0
The per-contract ABI definitions previously omitted these shared functions: `Update`, `DepositQsr`, `WithdrawQsr`, and `CollectReward` were missing from the pillar and sentinel definitions, and `Update` and `CollectReward` from the stake definition. They are now included, so the SDK's local ABI definitions match the node's. See [the 1.0.0 changelog](/changelog).
:::
