---
sidebar_position: 1
title: Zenon Dart SDK
slug: /
---

# Zenon Dart SDK

<p className="text-ledger">Network of Momentum</p>

`znn_sdk_dart` is the reference Dart and Flutter SDK for Zenon — the Network
of Momentum, a feeless dual-ledger blockchain. It gives you everything needed
to build wallets, explorers and dApps: key management, JSON-RPC clients,
typed APIs for the ledger and every embedded contract, plasma and
proof-of-work handling, and transaction construction and signing.

<a className="button button--lg bg-plasma" href="getting-started/installation">Start building</a>

## What the SDK covers

| Area | What you get |
| --- | --- |
| [Wallet](/api/wallet) | BIP-39 mnemonics, Ed25519 key derivation, encrypted key files |
| [Clients](/api/client) | WebSocket and HTTP JSON-RPC 2.0 transports with normalized errors |
| [Ledger](/api/ledger) | Account blocks, momentums, account info, publishing transactions |
| [Embedded contracts](/api/embedded/) | Pillar, Sentinel, Stake, Plasma, Token, Accelerator-Z, HTLC, Bridge, Liquidity, Spork, Swap |
| [Subscriptions](/api/subscribe) | Momentum and account-block streams over WebSocket |
| [ABI](/api/abi) | Strict encoder/decoder for embedded contract calldata |
| [Proof of work](/api/pow) | PoW generation, verification, and pluggable backends |

## Versions

These docs describe `znn_sdk_dart` v1.0.0 including its
[spec conformance and hardening pass](/changelog) — it aligns
the SDK's ABI handling, RPC transport, embedded contract definitions and
wallet key files with the behavior of the Zenon node. If you are upgrading
from an earlier release, read that page first: several APIs now validate
inputs strictly and throw descriptive exceptions where they previously
returned malformed data.

## A minimal program

```dart
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

Future<void> main() async {
  final zenon = Zenon();
  await zenon.wsClient.initialize('ws://127.0.0.1:35998');

  final momentum = await zenon.ledger.getFrontierMomentum();
  print('height: ${momentum.height}');

  zenon.wsClient.stop();
}
```

Continue with [installation](/getting-started/installation) and the
[quickstart](/getting-started/quickstart).
