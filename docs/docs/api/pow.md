---
sidebar_position: 9
title: Proof of work
---

# Proof of work

Zenon transactions are feeless, but every account block must be backed by plasma. An account gets plasma either by fusing QSR (see [Plasma](/api/embedded/plasma)) or by computing a one-off proof of work for the block. When you publish through `zenon.send(...)`, the SDK checks the required plasma and — if the account's fused plasma is insufficient — sets the block's `difficulty` and computes a `nonce` automatically before signing (see [sending transactions](/guides/transactions)). The functions on this page (`lib/src/pow/pow.dart`) are what that machinery uses under the hood.

## generatePoW

```dart
Future<String> generatePoW(Hash hash, int? difficulty) async
```

Computes a nonce for `hash` at the given `difficulty` and returns it as a hex string (8 bytes). The work runs single-threaded native C code inside a dedicated Dart isolate, so the main isolate stays responsive. If a custom [`PowProvider`](#custom-pow-backends) is set, the call is routed there instead of the native library.

You can observe progress through the `generatingPowCallback` of `zenon.send(...)`, which reports a `PowStatus`:

```dart
enum PowStatus {
  generating,
  done,
}
```

```dart
await zenon.send(tx, generatingPowCallback: (status) {
  if (status == PowStatus.generating) print('Generating PoW...');
  if (status == PowStatus.done) print('PoW done');
});
```

`zenon.requiresPoW(transaction)` tells you up front whether a block will need PoW for the current plasma balance.

## verifyPoW

```dart
bool verifyPoW(Hash dataHash, int difficulty, String nonce)
```

:::note Added in 1.0.0
Verifies that a hex `nonce` (8 bytes) satisfies `difficulty` for `dataHash`, mirroring the node's `pow.CheckPoWNonce`: it computes `sha3-256(nonce || dataHash)` and compares the first 8 bytes of the digest, interpreted in little-endian order, against the threshold `2^64 - 2^64 / difficulty`. Returns `true` when the nonce meets or exceeds the threshold. Throws an `ArgumentError` if the nonce is not exactly 8 bytes or the difficulty is negative. Use it to validate nonces produced by a custom PoW backend before publishing. See [the 1.0.0 changelog](/changelog).
:::

```dart
var nonce = await generatePoW(powData, difficulty);
assert(verifyPoW(powData, difficulty, nonce));
```

## Custom PoW backends

:::note Added in 1.0.0
PoW generation can be routed through a custom backend — for example an isolate pool, a GPU worker, or a remote PoW service — instead of the bundled native library:

```dart
typedef PowProvider = Future<String> Function(Hash dataHash, int difficulty);

void setPowProvider(PowProvider provider)
void clearPowProvider()
```

After `setPowProvider`, every `generatePoW` call (including the ones `zenon.send(...)` makes internally) invokes the provider and expects the hex nonce back. `clearPowProvider` restores the default native backend. See [the 1.0.0 changelog](/changelog).
:::

```dart
setPowProvider((dataHash, difficulty) async {
  // Delegate to a remote worker, isolate pool, etc.
  return await myRemoteWorker.solve(dataHash.toString(), difficulty);
});

// ... transactions sent now use the custom backend ...

clearPowProvider();
```

## Native library loading

The default backend is `libpow_links`, a native library shipped with the SDK in `lib/src/pow/blobs`.

```dart
void initializePoWLinks()
```

`initializePoWLinks` locates and loads the library and maps its `generatePoW` and `benchmark` functions. It is called automatically on the first `generatePoW` or `benchmarkPoW` call, but you can call it eagerly at startup to fail fast. The loader searches, in order: the current working directory, the directory of the running executable (and its `Resources` sibling, for macOS bundles), the SDK's `blobs` directory, and the pub cache. The file name depends on the platform: `libpow_links.so` (Linux), `libpow_links.dylib` (macOS), `libpow_links.dll` (Windows), `libpow_links-arm64-v8a.so` (Android); on iOS the symbols are looked up in the host process. If no library is found, a `ZnnSdkException` (`'Library libpow_links could not be found'`) is thrown — in that case either place the library next to your executable or install a custom `PowProvider`.

## benchmarkPoW

```dart
String benchmarkPoW(int difficulty)
```

Generates a nonce for the empty hash without random seeding, so the result is deterministic — useful for benchmarking a machine's PoW throughput. With difficulty `10000000` expect a runtime of roughly 800 ms and the result `ufVIAAAAAAA=`.
