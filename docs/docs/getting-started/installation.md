---
sidebar_position: 1
title: Installation
---

# Installation

## Requirements

- Dart SDK `>=3.7.0 <4.0.0` (or a Flutter release that bundles it)
- A Zenon full node to connect to — your own
  [`go-zenon`](https://github.com/zenon-network/go-zenon) node or a community
  endpoint

## Add the package

```bash
dart pub add znn_sdk_dart
```

or add it to `pubspec.yaml` yourself:

```yaml
dependencies:
  znn_sdk_dart: ^1.0.0
```

then:

```bash
dart pub get
```

Import the single entry point:

```dart
import 'package:znn_sdk_dart/znn_sdk_dart.dart';
```

## Native libraries

Two features call into native code:

- **Argon2** — key-file encryption and decryption uses `argon2_ffi_base`.
- **Proof of work** — `generatePoW` loads the `libpow_links` shared library
  (`.dll` / `.so` / `.dylib`) from the directory of the running executable or
  a `blobs/` subdirectory.

Desktop Dart applications should ship the matching binaries next to the
executable. If you cannot bundle native binaries (for example on some mobile
or web-adjacent targets), you can route proof-of-work generation through a
custom backend with `setPowProvider` — see [proof of work](/api/pow).

## Node endpoints

A default `go-zenon` node exposes:

| Transport | Default port | SDK client |
| --- | --- | --- |
| WebSocket | `35998` | `WsClient` |
| HTTP | `35997` | `HttpRpcClient` |

Subscriptions are only available over WebSocket. See
[connecting to a node](/guides/connecting).
