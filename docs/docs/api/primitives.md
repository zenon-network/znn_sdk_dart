---
sidebar_position: 7
title: Primitives
---

# Primitives

The primitive types (`lib/src/model/primitives/`) are the building blocks used throughout the SDK: bech32 `Address`es, 32-byte `Hash`es, `HashHeight` momentum references, and `TokenStandard` (ZTS) identifiers. This page also covers `AccountBlockTemplate`, the mutable block structure you build transactions with.

## Address

A Zenon address is a bech32 string with human-readable part `z` and a 20-byte core: 1 type byte (`0` for user addresses, `1` for embedded contracts) followed by the first 19 bytes of the SHA3-256 digest of the public key.

| Member | Description |
| --- | --- |
| `Address(String hrp, List<int> core)` | Construct from parts |
| `Address.parse(String address)` | Parse a bech32 address string |
| `static Address fromPublicKey(List<int> publicKey)` | Derive a user address from an Ed25519 public key |
| `static bool isValid(String address)` | `true` if the string parses and round-trips exactly |
| `bool isEmbedded()` | `true` if this is an embedded contract address |
| `List<int>? getBytes()` | The 20-byte core |
| `String toString()` / `toShortString()` | Full / abbreviated bech32 form |
| `bool equals(Address address)` / `compareTo` | Comparison helpers (`==` and `hashCode` are also overridden) |

```dart
Address(String hrp, List<int> core)
Address.parse(String address)
static Address fromPublicKey(List<int> publicKey)
static bool isValid(String address)
```

:::note Changed in 1.0.0
`Address.parse` now validates that the bech32 human-readable part is exactly `z` and that the decoded core is exactly 20 bytes, and the `Address(hrp, core)` constructor validates the core length; both throw an `ArgumentError` on violation. Previously a well-formed bech32 string with the wrong prefix or length could produce a corrupt `Address`. See [the 1.0.0 changelog](/changelog).
:::

```dart
var address = Address.parse('z1qqjnwjjpnue8xmmpanz6csze6tcmtzzdtfsww7');
print(address.toShortString()); // z1qqjnw...tfsww7
print(Address.isValid('not-an-address')); // false
```

### Well-known addresses

The library exports `emptyAddress` (`z1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqsggv2f`) and one constant per embedded contract, all collected in `embeddedContractAddresses`:

| Constant | Contract |
| --- | --- |
| `plasmaAddress` | [Plasma](/api/embedded/plasma) |
| `pillarAddress` | [Pillar](/api/embedded/pillar) |
| `tokenAddress` | [Token](/api/embedded/token) |
| `sentinelAddress` | [Sentinel](/api/embedded/sentinel) |
| `swapAddress` | [Swap](/api/embedded/swap) |
| `stakeAddress` | [Stake](/api/embedded/stake) |
| `sporkAddress` | [Spork](/api/embedded/spork) |
| `acceleratorAddress` | [Accelerator-Z](/api/embedded/accelerator) |
| `htlcAddress` | [HTLC](/api/embedded/htlc) |
| `bridgeAddress` | [Bridge](/api/embedded/bridge) |
| `liquidityAddress` | [Liquidity](/api/embedded/liquidity) |

## Hash

A 32-byte SHA3-256 hash (`Hash.length == 32`). Note that `Hash.fromBytes`
retains the list it is given and `getBytes()` returns that same list, so
treat the underlying bytes as read-only.

```dart
Hash.fromBytes(List<int> hash)
Hash.parse(String hash)
Hash.digest(List<int> byteArrays)
List<int>? getBytes()
String toString()      // 64-char hex
String toShortString() // abbreviated hex
int compareTo(Hash otherHash)
```

`Hash.fromBytes` and `Hash.parse` throw an `ArgumentError` when the input is not exactly 32 bytes / 64 hex characters. `Hash.digest` computes the SHA3-256 digest of the given bytes. The all-zero hash is exported as `emptyHash`.

```dart
var h = Hash.digest(utf8.encode('hello'));
var same = Hash.parse(h.toString());
assert(h == same);
```

## HashHeight

A `(hash, height)` pair identifying a momentum, used for `momentumAcknowledged` in account blocks. The zero value is exported as `emptyHashHeight`.

```dart
HashHeight(Hash hash, int height)
HashHeight.fromJson(Map<String, dynamic> json)
Map<String, dynamic> toJson()
List<int> getBytes() // hash bytes ++ big-endian 8-byte height
```

