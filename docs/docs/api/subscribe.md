---
sidebar_position: 5
title: Subscribe
---

# SubscribeApi

Accessed via `zenon.subscribe` on the [`Zenon`](/api/zenon) singleton. Registers real-time event subscriptions with the node so it pushes new momentums and account blocks to your application as they occur.

Subscriptions require the WebSocket transport (`WsClient`). They do not work over `HttpRpcClient`, which is stateless and cannot receive push notifications — if you switched transports with `Zenon().setClient(...)`, pass `zenon.wsClient` back before subscribing. See [Clients](/api/client).

## Methods

Each method sends a `ledger.subscribe` request with a different event type and returns the node-assigned subscription id. You use this id to pick your subscription's events out of the notification stream (see below).

| Method | RPC | Description |
| --- | --- | --- |
| `toMomentums` | `ledger.subscribe` (`momentums`) | New momentums as they are produced. |
| `toAllAccountBlocks` | `ledger.subscribe` (`allAccountBlocks`) | Every new account block on the network. |
| `toAccountBlocksByAddress` | `ledger.subscribe` (`accountBlocksByAddress`) | New account blocks of one address. |
| `toUnreceivedAccountBlocksByAddress` | `ledger.subscribe` (`unreceivedAccountBlocksByAddress`) | New unreceived blocks sent to one address. |

### toMomentums

```dart
Future<String?> toMomentums()
```

Subscribes to newly produced momentums. Returns the subscription id.

### toAllAccountBlocks

```dart
Future<String?> toAllAccountBlocks()
```

Subscribes to every account block added to the ledger, network-wide. Returns the subscription id.

### toAccountBlocksByAddress

```dart
Future<String?> toAccountBlocksByAddress(Address address)
```

Subscribes to account blocks created by `address`. Returns the subscription id.

### toUnreceivedAccountBlocksByAddress

```dart
Future<String?> toUnreceivedAccountBlocksByAddress(Address address)
```

Subscribes to blocks sent to `address` that await a receive block — useful for reacting to incoming funds. Returns the subscription id.

## Consuming events

The subscribe methods only register the subscription; the events themselves arrive as JSON-RPC notifications on the WebSocket connection. `WsClient` exposes every raw message from the node as a broadcast stream via `addOnConnectionEstablishedCallback`:

```dart
void addOnConnectionEstablishedCallback(ConnectionEstablishedCallback callback)

typedef ConnectionEstablishedCallback = void Function(
    Stream<Map<String, dynamic>?> allResponseBroadcaster);
```

The callback runs each time a connection is established (immediately, if already connected), receiving the stream of all incoming JSON-RPC messages. Subscription events are notifications whose `method` is `ledger.subscription`; their `params` map carries the `subscription` id and a `result` list with one entry per event. Filter the stream on your subscription id and decode each `result` entry.

Because it is a broadcast stream, multiple listeners can consume it independently, and messages emitted while nobody listens are dropped.

### Example: subscribing to momentums

```dart
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

Future<void> main() async {
  final zenon = Zenon();
  await zenon.wsClient.initialize('ws://127.0.0.1:35998');

  // Register the stream consumer, then subscribe.
  zenon.wsClient.addOnConnectionEstablishedCallback((broadcaster) async {
    final id = await zenon.subscribe.toMomentums();
    print('Subscribed with id $id');

    broadcaster.listen((json) {
      if (json == null || json['method'] != 'ledger.subscription') return;
      if (json['params']['subscription'] != id) return;
      for (final event in json['params']['result']) {
        print('New momentum ${event['height']} (${event['hash']})');
      }
    });
  });
}
```

Registering the consumer inside `addOnConnectionEstablishedCallback` also handles reconnects: the callback runs again on every re-established connection, re-creating the subscription (node-side subscriptions do not survive a dropped connection). Alternatively, listen to `zenon.wsClient.restartedStream` and re-subscribe there — see [Clients](/api/client).
