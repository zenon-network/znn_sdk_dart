---
sidebar_position: 4
title: Stats
---

# StatsApi

Accessed via `zenon.stats` on the [`Zenon`](/api/zenon) singleton. Reports operational information about the connected full node: host OS, node process, peer network and sync progress.

```dart
final zenon = Zenon();
final sync = await zenon.stats.syncInfo();
```

## Methods

| Method | RPC | Description |
| --- | --- | --- |
| `osInfo` | `stats.osInfo` | Operating system and hardware details of the node's host. |
| `processInfo` | `stats.processInfo` | Version and commit of the running node process. |
| `networkInfo` | `stats.networkInfo` | The node's own peer identity and its connected peers. |
| `syncInfo` | `stats.syncInfo` | Momentum sync state and progress. |

## osInfo

```dart
Future<OsInfo> osInfo()
```

Returns an `OsInfo` describing the node's host: `os`, `platform`, `platformFamily`, `platformVersion`, `kernelVersion`, `memoryTotal`, `memoryFree`, `numCPU` and `numGoroutine`.

```dart
final zenon = Zenon();
final os = await zenon.stats.osInfo();
print('${os.os} on ${os.numCPU} CPUs, ${os.memoryFree}/${os.memoryTotal} bytes free');
```

## processInfo

```dart
Future<ProcessInfo> processInfo()
```

Returns a `ProcessInfo` with the node software's `version` and git `commit`.

```dart
final zenon = Zenon();
final process = await zenon.stats.processInfo();
print('Node version ${process.version} (${process.commit})');
```

## networkInfo

```dart
Future<NetworkInfo> networkInfo()
```

Returns a `NetworkInfo` with `numPeers`, the node's own identity as `self`, and the list of connected `peers`. Each `Peer` exposes `publicKey` and `ip`.

```dart
final zenon = Zenon();
final network = await zenon.stats.networkInfo();
print('Connected to ${network.numPeers} peers');
for (final peer in network.peers) {
  print('  ${peer.ip}');
}
```

## syncInfo

```dart
Future<SyncInfo> syncInfo()
```

Returns a `SyncInfo` with the node's momentum sync `state`, `currentHeight` and `targetHeight`. `state` is a `SyncState` enum value: `unknown`, `syncing`, `syncDone` or `notEnoughPeers`.

```dart
final zenon = Zenon();
final sync = await zenon.stats.syncInfo();
if (sync.state == SyncState.syncDone) {
  print('Node is in sync at height ${sync.currentHeight}');
} else {
  print('Syncing: ${sync.currentHeight}/${sync.targetHeight}');
}
```
