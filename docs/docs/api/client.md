---
sidebar_position: 2
title: Clients
---

# Clients

The SDK talks JSON-RPC 2.0 to a Zenon full node through implementations of the minimal `Client` interface:

```dart
abstract class Client {
  Future sendRequest(String method, [parameters]);
}
```

Two transports are provided: `WsClient` (WebSocket, stateful, supports subscriptions) and `HttpRpcClient` (HTTP/HTTPS, stateless, no subscriptions). The [`Zenon`](/api/zenon) singleton uses `wsClient` by default; `Zenon().setClient(...)` routes all API namespaces through any other `Client`.

## WsClient

`WsClient` is the default transport, available as `Zenon().wsClient`. It maintains a persistent WebSocket connection, multiplexes JSON-RPC requests over it, and exposes the raw notification stream that powers the [Subscribe](/api/subscribe) API.

The default WebSocket port of a Zenon full node is `35998` (`defaultWsPort`).

### initialize

```dart
Future<bool> initialize(String url, {bool retry = true})
```

Connects to the node at `url` (e.g. `ws://127.0.0.1:35998`). Returns `true` once the connection is established. With `retry: true` (the default) the client keeps retrying on connection failure, waiting between attempts; with `retry: false` it returns `false` after the first failed attempt. The connection is health-checked with a ping every 5 seconds.

:::note Changed in 1.0.0
The delay between reconnection attempts was reduced from 5 seconds to 1 second as part of [the 1.0.0 changelog](/changelog).
:::

```dart
final zenon = Zenon();
final connected = await zenon.wsClient.initialize('ws://127.0.0.1:35998', retry: false);
if (!connected) {
  print('Could not reach the node');
}
```

See the [connecting guide](/guides/connecting) for more.

### Status and lifecycle

```dart
WebsocketStatus status()
bool isClosed()
void restart()
void stop()
```

- `status()` returns the intended connection state: `uninitialized`, `connecting`, `running` or `stopped` (`WebsocketStatus` enum).
- `isClosed()` returns `true` when there is no live underlying JSON-RPC connection.
- `restart()` re-initializes the connection to the last used URL if the underlying connection dropped while the client was in the `running` state. This is also triggered automatically when the connection closes unexpectedly.
- `stop()` intentionally closes the connection; the client will not auto-reconnect afterwards.

### restartedStream

```dart
Stream<bool> get restartedStream
```

A broadcast stream that emits `true` whenever the client successfully re-establishes a connection after a drop. Useful for re-registering [subscriptions](/api/subscribe), which do not survive a reconnect:

```dart
zenon.wsClient.restartedStream.listen((_) async {
  print('Reconnected, re-subscribing...');
  await zenon.subscribe.toMomentums();
});
```

### addOnConnectionEstablishedCallback

```dart
void addOnConnectionEstablishedCallback(ConnectionEstablishedCallback callback)

typedef ConnectionEstablishedCallback = void Function(
    Stream<Map<String, dynamic>?> allResponseBroadcaster);
```

Registers a callback invoked each time a connection is established (including reconnects), receiving the broadcast stream of every raw JSON-RPC message from the node. If the client is already running, the callback fires immediately. This stream is how subscription notifications are consumed; see [Subscribe](/api/subscribe).

### sendRequest

```dart
Future sendRequest(String method, [parameters])
```

Sends a JSON-RPC request and completes with its `result`. Throws `noConnectionException` if the client is closed.

:::note Changed in 1.0.0
JSON-RPC error responses are now normalized: instead of surfacing the underlying `json_rpc_2` package's exception type, `sendRequest` throws an `RpcError` carrying the failed method, its parameters, and the error code, message and data. Part of [the 1.0.0 changelog](/changelog).
:::

## HttpRpcClient

:::note Added in 1.0.0
`HttpRpcClient` is part of [the 1.0.0 changelog](/changelog).
:::

```dart
class HttpRpcClient implements Client {
  final Uri url;

  HttpRpcClient(String url);

  void stop();

  @override
  Future sendRequest(String method, [parameters]);
}
```

A JSON-RPC 2.0 client over HTTP or HTTPS. Each `sendRequest` call is a self-contained HTTP POST — the transport is stateless per request, so there is no connection to initialize and nothing to reconnect. It does **not** support subscriptions; the [Subscribe](/api/subscribe) API requires `WsClient`.

The default HTTP port of a Zenon full node is `35997` (`defaultHttpPort`).

- `HttpRpcClient(String url)` parses `url` (e.g. `https://node:35997`) and is immediately ready to use.
- `sendRequest` throws `RpcError` on JSON-RPC error responses and on non-200 HTTP status codes, and `noConnectionException` on network failure or after `stop()` has been called.
- `stop()` closes the underlying HTTP client; subsequent requests throw `noConnectionException`.

Route the whole SDK through it with [`Zenon().setClient`](/api/zenon):

```dart
final zenon = Zenon();
zenon.setClient(HttpRpcClient('https://node:35997'));

final momentum = await zenon.ledger.getFrontierMomentum();
print('Height over HTTP: ${momentum.height}');

// Switch back to WebSocket:
zenon.setClient(zenon.wsClient);
```

## RpcError

:::note Added in 1.0.0
`RpcError` is part of [the 1.0.0 changelog](/changelog).
:::

```dart
class RpcError implements Exception {
  final String method;
  final dynamic params;
  final int? code;
  final String message;
  final dynamic data;

  RpcError(
      {required this.method,
      this.params,
      this.code,
      required this.message,
      this.data});
}
```

A normalized JSON-RPC error thrown by both `WsClient.sendRequest` and `HttpRpcClient.sendRequest`. It carries the context of the failed request (`method`, `params`) alongside the node's error `code`, `message` and optional `data`. Its `toString()` renders as `RPC error <code> for <method>: <message>`.

```dart
final zenon = Zenon();
try {
  await zenon.ledger.publishRawTransaction(block);
} on RpcError catch (e) {
  print('Node rejected ${e.method}: ${e.message} (code ${e.code})');
} on ZnnSdkException catch (e) {
  print('SDK error: $e');
}
```

## noConnectionException

```dart
final noConnectionException =
    ZnnSdkException('No connection to the Zenon full node');
```

A shared `ZnnSdkException` instance thrown when a request is attempted without a usable connection: by `WsClient.sendRequest` when the socket is closed, and by `HttpRpcClient` on network failure or after `stop()`.
