---
sidebar_position: 8
title: HTLC
---

# HtlcApi

Accessed via `zenon.embedded.htlc`.

The HTLC embedded contract implements hashed timelock contracts, the building block for atomic swaps: funds are locked for a `hashLocked` counterparty who can claim them by revealing a preimage before `expirationTime`, after which the creator can reclaim them.

## Methods

| Method | RPC | Description |
| --- | --- | --- |
| `getById` | `embedded.htlc.getById` | An active HTLC entry by id |
| `getProxyUnlockStatus` | `embedded.htlc.getProxyUnlockStatus` | Whether an address allows proxy unlocking |

### Contract methods

These return an unsigned `AccountBlockTemplate` that you pass to `zenon.send(...)` — see [sending transactions](/guides/transactions).

| Method | Description |
| --- | --- |
| `create` | Lock funds in a new HTLC |
| `reclaim` | Reclaim an expired HTLC as its creator |
| `unlock` | Unlock an HTLC by revealing the preimage |
| `denyProxyUnlock` | Disallow third parties from unlocking on your behalf |
| `allowProxyUnlock` | Allow third parties to unlock on your behalf (default) |

## getById

```dart
Future<HtlcInfo> getById(Hash id) async
```

Returns the `HtlcInfo` for an active HTLC: `id`, `timeLocked` (creator), `hashLocked` (recipient), `tokenStandard`, `amount`, `expirationTime`, `hashType`, `keyMaxSize`, and `hashLock`. The id is the hash of the account block that created the HTLC. Fails once the entry has been unlocked or reclaimed.

## getProxyUnlockStatus

```dart
Future<bool> getProxyUnlockStatus(Address address) async
```

Returns `true` if `address` permits proxy unlocking, i.e. any address that knows the preimage may unlock HTLCs hash-locked to it, rather than only the `hashLocked` address itself. Defaults to `true` for addresses that never called `denyProxyUnlock`.

## create

```dart
AccountBlockTemplate create(Token token, BigInt amount, Address hashLocked,
    int expirationTime, int hashType, int keyMaxSize, List<int>? hashLock)
```

Builds a block that locks `amount` of `token` for `hashLocked`. Parameters:

- `expirationTime` — unix timestamp (seconds) after which the creator can reclaim.
- `hashType` — `0` for SHA3-256, `1` for SHA-256.
- `keyMaxSize` — maximum allowed preimage length in bytes (typically `32`).
- `hashLock` — the digest of the secret preimage under `hashType`.

## reclaim

```dart
AccountBlockTemplate reclaim(Hash id)
```

Builds a block returning the locked funds to the creator. Only valid after `expirationTime` and only from the `timeLocked` address.

## unlock

```dart
AccountBlockTemplate unlock(Hash id, List<int>? preimage)
```

Builds a block that unlocks HTLC `id` by revealing `preimage`, whose hash under the entry's `hashType` must equal `hashLock`. Must be sent before `expirationTime`.

## denyProxyUnlock / allowProxyUnlock

```dart
AccountBlockTemplate denyProxyUnlock()
```

```dart
AccountBlockTemplate allowProxyUnlock()
```

Toggle whether other addresses may submit `unlock` on behalf of the sending address. The setting applies to the address as a whole, not to individual HTLCs.

## Examples

Create an HTLC locking `10` `ZNN`:

```dart
import 'dart:convert';

final zenon = Zenon();
// ... connect and set zenon.defaultKeyPair (see /guides/wallets)

final preimage = utf8.encode('my secret preimage value');
final hashLock = Crypto.digest(preimage); // SHA3-256
final counterparty =
    Address.parse('z1qqjnwjjpnue8xmmpanz6csze6tcmtzzdtfsww7');
final znn = await zenon.embedded.token.getByZts(znnZts);

final block = zenon.embedded.htlc.create(
  znn!,
  BigInt.from(10 * 100000000), // 10 ZNN, 8 decimals
  counterparty,
  DateTime.now().millisecondsSinceEpoch ~/ 1000 + 24 * 3600, // 24h expiry
  0, // hashType 0 = SHA3-256
  32,
  hashLock,
);
await zenon.send(block);
```

Inspect and unlock an HTLC as the counterparty:

```dart
import 'dart:convert';

final zenon = Zenon();
// The HTLC id is the hash of the account block that created it.
final id = Hash.parse(
    '3fd7f3f2b2c1c31c1b2f5e6a4bfeef8ad35bbb55f7ba09a1e5bfe0f2a4e78f21');
final preimage = utf8.encode('my secret preimage value');

final info = await zenon.embedded.htlc.getById(id);
print('Locked ${info.amount} ${info.tokenStandard} until ${info.expirationTime}');

await zenon.send(zenon.embedded.htlc.unlock(id, preimage));
```
