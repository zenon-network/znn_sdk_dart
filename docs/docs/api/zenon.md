---
sidebar_position: 1
title: Zenon
---

# Zenon

`Zenon` is the SDK's main entry point. It is a singleton: every call to the `Zenon()` factory constructor returns the same instance, so state such as the connected client and the default wallet account is shared across your whole application.

```dart
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

final zenon = Zenon();
```

## Construction

```dart
factory Zenon()
```

The first call constructs the singleton and wires everything up:

- `keyStoreManager` is created as a `KeyStoreManager` rooted at the default wallet directory (`znnDefaultWalletDirectory`).
- `wsClient` is created as a fresh, uninitialized `WsClient`.
- The four API namespaces (`ledger`, `stats`, `embedded`, `subscribe`) are created and routed through `wsClient`.

The instance is not connected to a node yet; call `zenon.wsClient.initialize(...)` first (see [Clients](/api/client) and the [connecting guide](/guides/connecting)).

## Properties

| Property | Type | Description |
| --- | --- | --- |
| `wsClient` | `WsClient` | The default WebSocket JSON-RPC client. |
| `keyStoreManager` | `WalletManager` | Manages encrypted key store files in the default wallet directory. See [Wallet](/api/wallet). |
| `defaultKeyPair` | `WalletAccount?` | The account used to sign transactions when no explicit key pair is passed. |
| `defaultKeyStore` | `Wallet?` | The currently opened wallet, if any. |
| `defaultKeyStorePath` | `WalletDefinition?` | The definition (file location) of the currently opened wallet, if any. |
| `ledger` | `LedgerApi` | Ledger queries and transaction publishing. See [Ledger](/api/ledger). |
| `stats` | `StatsApi` | Node statistics. See [Stats](/api/stats). |
| `embedded` | `EmbeddedApi` | Embedded smart contract APIs. See [the embedded index](/api/embedded/). |
| `subscribe` | `SubscribeApi` | Event subscriptions over WebSocket. See [Subscribe](/api/subscribe). |

`defaultKeyPair`, `defaultKeyStore` and `defaultKeyStorePath` start as `null`; assign them after opening a wallet (see the [wallets guide](/guides/wallets)):

```dart
final zenon = Zenon();
final keyStore = KeyStore.fromMnemonic(mnemonic);
zenon.defaultKeyStore = keyStore;
zenon.defaultKeyPair = keyStore.getKeyPair(0);
```

## setClient

:::note Added in 1.0.0
`setClient` is part of [the 1.0.0 changelog](/changelog).
:::

```dart
void setClient(Client client)
```

Routes every API namespace (`ledger`, `stats`, `embedded`, `subscribe`) through the given `Client`. This lets the SDK operate over any transport that implements `Client` — most notably the HTTP transport:

```dart
final zenon = Zenon();
zenon.setClient(HttpRpcClient('https://node:35997'));

// Restore the default WebSocket transport:
zenon.setClient(zenon.wsClient);
```

Note that the [Subscribe](/api/subscribe) API only functions over a WebSocket-backed client; `HttpRpcClient` cannot receive push notifications. See [Clients](/api/client) for details on both transports.

## send

```dart
Future<AccountBlockTemplate> send(AccountBlockTemplate transaction,
    {WalletAccount? currentKeyPair,
    void Function(PowStatus)? generatingPowCallback,
    waitForRequiredPlasma = false})
```

Fully processes and publishes an account block: autofills the block fields (height, previous hash, momentum acknowledgement), attaches plasma or generates proof of work as needed, computes the hash, signs the block with `currentKeyPair` (falling back to `defaultKeyPair`), and publishes it via `ledger.publishRawTransaction`. Returns the completed `AccountBlockTemplate`.

Throws `noKeyPairSelectedException` (a `ZnnSdkException`) if no key pair is passed and `defaultKeyPair` is `null`.

- `generatingPowCallback` is invoked with `PowStatus.generating` and `PowStatus.done` when PoW is required, so you can show progress in a UI. See [PoW](/api/pow).
- `waitForRequiredPlasma` controls whether the SDK waits for plasma instead of falling back to PoW.

```dart
final zenon = Zenon();
final tx = AccountBlockTemplate.send(toAddress, znnZts, amount);
final block = await zenon.send(tx);
```

See the [transactions guide](/guides/transactions) for a full walkthrough.

## prepareBlock

:::note Added in 1.0.0
`prepareBlock` is part of [the 1.0.0 changelog](/changelog).
:::

```dart
Future<AccountBlockTemplate> prepareBlock(AccountBlockTemplate transaction,
    {WalletAccount? currentKeyPair,
    void Function(PowStatus)? generatingPowCallback,
    waitForRequiredPlasma = false})
```

Performs the same steps as `send` — autofill, plasma/PoW, hash, signature — but does **not** publish the block to the network. Use it when you want to inspect, store, or broadcast the fully signed block yourself:

```dart
final zenon = Zenon();
final tx = AccountBlockTemplate.send(toAddress, znnZts, amount);
final signed = await zenon.prepareBlock(tx);
// ... later:
await zenon.ledger.publishRawTransaction(signed);
```

Like `send`, it throws `noKeyPairSelectedException` if no signing account is available.

## requiresPoW

```dart
Future<bool> requiresPoW(AccountBlockTemplate transaction,
    {WalletAccount? blockSigningKey})
```

Returns `true` if publishing `transaction` would require generating proof of work (i.e. the sending account does not have enough plasma from fused QSR). `blockSigningKey` defaults to `defaultKeyPair`. Useful for warning users before an expensive PoW computation starts.

## Global network settings

Two pairs of top-level functions (from the SDK's global scope, exported by the package) configure which network the SDK targets. They affect address block signing data, so set them before sending transactions on a non-default network.

```dart
void setChainIdentifier({int chainIdentifier = 1})
int getChainIdentifier()
```

Gets or sets the chain identifier (default `1`, Alphanet).

:::note Added in 1.0.0
`setNetworkId` and `getNetworkId` are part of [the 1.0.0 changelog](/changelog).
:::

```dart
void setNetworkId({int networkId = 1})
int getNetworkId()
```

Gets or sets the network identifier of the connected node (default `1`).

```dart
setChainIdentifier(chainIdentifier: 3);
setNetworkId(networkId: 3);
print(getChainIdentifier()); // 3
print(getNetworkId()); // 3
```
