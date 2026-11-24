---
sidebar_position: 10
title: Liquidity
---

# LiquidityApi

Accessed via `zenon.embedded.liquidity`.

The liquidity embedded contract rewards providers of liquidity: eligible LP tokens can be staked for a chosen duration and earn `ZNN` and `QSR` rewards. Like the bridge, the contract is protected by guardians and an administrator.

:::note Changed in 1.0.0
`getSecurityInfo`, `getTimeChallengesInfo`, and `getLiquidityInfo` now send an explicit empty params list (`[]`) instead of omitting the `params` field, which some nodes reject. See [the 1.0.0 changelog](/changelog).
:::

## Methods

| Method | RPC | Description |
| --- | --- | --- |
| `getUncollectedReward` | `embedded.liquidity.getUncollectedReward` | Uncollected `ZNN`/`QSR` rewards for an address |
| `getFrontierRewardByPage` | `embedded.liquidity.getFrontierRewardByPage` | Paginated per-epoch reward history for an address |
| `getSecurityInfo` | `embedded.liquidity.getSecurityInfo` | Guardians, guardian votes, and administrative delays |
| `getTimeChallengesInfo` | `embedded.liquidity.getTimeChallengesInfo` | Active time challenges for security-sensitive methods |
| `getLiquidityInfo` | `embedded.liquidity.getLiquidityInfo` | Global contract state and configured token tuples |
| `getLiquidityStakeEntriesByAddress` | `embedded.liquidity.getLiquidityStakeEntriesByAddress` | Paginated liquidity stake entries for an address |

### Contract methods

These return an unsigned `AccountBlockTemplate` that you pass to `zenon.send(...)` — see [sending transactions](/guides/transactions).

| Method | Description |
| --- | --- |
| `liquidityStake` | Stake LP tokens for a duration |
| `cancelLiquidityStake` | Cancel an expired stake entry and reclaim the tokens |
| `unlockLiquidityStakeEntries` | Unlock stake entries for a token (used when the contract halts) |
| `collectReward` | Collect accumulated `ZNN`/`QSR` rewards |
| `setTokenTuple` | Configure eligible LP tokens and reward shares (administrator) |
| `setAdditionalReward` | Set extra `ZNN`/`QSR` rewards (administrator) |
| `setIsHalted` | Halt or resume the contract (administrator) |
| `nominateGuardians` | Nominate the guardian set (administrator) |
| `proposeAdministrator` | Propose a new administrator (guardian, in emergency) |
| `changeAdministrator` | Transfer the administrator role (administrator) |
| `emergency` | Put the contract into emergency mode (administrator) |

## Query methods

### getUncollectedReward

```dart
Future<RewardDeposit> getUncollectedReward(Address address) async
```

Returns the `RewardDeposit` (`znnAmount`, `qsrAmount`) waiting to be collected by `address`.

### getFrontierRewardByPage

```dart
Future<RewardHistoryList> getFrontierRewardByPage(Address address,
    {int pageIndex = 0, int pageSize = rpcMaxPageSize}) async
```

Returns the per-epoch reward history for `address`, newest first.

### getSecurityInfo

```dart
Future<SecurityInfo> getSecurityInfo() async
```

Returns the `SecurityInfo`: current `guardians`, pending `guardiansVotes`, and the `administratorDelay` and `softDelay` applied to sensitive operations.

### getTimeChallengesInfo

```dart
Future<TimeChallengesList> getTimeChallengesInfo() async
```

Returns the list of active time challenges for the liquidity contract's security-sensitive methods.

### getLiquidityInfo

```dart
Future<LiquidityInfo> getLiquidityInfo() async
```

Returns the global `LiquidityInfo`: administrator, halt status, additional rewards, and the configured token tuples (eligible ZTS tokens with their `ZNN`/`QSR` reward percentages and minimum amounts).

### getLiquidityStakeEntriesByAddress

```dart
Future<LiquidityStakeList> getLiquidityStakeEntriesByAddress(Address address,
    {int pageIndex = 0, int pageSize = memoryPoolPageSize}) async
```

Returns the liquidity stake entries owned by `address`. Note the default `pageSize` here is `memoryPoolPageSize` (`50`).

## Contract methods

### liquidityStake

```dart
AccountBlockTemplate liquidityStake(
    int durationInSec, BigInt amount, TokenStandard zts)
```

Builds a block that stakes `amount` of the LP token `zts` for `durationInSec` seconds. Longer durations earn a higher reward multiplier.

### cancelLiquidityStake

```dart
AccountBlockTemplate cancelLiquidityStake(Hash id)
```

Builds a block cancelling the stake entry `id` and returning the staked tokens. Only valid after the entry's duration has elapsed.

### unlockLiquidityStakeEntries

```dart
AccountBlockTemplate unlockLiquidityStakeEntries(TokenStandard zts)
```

Builds a block unlocking all of the sender's stake entries for token `zts`; used to free entries when the contract is halted.

### collectReward

```dart
AccountBlockTemplate collectReward()
```

Builds a block that collects the sender's accumulated `ZNN`/`QSR` rewards.

### Administrator methods

```dart
AccountBlockTemplate setTokenTuple(List<String> tokenStandards,
    List<int> znnPercentages, List<int> qsrPercentages, List<BigInt> minAmounts)
```

```dart
AccountBlockTemplate setAdditionalReward(int znnReward, int qsrReward)
```

```dart
AccountBlockTemplate setIsHalted(bool isHalted)
```

```dart
AccountBlockTemplate nominateGuardians(List<Address> guardians)
```

```dart
AccountBlockTemplate proposeAdministrator(Address address)
```

```dart
AccountBlockTemplate changeAdministrator(Address administrator)
```

```dart
AccountBlockTemplate emergency()
```

Governance operations mirroring the [bridge](/api/embedded/bridge) security model. `setTokenTuple` passes four parallel lists defining, for each eligible LP token, its `ZNN` and `QSR` reward percentages and minimum stake amount.

## Examples

Check rewards and stake entries:

```dart
final zenon = Zenon();
await zenon.wsClient.initialize('ws://127.0.0.1:35998');

final address = Address.parse('z1qqjnwjjpnue8xmmpanz6csze6tcmtzzdtfsww7');
final reward = await zenon.embedded.liquidity.getUncollectedReward(address);
print('Uncollected: ${reward.znnAmount} ZNN, ${reward.qsrAmount} QSR');

final entries = await zenon.embedded.liquidity
    .getLiquidityStakeEntriesByAddress(address);
```

Stake LP tokens for 30 days, then later collect rewards:

```dart
final zenon = Zenon();
// ... connect and set zenon.defaultKeyPair (see /guides/wallets)

final lpToken = TokenStandard.parse('zts17d6yr02kh0r9qr566p7tg6');
final stakeBlock = zenon.embedded.liquidity.liquidityStake(
  30 * 24 * 3600, // 30 days
  BigInt.from(1000000),
  lpToken,
);
await zenon.send(stakeBlock);

// later
await zenon.send(zenon.embedded.liquidity.collectReward());
```
