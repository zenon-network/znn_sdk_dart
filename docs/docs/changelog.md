---
sidebar_position: 5
title: Changelog
---

# Changelog

Notable SDK changes are recorded here. API details and usage guidance remain
in their corresponding reference and guide sections.

## 1.0.0

### Spec conformance and hardening

A hardening pass
([PR #23](https://github.com/zenon-network/znn_sdk_dart/pull/23)) that
aligns the SDK with the behavior of the `go-zenon` node: the ABI
encoder/decoder now matches the node's encoding rules exactly, the embedded
contract definitions include every function the node serves, RPC failures
are normalized, and malformed inputs fail loudly instead of producing
corrupt data. This page summarizes what changed and what to check when
upgrading.

#### ABI encoding and decoding

The ABI layer (`Abi`, [reference](/api/abi)) previously accepted and
produced non-canonical data in several cases. It is now strict:

- **Argument counts** — `encodeFunction` requires exactly the number of
  arguments the function declares (extra and missing arguments both throw).
- **Signed integers** — `intN` words are decoded as two's complement;
  negative values round-trip correctly.
- **Range checks** — `intN`/`uintN` values are validated against the type's
  bit width on both encode and decode.
- **Fixed-size bytes** — `bytesN` requires exactly `N` bytes on encode
  (hex strings may carry a `0x` prefix) and rejects words with non-zero
  padding on decode. Decoded values have length `N`, not 32.
- **Booleans** — only Dart `bool` values encode (the strings
  `'true'`/`'false'` are no longer accepted), and only canonical `0`/`1`
  words decode.
- **Arrays** — fixed-size arrays of dynamic elements are correctly treated
  as dynamic types; array decoding no longer corrupts element order.
- **Errors** — malformed input throws a descriptive `ZnnSdkException`
  instead of a bare `Error`.

New API: `Abi.decodeCallData` matches full calldata (4-byte selector plus
arguments) against the definition and returns a `DecodedCall` with the
function `name` and decoded `args` — useful for decoding blocks addressed
to embedded contracts.

#### Embedded contract definitions

The SDK's local contract ABIs were missing functions the node accepts.
Added: `Update`, `DepositQsr`, `WithdrawQsr` and `CollectReward` on
[Pillar](/api/embedded/pillar) and [Sentinel](/api/embedded/sentinel);
`Update` and `CollectReward` on [Stake](/api/embedded/stake); `Update` on
the [Accelerator](/api/embedded/accelerator).

#### RPC transport

- **`HttpRpcClient`** — a new JSON-RPC 2.0 client over HTTP/HTTPS, plus
  `Zenon.setClient` to route all API namespaces through any client. See
  [clients](/api/client).
- **`RpcError`** — JSON-RPC failures from both transports now throw a
  normalized error carrying the failed `method`, `params`, `code`,
  `message` and `data`.
- **Parameter encoding** — parameterless bridge and liquidity RPCs send an
  explicit empty params list, which some node configurations require.
- **`getAllNetworks`** — the bridge method no longer ignores its `pageSize`
  argument.
- **`publishRawTransaction`** — throws if the node returns an unexpected
  non-null result instead of silently discarding it.
- **Reconnects** — the WebSocket retry delay dropped from five seconds to
  one.

#### Transactions

- **`Zenon.prepareBlock`** / **`BlockUtils.prepare`** — autofill, attach
  plasma or PoW, hash and sign a block without publishing it. See
  [sending transactions](/guides/transactions).
- **`BlockUtils.isReceiveBlock`** — fixed a bug where `contractReceive`
  blocks were not recognized (the enum was compared instead of its index).

#### Proof of work

- **`setPowProvider` / `clearPowProvider`** — route PoW generation through a
  custom backend (isolate pool, remote worker) instead of the bundled
  native library.
- **`verifyPoW`** — client-side nonce verification mirroring the node's
  `pow.CheckPoWNonce`.

See [proof of work](/api/pow).

#### Wallet key files

- Key files now store their Argon2id parameters (`timeCost`, `memoryCost`,
  `hashLength`, `parallelism`) instead of assuming hardcoded defaults, and
  validate version, KDF, cipher and parameter bounds before decrypting —
  a hostile key file can no longer request pathological KDF resources.
- `EncryptedFile.needsUpgrade` reports legacy files that should be
  re-encrypted to carry their parameters.
- `KeyStoreManager.readKeyStore` verifies the file's stored base address
  against the decrypted entropy and throws `WalletException` on mismatch.
- `KeyPair.clear()` zeroes and drops key material.

See [wallets](/guides/wallets).

#### Primitive validation

- `Address` — the constructor and `Address.parse` validate the bech32 HRP
  (`z`) and the 20-byte core length.
- `HashHeight` — heights must be non-negative 64-bit integers.
- `Momentum.toJson` and the Accelerator `Phase`/`Project` `toJson` methods
  now emit the node's JSON shapes; `ProjectList.findProjectByPhaseId` fixed
  an infinite-loop bug.
- `GetRequiredParam.fromJson` tolerates integer `blockType` and null
  `toAddress`/`data`.

#### Network identifier

`setNetworkId` / `getNetworkId` track the connected node's network
identifier alongside the existing chain identifier — see
[connecting to a node](/guides/connecting).

#### Deprecations

- `PlasmaApi.getRequiredFusionAmount` — the node does not serve
  `embedded.plasma.getRequiredFusionAmount`; use
  [`getPlasmaByQsr`](/api/embedded/plasma) for the client-side conversion.

#### Upgrade notes

The fixes are behavior-preserving for well-formed inputs, but code that
relied on lax behavior will now see exceptions:

- Passing the wrong number of ABI arguments, out-of-range integers,
  wrongly-sized `bytesN` values, or string booleans throws
  `ZnnSdkException`.
- Invalid addresses and negative heights throw `ArgumentError` at parse
  time rather than failing later.
- JSON-RPC failures throw `RpcError` instead of transport-specific
  exception types — update `catch` clauses accordingly.
- Malformed or tampered key files throw `WalletException` on decrypt.
