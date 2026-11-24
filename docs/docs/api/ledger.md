---
sidebar_position: 3
title: Ledger
---

# LedgerApi

Accessed via `zenon.ledger` on the [`Zenon`](/api/zenon) singleton. Queries account blocks, momentums and account state, and publishes signed transactions to the network.

```dart
final zenon = Zenon();
final momentum = await zenon.ledger.getFrontierMomentum();
```

## Methods

| Method | RPC | Description |
| --- | --- | --- |
| `publishRawTransaction` | `ledger.publishRawTransaction` | Publishes a fully signed account block. |
| `getUnconfirmedBlocksByAddress` | `ledger.getUnconfirmedBlocksByAddress` | Account blocks in the mempool for an address, not yet included in a momentum. |
| `getUnreceivedBlocksByAddress` | `ledger.getUnreceivedBlocksByAddress` | Blocks sent to an address that it has not received yet. |
| `getFrontierAccountBlock` | `ledger.getFrontierAccountBlock` | Latest account block of an address. |
| `getAccountBlockByHash` | `ledger.getAccountBlockByHash` | An account block by its hash. |
| `getAccountBlocksByHeight` | `ledger.getAccountBlocksByHeight` | Account blocks of an address starting at a height. |
| `getAccountBlocksByPage` | `ledger.getAccountBlocksByPage` | Paginated account blocks of an address, most recent first. |
| `getFrontierMomentum` | `ledger.getFrontierMomentum` | The latest momentum. |
| `getMomentumBeforeTime` | `ledger.getMomentumBeforeTime` | The last momentum before a Unix timestamp. |
| `getMomentumByHash` | `ledger.getMomentumByHash` | A momentum by its hash. |
| `getMomentumsByHeight` | `ledger.getMomentumsByHeight` | A range of momentums starting at a height. |
| `getMomentumsByPage` | `ledger.getMomentumsByPage` | Paginated momentums, most recent first. |
| `getDetailedMomentumsByHeight` | `ledger.getDetailedMomentumsByHeight` | Momentums with their contained account blocks. |
| `getAccountInfoByAddress` | `ledger.getAccountInfoByAddress` | Balances and block count for an address. |

Page sizes default to `rpcMaxPageSize` (1024), except the two mempool queries which default to `memoryPoolPageSize` (50).

## publishRawTransaction

```dart
Future publishRawTransaction(AccountBlockTemplate accountBlockTemplate)
```

Publishes a fully prepared (autofilled, plasma/PoW-attached, signed) account block. The node returns `null` on acceptance, so the returned future completes with `null` on success.

Most applications should use [`zenon.send`](/api/zenon) instead, which prepares the block and then calls this method; use `publishRawTransaction` directly when broadcasting a block prepared earlier with [`zenon.prepareBlock`](/api/zenon). See the [transactions guide](/guides/transactions).

:::note Changed in 1.0.0
`publishRawTransaction` now throws a `ZnnSdkException` if the node returns an unexpected non-null result (`null` remains the acceptance signal). Part of [the 1.0.0 changelog](/changelog).
:::

```dart
final zenon = Zenon();
final signed = await zenon.prepareBlock(AccountBlockTemplate.send(toAddress, znnZts, amount));
await zenon.ledger.publishRawTransaction(signed);
```

## getUnconfirmedBlocksByAddress

```dart
Future<AccountBlockList> getUnconfirmedBlocksByAddress(Address address,
    {int pageIndex = 0, int pageSize = memoryPoolPageSize})
```

Returns account blocks of `address` that are in the mempool but not yet included in a momentum.

## getUnreceivedBlocksByAddress

```dart
Future<AccountBlockList> getUnreceivedBlocksByAddress(Address address,
    {int pageIndex = 0, int pageSize = memoryPoolPageSize})
```

Returns blocks sent to `address` for which no corresponding receive block exists yet. Iterate this list to receive pending funds:

```dart
final zenon = Zenon();
final unreceived = await zenon.ledger.getUnreceivedBlocksByAddress(address);
for (final block in unreceived.list!) {
  await zenon.send(AccountBlockTemplate.receive(block.hash));
}
```

## getFrontierAccountBlock

```dart
Future<AccountBlock?> getFrontierAccountBlock(Address? address)
```

Returns the most recent account block of `address`, or `null` if the account has no blocks.

## getAccountBlockByHash

```dart
Future<AccountBlock?> getAccountBlockByHash(Hash? hash)
```

Returns the account block with the given `hash`, or `null` if not found.

## getAccountBlocksByHeight

```dart
Future<AccountBlockList> getAccountBlocksByHeight(Address address,
    [int height = 1, int count = rpcMaxPageSize])
```

Returns up to `count` account blocks of `address` starting at `height` (heights start at 1), ascending.

## getAccountBlocksByPage

```dart
Future<AccountBlockList> getAccountBlocksByPage(Address address,
    {int pageIndex = 0, int pageSize = rpcMaxPageSize})
```

Returns a page of account blocks for `address`. `pageIndex = 0` returns the most recent blocks, sorted descending by height.

## getFrontierMomentum

```dart
Future<Momentum> getFrontierMomentum()
```

Returns the latest momentum of the network.

```dart
final zenon = Zenon();
final frontier = await zenon.ledger.getFrontierMomentum();
print('Current height: ${frontier.height}');
```

## getMomentumBeforeTime

```dart
Future<Momentum?> getMomentumBeforeTime(int time)
```

Returns the last momentum produced before the Unix timestamp `time` (seconds), or `null` if there is none.

## getMomentumByHash

```dart
Future<Momentum?> getMomentumByHash(Hash hash)
```

Returns the momentum with the given `hash`, or `null` if not found.

## getMomentumsByHeight

```dart
Future<MomentumList> getMomentumsByHeight(int height, int count)
```

Returns up to `count` momentums starting at `height`, ascending. The SDK clamps `height` to a minimum of 1 and `count` to a maximum of `rpcMaxPageSize`.

## getMomentumsByPage

```dart
Future<MomentumList> getMomentumsByPage(
    {int pageIndex = 0, int pageSize = rpcMaxPageSize})
```

Returns a page of momentums. `pageIndex = 0` returns the most recent momentums, sorted descending by height.

## getDetailedMomentumsByHeight

```dart
Future<DetailedMomentumList> getDetailedMomentumsByHeight(
    int height, int count)
```

Like `getMomentumsByHeight`, but each entry includes the account blocks contained in the momentum. The same clamping of `height` and `count` applies.

## getAccountInfoByAddress

```dart
Future<AccountInfo> getAccountInfoByAddress(Address address)
```

Returns the state of `address`: its block count and per-token balances.

```dart
final zenon = Zenon();
final info = await zenon.ledger.getAccountInfoByAddress(address);
print('Block count: ${info.blockCount}');
```
