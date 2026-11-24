---
sidebar_position: 2
title: Pillar
---

# PillarApi

Accessed via `zenon.embedded.pillar`.

Pillars are the momentum-producing nodes of the Network of Momentum. This namespace queries the pillar registry, delegation state, and rewards, and builds transactions for registering, updating, revoking, and delegating to pillars.

## Methods

| Method | RPC | Description |
|---|---|---|
| `getAll` | `embedded.pillar.getAll` | Paginated list of all pillars |
| `getByOwner` | `embedded.pillar.getByOwner` | Pillars owned by an address |
| `getByName` | `embedded.pillar.getByName` | A single pillar by name, or `null` |
| `checkNameAvailability` | `embedded.pillar.checkNameAvailability` | Whether a pillar name is free |
| `getDelegatedPillar` | `embedded.pillar.getDelegatedPillar` | The pillar an address delegates to, or `null` |
| `getQsrRegistrationCost` | `embedded.pillar.getQsrRegistrationCost` | Current QSR cost to register a pillar |
| `getDepositedQsr` | `embedded.pillar.getDepositedQsr` | QSR deposited toward registration by an address |
| `getUncollectedReward` | `embedded.pillar.getUncollectedReward` | Unclaimed rewards for an address |
| `getFrontierRewardByPage` | `embedded.pillar.getFrontierRewardByPage` | Per-epoch reward history for an address |
| `getPillarEpochHistory` | `embedded.pillar.getPillarEpochHistory` | Epoch history for a named pillar |
| `getPillarsHistoryByEpoch` | `embedded.pillar.getPillarsHistoryByEpoch` | All pillars' stats for a given epoch |

### Contract methods

Each returns an unsigned `AccountBlockTemplate` addressed to the pillar contract; pass it to `zenon.send(...)` (see [the transactions guide](/guides/transactions)).

| Method | Description |
|---|---|
| `register` | Register a pillar; sends `pillarRegisterZnnAmount` (`15000` ZNN) |
| `registerLegacy` | Register using a legacy swap public key and signature; sends `15000` ZNN |
| `updatePillar` | Change producer/reward addresses and reward percentages |
| `revoke` | Revoke a pillar by name |
| `delegate` | Delegate the sender's ZNN balance weight to a pillar |
| `undelegate` | Remove the sender's delegation |
| `collectReward` | Collect uncollected rewards |
| `depositQsr` | Deposit QSR toward the registration cost |
| `withdrawQsr` | Withdraw previously deposited QSR |

## Query methods

### getAll

```dart
Future<PillarInfoList> getAll({int pageIndex = 0, int pageSize = rpcMaxPageSize})
```

Returns the pillar registry as a `PillarInfoList` (`count` plus a list of `PillarInfo`). `PillarInfo` includes `name`, `rank`, `type`, `ownerAddress`, `producerAddress`, `withdrawAddress`, reward-sharing percentages, revocation state, `weight` (`BigInt`), and current-epoch momentum stats. `rpcMaxPageSize` is `1024`.

### getByOwner

```dart
Future<List<PillarInfo>> getByOwner(Address address)
```

Returns all pillars owned by `address`.

### getByName

```dart
Future<PillarInfo?> getByName(String name)
```

Returns the pillar named `name`, or `null` if it does not exist.

### checkNameAvailability

```dart
Future<bool> checkNameAvailability(String name)
```

Returns `true` if `name` can still be registered. Valid names are at most `40` characters and must match `^([a-zA-Z0-9]+[-._]?)*[a-zA-Z0-9]$`.

### getDelegatedPillar

```dart
Future<DelegationInfo?> getDelegatedPillar(Address address)
```

Returns the delegation of `address` as a `DelegationInfo` (`name`, `status`, `weight`), or `null` if the address is not delegating. `DelegationInfo.isPillarActive()` is `true` when `status == 1`.

### getQsrRegistrationCost

```dart
Future<BigInt> getQsrRegistrationCost()
```

Returns the current QSR amount that must be deposited before registering a pillar. The base cost is `pillarRegisterQsrAmount` (`150000` QSR) and increases with each registered pillar.

### getDepositedQsr

```dart
Future<BigInt> getDepositedQsr(Address address)
```

