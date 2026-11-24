---
sidebar_position: 3
title: Sentinel
---

# SentinelApi

Accessed via `zenon.embedded.sentinel`.

Sentinels are full nodes registered with the sentinel embedded contract. This namespace queries active sentinels and their rewards, and builds registration, revocation, and reward transactions.

## Methods

| Method | RPC | Description |
|---|---|---|
| `getAllActive` | `embedded.sentinel.getAllActive` | Paginated list of active sentinels |
| `getByOwner` | `embedded.sentinel.getByOwner` | The sentinel owned by an address, or `null` |
| `getDepositedQsr` | `embedded.sentinel.getDepositedQsr` | QSR deposited toward registration by an address |
| `getUncollectedReward` | `embedded.sentinel.getUncollectedReward` | Unclaimed rewards for an address |
| `getFrontierRewardByPage` | `embedded.sentinel.getFrontierRewardByPage` | Per-epoch reward history for an address |

### Contract methods

Each returns an unsigned `AccountBlockTemplate` addressed to the sentinel contract; pass it to `zenon.send(...)` (see [the transactions guide](/guides/transactions)).

| Method | Description |
|---|---|
| `register` | Register a sentinel; sends `sentinelRegisterZnnAmount` (`5000` ZNN) |
| `revoke` | Revoke the sender's sentinel |
| `collectReward` | Collect uncollected rewards |
| `depositQsr` | Deposit QSR toward the registration cost (`sentinelRegisterQsrAmount` is `50000` QSR) |
| `withdrawQsr` | Withdraw previously deposited QSR |

## Query methods

### getAllActive

```dart
Future<SentinelInfoList> getAllActive({int pageIndex = 0, int pageSize = rpcMaxPageSize})
```

Returns active sentinels as a `SentinelInfoList` (`count` plus a list of `SentinelInfo`). `SentinelInfo` carries `owner`, `registrationTimestamp`, `isRevocable`, `revokeCooldown`, and `active`. `rpcMaxPageSize` is `1024`.

### getByOwner

```dart
Future<SentinelInfo?> getByOwner(Address owner)
```

Returns the sentinel registered by `owner`, or `null` if the address has none.

### getDepositedQsr

```dart
Future<BigInt> getDepositedQsr(Address address)
```

Returns the QSR `address` has deposited into the sentinel contract toward a registration.

### getUncollectedReward

```dart
Future<UncollectedReward> getUncollectedReward(Address address)
```

Returns the unclaimed rewards for `address` (`znnAmount` and `qsrAmount`, both `BigInt`).

### getFrontierRewardByPage

```dart
Future<RewardHistoryList> getFrontierRewardByPage(Address address,
    {int pageIndex = 0, int pageSize = rpcMaxPageSize})
```

Returns the per-epoch reward history for `address`.

## Contract methods

### register

```dart
AccountBlockTemplate register()
```

Builds a `Register` call that sends `sentinelRegisterZnnAmount` (`5000` ZNN) to the sentinel contract. Registration also requires a prior QSR deposit of `sentinelRegisterQsrAmount` (`50000` QSR) via `depositQsr`.

### revoke

```dart
AccountBlockTemplate revoke()
```

Builds a `Revoke` call (zero ZNN) for the sender's sentinel. Revocation is only accepted while the sentinel is revocable (`isRevocable` / `revokeCooldown` on `SentinelInfo`).

### collectReward, depositQsr, withdrawQsr

```dart
AccountBlockTemplate collectReward()
AccountBlockTemplate depositQsr(BigInt amount)
AccountBlockTemplate withdrawQsr()
```

Shared reward and deposit plumbing, encoded with the common ABI (`Definitions.common`). `depositQsr` sends `amount` QSR (base units) to the sentinel contract.

:::note Changed in 1.0.0
The sentinel ABI definition (`Definitions.sentinel`) previously omitted the `Update`, `DepositQsr`, `WithdrawQsr`, and `CollectReward` functions; they are now included so the local ABI matches the node's contract. See [the 1.0.0 changelog](/changelog).
:::

## Example

Deposit QSR, register a sentinel, and later collect rewards:

```dart
final zenon = Zenon();
final address = await zenon.defaultKeyPair!.getAddress();

// 50000 QSR must be deposited before registering
final deposited = await zenon.embedded.sentinel.getDepositedQsr(address);
if (deposited < sentinelRegisterQsrAmount) {
  await zenon.send(zenon.embedded.sentinel
      .depositQsr(sentinelRegisterQsrAmount - deposited));
}

// Sends 5000 ZNN (sentinelRegisterZnnAmount) with the Register call
await zenon.send(zenon.embedded.sentinel.register());

// Later: check and collect rewards
final reward = await zenon.embedded.sentinel.getUncollectedReward(address);
if (reward.znnAmount > BigInt.zero || reward.qsrAmount > BigInt.zero) {
  await zenon.send(zenon.embedded.sentinel.collectReward());
}
```
