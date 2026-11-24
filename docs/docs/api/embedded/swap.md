---
sidebar_position: 12
title: Swap
---

# SwapApi

Accessed via `zenon.embedded.swap`.

The swap embedded contract distributed the genesis allocation to holders of legacy-network assets. Balances are keyed by the hash of a legacy public key id; owners retrieve them by proving control of the corresponding key. Unclaimed balances decay over time after the decay start timestamp.

## Methods

| Method | RPC | Description |
| --- | --- | --- |
| `getAssetsByKeyIdHash` | `embedded.swap.getAssetsByKeyIdHash` | Swappable `ZNN`/`QSR` balance for one key id hash |
| `getAssets` | `embedded.swap.getAssets` | All swappable balances, keyed by key id hash |
| `getLegacyPillars` | `embedded.swap.getLegacyPillars` | Legacy Pillar entries by key id hash |

### Contract methods

These return an unsigned `AccountBlockTemplate` that you pass to `zenon.send(...)` — see [sending transactions](/guides/transactions).

| Method | Description |
| --- | --- |
| `retrieveAssets` | Claim a legacy balance with a public key and signature |

The API also exposes a pure helper, `getSwapDecayPercentage`, computed client-side without an RPC call.

## getAssetsByKeyIdHash

```dart
Future<SwapAssetEntry> getAssetsByKeyIdHash(String keyIdHash) async
```

Returns the `SwapAssetEntry` (`znn` and `qsr` amounts) still claimable for `keyIdHash`. `SwapAssetEntry.hasBalance()` reports whether anything remains.

## getAssets

```dart
Future<Map<String, SwapAssetEntry>> getAssets() async
```

Returns every remaining swap entry as a map from key id hash (hex string) to `SwapAssetEntry`.

## getLegacyPillars

```dart
Future<List<SwapLegacyPillarEntry>> getLegacyPillars() async
```

Returns the legacy Pillar registrations, each with a `keyIdHash` and the `numPillars` it entitles the owner to register.

## retrieveAssets

```dart
AccountBlockTemplate retrieveAssets(String pubKey, String signature)
```

Builds a block claiming the balance associated with `pubKey` (base64) to the sending address. `signature` must be produced with the legacy private key over the retrieval message that includes the destination address.

## getSwapDecayPercentage

```dart
int getSwapDecayPercentage(int currentTimestamp)
```

Returns the percentage (`0` to `100`) of the swap balance already lost to decay at `currentTimestamp` (unix seconds). Returns `0` before the decay start timestamp; afterwards the decayed share grows in ticks until it reaches `100`.

## Example

Check a legacy balance and its decay:

```dart
final zenon = Zenon();
await zenon.wsClient.initialize('ws://127.0.0.1:35998');

const keyIdHash =
    'f9d5de1b99f19b9e4485b33d43ff42883f56f7bcf8f75dfb08fd08b3f37e2036';
final entry = await zenon.embedded.swap.getAssetsByKeyIdHash(keyIdHash);
if (entry.hasBalance()) {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final decay = zenon.embedded.swap.getSwapDecayPercentage(now);
  print('Claimable: ${entry.znn} ZNN, ${entry.qsr} QSR ($decay% decayed)');
}
```