:::note Changed in 1.0.0
Both the constructor and `HashHeight.fromJson` now validate that `height` is non-negative, throwing an `ArgumentError` otherwise. Dart ints are signed 64-bit, so heights that would overflow arrive negative; rejecting negatives bounds heights to `[0, 2^63)`. See [the 1.0.0 changelog](/changelog).
:::

## TokenStandard

A ZTS token identifier: a bech32 string with human-readable part `zts` and a 10-byte core.

```dart
TokenStandard.parse(String tokenStandard)
TokenStandard.fromBytes(List<int> bytes)
factory TokenStandard.bySymbol(String symbol) // 'znn'/'ZNN' or 'qsr'/'QSR' only
List<int> getBytes()
```

Both constructors validate the `zts` prefix and 10-byte core size. Exported constants:

| Constant | Value | Token |
| --- | --- | --- |
| `znnZts` | `zts1znnxxxxxxxxxxxxx9z4ulx` | ZNN |
| `qsrZts` | `zts1qsrxxxxxxxxxxxxxmrhjll` | QSR |
| `emptyZts` | `zts1qqqqqqqqqqqqqqqqtq587y` | Empty / placeholder |

The raw strings are also exported as `znnTokenStandard`, `qsrTokenStandard`, and `emptyTokenStandard`.

```dart
var zts = TokenStandard.bySymbol('znn');
assert(zts == znnZts);
```

## AccountBlockTemplate

Defined in `lib/src/model/nom/account_block_template.dart`, `AccountBlockTemplate` is the mutable account block you construct, have autofilled/signed, and publish. Every transaction — plain transfers and embedded contract calls alike — starts as one of its factory constructors and is normally passed to `zenon.send(...)`, which fills in `previousHash`, `height`, `momentumAcknowledged`, plasma or PoW fields, the `hash`, and the `signature` before publishing. See [sending transactions](/guides/transactions).

### Factory constructors

```dart
factory AccountBlockTemplate.receive(Hash fromBlockHash)

factory AccountBlockTemplate.send(
  Address toAddress,
  TokenStandard tokenStandard,
  BigInt amount, [
  List<int>? data,
])

factory AccountBlockTemplate.callContract(Address toAddress,
    TokenStandard tokenStandard, BigInt amount, List<int> data)
```

- `receive` creates a `userReceive` block that accepts the send block with hash `fromBlockHash`.
- `send` creates a `userSend` block transferring `amount` (in base units) of `tokenStandard` to `toAddress`, with optional `data`.
- `callContract` is a `userSend` block whose `data` is ABI-encoded calldata for an embedded contract (see [ABI](/api/abi)); the embedded contract APIs build these for you.

Block types come from `BlockTypeEnum`: `unknown`, `genesisReceive`, `userSend`, `userReceive`, `contractSend`, `contractReceive` (the `blockType` field stores the enum index).

### Fields

| Field | Type | Description |
| --- | --- | --- |
| `version`, `chainIdentifier`, `blockType` | `int` | Protocol version, chain id, block type index |
| `hash`, `previousHash` | `Hash` | Block hash and previous block hash in the account chain |
| `height` | `int` | Account chain height |
| `momentumAcknowledged` | `HashHeight` | Momentum the block anchors to |
| `address`, `toAddress` | `Address` | Sender and recipient |
| `amount` | `BigInt` | Amount in base units |
| `tokenStandard` | `TokenStandard` | Token being transferred |
| `fromBlockHash` | `Hash` | For receive blocks: the send block being received |
| `data` | `List<int>` | Payload / ABI calldata |
| `fusedPlasma`, `difficulty`, `nonce` | `int`, `int`, `String` | Plasma and proof-of-work fields (see [Proof of work](/api/pow)) |
| `publicKey`, `signature` | `List<int>` | Signer's public key and signature |

`AccountBlockTemplate.fromJson` / `toJson` convert to and from the node's JSON representation.

### Example

```dart
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

Future<void> main() async {
  var zenon = Zenon();
  // ... connect and set zenon.defaultKeyPair (see /guides/connecting)

  // Send 1 ZNN (8 decimals) to an address
  var tx = AccountBlockTemplate.send(
    Address.parse('z1qqjnwjjpnue8xmmpanz6csze6tcmtzzdtfsww7'),
    znnZts,
    BigInt.from(100000000),
  );
  await zenon.send(tx);
}
```
