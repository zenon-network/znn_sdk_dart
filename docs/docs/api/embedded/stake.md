---
sidebar_position: 4
title: Stake
---

# StakeApi

Accessed via `zenon.embedded.stake`.

The stake embedded contract locks ZNN for a chosen duration and pays QSR rewards. This namespace queries staking entries and rewards, and builds stake, cancel, and collect transactions.

## Methods

| Method | RPC | Description |
|---|---|---|
| `getEntriesByAddress` | `embedded.stake.getEntriesByAddress` | Paginated staking entries for an address |
| `getUncollectedReward` | `embedded.stake.getUncollectedReward` | Unclaimed rewards for an address |
| `getFrontierRewardByPage` | `embedded.stake.getFrontierRewardByPage` | Per-epoch reward history for an address |

### Contract methods

Each returns an unsigned `AccountBlockTemplate` addressed to the stake contract; pass it to `zenon.send(...)` (see [the transactions guide](/guides/transactions)).

| Method | Description |
|---|---|
| `stake` | Lock ZNN for a duration; minimum `stakeMinZnnAmount` (`1` ZNN) |
| `cancel` | Cancel an expired staking entry by id |
| `collectReward` | Collect uncollected QSR rewards |

## Query methods

### getEntriesByAddress

```dart
Future<StakeList> getEntriesByAddress(Address address,
    {int pageIndex = 0, int pageSize = rpcMaxPageSize})
```

Returns the staking entries of `address` as a `StakeList`: `totalAmount` and `totalWeightedAmount` (`BigInt`), `count`, and a list of `StakeEntry` (`amount`, `weightedAmount`, `startTimestamp`, `expirationTimestamp`, `address`, `id`). Longer durations produce a higher `weightedAmount` for the same `amount`. `rpcMaxPageSize` is `1024`.

### getUncollectedReward

```dart
Future<UncollectedReward> getUncollectedReward(Address address)
```

Returns the unclaimed rewards for `address` (`znnAmount` and `qsrAmount`, both `BigInt`); staking rewards are paid in QSR.

### getFrontierRewardByPage

```dart
Future<RewardHistoryList> getFrontierRewardByPage(Address address,
    {int pageIndex = 0, int pageSize = rpcMaxPageSize})
```

Returns the per-epoch reward history for `address`.

## Contract methods

### stake

```dart
AccountBlockTemplate stake(int durationInSec, BigInt amount)
```

Builds a `Stake` call that sends `amount` ZNN (base units, `8` decimals) to the stake contract, locked for `durationInSec` seconds. Constraints from `lib/src/embedded/constants.dart`:

- minimum amount: `stakeMinZnnAmount` (`1` ZNN, i.e. `100000000` base units)
- duration is measured in 30-day units (`stakeTimeUnitSec` = `2592000` seconds), from `stakeTimeMinSec` (1 unit) to `stakeTimeMaxSec` (12 units)

### cancel

```dart
AccountBlockTemplate cancel(Hash id)
```

Builds a `Cancel` call for the staking entry with hash `id` (see `StakeEntry.id`). The entry can be cancelled once its `expirationTimestamp` has passed; the locked ZNN is then sent back to the staker.

### collectReward

```dart
AccountBlockTemplate collectReward()
```

Builds a `CollectReward` call (encoded with the common ABI, `Definitions.common`) that claims the sender's uncollected rewards.

:::note Changed in 1.0.0
The stake ABI definition (`Definitions.stake`) previously omitted the `Update` and `CollectReward` functions; they are now included so the local ABI matches the node's contract. See [the 1.0.0 changelog](/changelog).
:::

## Examples

Stake `10` ZNN for 3 months and inspect existing entries:

```dart
final zenon = Zenon();
final address = await zenon.defaultKeyPair!.getAddress();

// 3 x 30-day units
await zenon.send(zenon.embedded.stake.stake(
    3 * stakeTimeUnitSec, AmountUtils.extractDecimals('10', coinDecimals)));

final entries = await zenon.embedded.stake.getEntriesByAddress(address);
print('Staked total: '
    '${AmountUtils.addDecimals(entries.totalAmount, coinDecimals)} ZNN');
```

Cancel an expired entry and collect rewards:

```dart
final zenon = Zenon();
final address = await zenon.defaultKeyPair!.getAddress();

final entries = await zenon.embedded.stake.getEntriesByAddress(address);
final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
for (final entry in entries.list) {
  if (entry.expirationTimestamp <= now) {
    await zenon.send(zenon.embedded.stake.cancel(entry.id));
  }
}

await zenon.send(zenon.embedded.stake.collectReward());
```
