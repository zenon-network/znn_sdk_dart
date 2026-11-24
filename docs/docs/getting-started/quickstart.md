---
sidebar_position: 2
title: Quickstart
---

# Quickstart

This walkthrough connects to a node, derives an address from a mnemonic,
queries the ledger, and sends a feeless transaction.

## Connect and derive an address

```dart
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

Future<void> main() async {
  final zenon = Zenon();
  await zenon.wsClient.initialize('ws://127.0.0.1:35998');

  final keyStore = KeyStore.fromMnemonic(
      'route become dream access impulse price inform obtain engage ski '
      'believe awful absent pig thing vibrant possible exotic flee pepper '
      'marble rural fire fancy');
  final keyPair = keyStore.getKeyPair(0);
  final address = await keyPair.getAddress();
  print('address: $address');

  // Use this account for zenon.send unless one is passed explicitly.
  zenon.defaultKeyPair = keyPair;
}
```

:::danger Never hardcode a real mnemonic
The mnemonic above is the SDK's public example seed. Real secrets belong in
an encrypted key file — see [wallets](/guides/wallets).
:::

## Query the ledger

```dart
final accountInfo = await zenon.ledger.getAccountInfoByAddress(address);
print('height: ${accountInfo.blockCount}');

for (final entry in accountInfo.balanceInfoList!) {
  print('${entry.token!.symbol}: '
      '${AmountUtils.addDecimals(entry.balance!, entry.token!.decimals)}');
}
```

Amounts are unscaled `BigInt` values; `ZNN` and `QSR` use 8 decimals
(`coinDecimals`). `AmountUtils.extractDecimals` and
`AmountUtils.addDecimals` convert between human-readable strings and
on-chain units.

## Send ZNN

```dart
final block = AccountBlockTemplate.send(
  Address.parse('z1qqjnwjjpnue8xmmpanz6csze6tcmtzzdtfsww7'),
  znnZts,
  AmountUtils.extractDecimals('1', coinDecimals), // 1 ZNN
);

await zenon.send(block, generatingPowCallback: (status) {
  print('PoW status: $status');
});
```

`zenon.send` autofills the block, attaches plasma (or generates proof of
work if the account has no plasma fused), hashes, signs, and publishes it.
The transaction is feeless: it costs plasma or a one-off PoW, never tokens.
See [sending transactions](/guides/transactions) for the full lifecycle,
including `prepareBlock` for signing without publishing.

## Receive

Zenon uses a dual-ledger (block-lattice) model: a transfer completes when
the recipient publishes a corresponding receive block.

```dart
final unreceived =
    await zenon.ledger.getUnreceivedBlocksByAddress(address);

for (final block in unreceived.list!) {
  await zenon.send(AccountBlockTemplate.receive(block.hash));
}
```

## Next steps

- [Connecting to a node](/guides/connecting) — WebSocket vs HTTP, error
  handling, reconnects
- [Wallets](/guides/wallets) — encrypted key files and the keystore manager
- [Embedded contracts](/api/embedded/) — staking, pillars, tokens, and more
