---
sidebar_position: 11
title: Spork
---

# SporkApi

Accessed via `zenon.embedded.spork`.

The spork embedded contract governs network upgrades. A spork is created with a name and description, then activated by the spork governor; once its `enforcementHeight` is reached, nodes apply the associated protocol change.

## Methods

| Method | RPC | Description |
| --- | --- | --- |
| `getAll` | `embedded.spork.getAll` | Paginated list of all sporks |

### Contract methods

These return an unsigned `AccountBlockTemplate` that you pass to `zenon.send(...)` — see [sending transactions](/guides/transactions).

| Method | Description |
| --- | --- |
| `createSpork` | Register a new spork |
| `activateSpork` | Activate an existing spork |

## getAll

```dart
Future<SporkList> getAll({int pageIndex = 0, int pageSize = rpcMaxPageSize}) async
```

Returns a paginated `SporkList` (`count` plus `list` of `Spork`). Each `Spork` has an `id`, `name`, `description`, an `activated` flag, and the `enforcementHeight` at which it takes effect (`0` while not activated).

## createSpork

```dart
AccountBlockTemplate createSpork(String name, String description)
```

Builds a block that registers a new spork. Only the spork governor address is authorized to create sporks.

## activateSpork

```dart
AccountBlockTemplate activateSpork(Hash id)
```

Builds a block that activates the spork `id`, scheduling its enforcement. Only the spork governor address is authorized to activate sporks.

## Example

List sporks and their activation status:

```dart
final zenon = Zenon();
await zenon.wsClient.initialize('ws://127.0.0.1:35998');

final sporks = await zenon.embedded.spork.getAll();
for (final spork in sporks.list) {
  final status = spork.activated
      ? 'active at height ${spork.enforcementHeight}'
      : 'not activated';
  print('${spork.name}: $status');
}
```
