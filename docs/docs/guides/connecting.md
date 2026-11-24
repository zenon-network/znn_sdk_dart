---
sidebar_position: 1
title: Connecting to a node
---

# Connecting to a node

The SDK talks JSON-RPC 2.0 to a `go-zenon` full node over WebSocket or HTTP.
All API namespaces (`ledger`, `stats`, `embedded`, `subscribe`) share one
client.

## WebSocket (default)

`Zenon()` constructs a `WsClient` and wires every namespace to it. Connect
once at startup:

```dart
final zenon = Zenon();
final connected = await zenon.wsClient.initialize(
  'ws://127.0.0.1:35998',
  retry: true,
);
```

With `retry: true` the client keeps attempting to connect until it succeeds,
waiting one second between attempts. `initialize` returns `false` only when
called with `retry: false` and the connection fails.

The client transparently reconnects if the socket drops. Observe restarts
through the `restartedStream` broadcast stream — for example to re-establish
[subscriptions](/api/subscribe), which do not survive a reconnect:

```dart
zenon.wsClient.restartedStream.listen((_) async {
  await zenon.subscribe.toMomentums();
});
```

Shut down cleanly with `zenon.wsClient.stop()`.

## HTTP

:::note Added in 1.0.0
`HttpRpcClient` is new — see [the 1.0.0 changelog](/changelog).
:::

For request/response use without subscriptions — CLIs, servers, one-shot
scripts — `HttpRpcClient` speaks JSON-RPC 2.0 over HTTP or HTTPS and holds
no connection state:

```dart
final zenon = Zenon();
zenon.setClient(HttpRpcClient('http://127.0.0.1:35997'));

final momentum = await zenon.ledger.getFrontierMomentum();
```

`Zenon.setClient` routes every namespace through the given client. Pass
`zenon.wsClient` to switch back to WebSocket. The
[subscribe API](/api/subscribe) only functions over a WebSocket-backed
client.

## Error handling

All transports normalize failures into two exceptions:

- `noConnectionException` (`ZnnSdkException`) — the client is not connected
  (or, for HTTP, has been stopped).
- `RpcError` — the node answered with a JSON-RPC error. It carries the
  failed `method`, its `params`, the error `code`, `message`, and any
  `data`, so logs show which call failed without extra bookkeeping.

```dart
try {
  await zenon.ledger.getAccountInfoByAddress(address);
} on RpcError catch (e) {
  // e.method == 'ledger.getAccountInfoByAddress'
  print('node rejected the call: $e');
} on ZnnSdkException {
  print('not connected');
}
```

:::note Changed in 1.0.0
Previously WebSocket calls surfaced raw `json_rpc_2` exceptions and the
reconnect delay was five seconds. Errors are now wrapped in `RpcError` for
both transports and the retry delay is one second. See
[the 1.0.0 changelog](/changelog).
:::

## Chain and network identifiers

The SDK signs blocks against a chain identifier (`1` for Alphanet). If you
target a testnet, set it before building transactions, and set the network
identifier reported by your node:

```dart
setChainIdentifier(chainIdentifier: 3);
setNetworkId(networkId: 3);
```

`getChainIdentifier()` and `getNetworkId()` return the active values.
