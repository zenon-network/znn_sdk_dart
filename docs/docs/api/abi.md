---
sidebar_position: 8
title: ABI
---

# Abi

The ABI module (`lib/src/abi/`) encodes and decodes embedded contract calldata using an Ethereum-style ABI: a 4-byte function selector (the first 4 bytes of the SHA3-256 hash of the function signature) followed by 32-byte-word-encoded arguments. You normally don't touch it directly — the embedded contract APIs (see [the embedded index](/api/embedded/)) build calldata for you — but it is the tool for decoding a block's `data` or crafting custom contract calls.

The ABI definitions of every embedded contract ship with the SDK as static `Abi` instances on the `Definitions` class (`lib/src/embedded/definitions.dart`): `Definitions.plasma`, `Definitions.pillar`, `Definitions.token`, `Definitions.sentinel`, `Definitions.swap`, `Definitions.stake`, `Definitions.accelerator`, `Definitions.bridge`, `Definitions.liquidity`, `Definitions.spork`, `Definitions.htlc`, and `Definitions.common`.

## Methods

| Method | Description |
| --- | --- |
| `Abi.fromJson` | Parse an ABI from its JSON definition (functions only) |
| `encodeFunction` | Encode a call: selector plus encoded arguments |
| `decodeFunction` | Decode calldata into a list of argument values |
| `decodeCallData` | Decode calldata into the matched function name plus arguments |

### Abi.fromJson

```dart
Abi.fromJson(var j)
```

Parses a JSON array of entries, e.g. `[{"type":"function","name":"Fuse","inputs":[{"name":"address","type":"address"}]}]`. Only `"type": "function"` entries are supported; anything else throws a `ZnnSdkException`.

### encodeFunction

```dart
List<int> encodeFunction(String name, var args)
```

Encodes a call to the function `name` with the positional argument list `args`, returning the full calldata (4-byte selector plus encoded arguments), ready to use as the `data` of `AccountBlockTemplate.callContract` (see [Primitives](/api/primitives)).

### decodeFunction

```dart
dynamic decodeFunction(List<int> encoded)
```

Matches `encoded`'s 4-byte selector against the ABI's functions and returns the decoded argument values as a `List`.

### decodeCallData

```dart
DecodedCall decodeCallData(List<int> encoded)

class DecodedCall {
  final String name;
  final List args;

  DecodedCall(this.name, this.args);
}
```

:::note Added in 1.0.0
`decodeCallData` decodes full calldata like `decodeFunction`, but also tells you *which* function was called: it returns a `DecodedCall` carrying the matched function `name` and its decoded `args`. It throws a `ZnnSdkException` when no ABI function matches the calldata selector. This is the convenient entry point for inspecting the `data` of account blocks sent to embedded contracts. See [the 1.0.0 changelog](/changelog).
:::

## Supported types

From `lib/src/abi/abi_types.dart` (`AbiType.getType`):

| ABI type | Accepted Dart values on encode | Decoded Dart type |
| --- | --- | --- |
| `intN` (N = 8…256, step 8; `int` = `int256`) | `int`, `BigInt`, decimal/hex `String`, byte `List` | `BigInt` (two's complement) |
| `uintN` (N = 8…256, step 8; `uint` = `uint256`) | `int`, `BigInt`, decimal/hex `String`, byte `List` | `BigInt` |
| `bool` | `bool` only | `bool` |
| `address` | `Address` or bech32 `String` | `Address` |
| `tokenStandard` | `TokenStandard` or bech32 `String` | `TokenStandard` |
| `hash` | hex `String`, `List<int>`, or `num` | `Hash` |
| `bytesN` (N = 1…32) | hex `String` (with or without `0x`) or `List<int>` of exactly N bytes | `List<int>` of N bytes |
| `bytes` (dynamic) | `List<int>` or hex `String` | `List<int>` |
| `string` (dynamic) | `String` (UTF-8) | `String` |
| `function` | `List<int>` of 24 bytes | not supported (encode-only) |
| `T[N]` (fixed-size array) | `List` of N elements (or a JSON array `String`) | `List` |
| `T[]` (dynamic array) | `List` (or a JSON array `String`) | `List` |

Static types occupy one 32-byte word; `bytes`, `string`, dynamic arrays — and fixed-size arrays whose element type is dynamic — are dynamic types referenced by offset.

## Validation and error behavior

:::note Changed in 1.0.0
The encoder and decoder were hardened to match the node's ABI semantics; all of the following throw a descriptive `ZnnSdkException` instead of the bare `Error()` the previous implementation used:

- **Strict argument count**: `encodeFunction` requires exactly as many arguments as the function declares (previously, too few arguments were silently accepted).
- **Signed integers**: `intN` values are now decoded as two's complement, so negative values round-trip correctly (previously they decoded as large positive numbers).
- **Integer range checks**: `intN`/`uintN` values are validated against the type's bit width on both encode and decode; e.g. encoding `256` as `uint8` or decoding a word that exceeds the declared width fails.
- **`bytesN` length enforcement**: encode requires exactly N bytes (previously shorter inputs were silently zero-padded), and decode verifies that the padding bytes beyond N are zero and returns exactly N bytes.
- **Canonical booleans**: `bool` accepts only a Dart `bool` on encode (the strings `'true'`/`'false'` are no longer accepted) and only decodes the canonical words 0 and 1 (any other word is rejected).
- **Fixed-size arrays of dynamic elements**: `T[N]` where `T` is dynamic (e.g. `string[2]`) is now correctly treated as a dynamic type and encoded/decoded by offset.

See [the 1.0.0 changelog](/changelog).
:::

## Example

Encode a call to the Plasma contract's `Fuse(address)` function and decode it back:

```dart
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

void main() {
  var beneficiary =
      Address.parse('z1qqjnwjjpnue8xmmpanz6csze6tcmtzzdtfsww7');

  // Encode: 4-byte selector + one address word
  List<int> data = Definitions.plasma.encodeFunction('Fuse', [beneficiary]);

  // This is exactly what PlasmaApi.fuse builds:
  var tx = AccountBlockTemplate.callContract(
      plasmaAddress, qsrZts, BigInt.from(5000000000), data);

  // Decode arguments only
  List args = Definitions.plasma.decodeFunction(data);
  print(args[0]); // z1qqjnwjjpnue8xmmpanz6csze6tcmtzzdtfsww7

  // Decode function name and arguments
  var call = Definitions.plasma.decodeCallData(tx.data);
  print('${call.name}(${call.args})'); // Fuse([z1qqjnw...])
}
```

:::note Changed in 1.0.0
The bundled `Definitions` ABIs were completed to cover every function the embedded contracts accept: `Update`, `DepositQsr`, `WithdrawQsr`, and `CollectReward` were added to the Pillar and Sentinel definitions, `Update` and `CollectReward` to the Stake definition, and `Update` to the Accelerator-Z definition, so calldata for those methods can now be decoded. See [the 1.0.0 changelog](/changelog).
:::