Returns the QSR `address` has deposited into the pillar contract toward a registration.

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

Returns the per-epoch reward history for `address`, newest first.

### getPillarEpochHistory

```dart
Future<PillarEpochHistoryList> getPillarEpochHistory(String name,
    {int pageIndex = 0, int pageSize = rpcMaxPageSize})
```

Returns per-epoch statistics (produced/expected momentums, reward percentages, weight) for the pillar named `name`.

### getPillarsHistoryByEpoch

```dart
Future<PillarEpochHistoryList> getPillarsHistoryByEpoch(int epoch,
    {int pageIndex = 0, int pageSize = rpcMaxPageSize})
```

Returns the statistics of all pillars for a single `epoch`.

## Contract methods

### register and registerLegacy

```dart
AccountBlockTemplate register(
    String name, Address producerAddress, Address rewardAddress,
    [int giveBlockRewardPercentage = 0, int giveDelegateRewardPercentage = 100])

AccountBlockTemplate registerLegacy(String name, Address producerAddress,
    Address rewardAddress, String publicKey, String signature,
    [int giveBlockRewardPercentage = 0, int giveDelegateRewardPercentage = 100])
```

Builds a `Register` (or `RegisterLegacy`) call that sends `pillarRegisterZnnAmount` (`15000` ZNN) to the pillar contract. Registration also requires that the sender has already deposited the QSR registration cost via `depositQsr` — check the required amount with `getQsrRegistrationCost` and the current deposit with `getDepositedQsr`.

### updatePillar

```dart
AccountBlockTemplate updatePillar(
    String name,
    Address producerAddress,
    Address rewardAddress,
    int giveBlockRewardPercentage,
    int giveDelegateRewardPercentage)
```

Builds an `UpdatePillar` call (zero ZNN) that changes the pillar's producer address, reward address, and reward-sharing percentages.

### revoke

```dart
AccountBlockTemplate revoke(String name)
```

Builds a `Revoke` call for the pillar named `name`. Revocation is only accepted while the pillar is in a revocable window (`isRevocable` / `revokeCooldown` on `PillarInfo`).

### delegate and undelegate

```dart
AccountBlockTemplate delegate(String name)
AccountBlockTemplate undelegate()
```

`delegate` builds a `Delegate` call that assigns the sender's ZNN balance as delegation weight to the pillar named `name`; `undelegate` removes it. Neither transfers tokens.

### collectReward, depositQsr, withdrawQsr

```dart
AccountBlockTemplate collectReward()
AccountBlockTemplate depositQsr(BigInt amount)
AccountBlockTemplate withdrawQsr()
```

Shared reward and deposit plumbing, encoded with the common ABI (`Definitions.common`). `depositQsr` sends `amount` QSR (base units) to the pillar contract; `withdrawQsr` returns any undeposited remainder; `collectReward` claims uncollected rewards.

:::note Changed in 1.0.0
The pillar ABI definition (`Definitions.pillar`) previously omitted the `Update`, `DepositQsr`, `WithdrawQsr`, and `CollectReward` functions; they are now included so the local ABI matches the node's contract. See [the 1.0.0 changelog](/changelog).
:::

## Examples

List pillars and delegate to one:

```dart
final zenon = Zenon();

final pillars = await zenon.embedded.pillar.getAll();
for (final pillar in pillars.list) {
  print('${pillar.rank} ${pillar.name} '
      'weight: ${AmountUtils.addDecimals(pillar.weight, coinDecimals)} ZNN');
}

// Delegate to the top-ranked pillar
await zenon.send(zenon.embedded.pillar.delegate(pillars.list.first.name));
```

Deposit the QSR registration cost, then register a pillar:

```dart
final zenon = Zenon();
final address = await zenon.defaultKeyPair!.getAddress();

final cost = await zenon.embedded.pillar.getQsrRegistrationCost();
final deposited = await zenon.embedded.pillar.getDepositedQsr(address);
if (deposited < cost) {
  await zenon.send(zenon.embedded.pillar.depositQsr(cost - deposited));
}

// Sends 15000 ZNN (pillarRegisterZnnAmount) with the Register call
await zenon.send(zenon.embedded.pillar.register(
    'MyPillar', producerAddress, rewardAddress));
```
