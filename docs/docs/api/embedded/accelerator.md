---
sidebar_position: 7
title: Accelerator-Z
---

# AcceleratorApi

Accessed via `zenon.embedded.accelerator`.

The Accelerator-Z embedded contract funds ecosystem development. Projects are submitted with `ZNN`/`QSR` funding targets, voted on by Pillars, and paid out phase by phase.

:::note Changed in 1.0.0
The Accelerator-Z ABI definition gained the `Update` function, so calldata for that contract method can now be decoded. In addition, `Phase.toJson` now emits the node's nested `{"phase": {...}, "votes": {...}}` shape (with the `projectID` key), `Project.toJson` emits a proper `phaseIds` list plus `votes` and `phases`, and `ProjectList.findProjectByPhaseId` no longer loops forever when the phase id is not in the first project. See [the 1.0.0 changelog](/changelog).
:::

## Methods

| Method | RPC | Description |
| --- | --- | --- |
| `getAll` | `embedded.accelerator.getAll` | Paginated list of all projects |
| `getProjectById` | `embedded.accelerator.getProjectById` | A single project by id |
| `getPhaseById` | `embedded.accelerator.getPhaseById` | A single phase by id |
| `getPillarVotes` | `embedded.accelerator.getPillarVotes` | A Pillar's votes for a set of project/phase hashes |
| `getVoteBreakdown` | `embedded.accelerator.getVoteBreakdown` | Yes/no/total vote counts for an id |

### Contract methods

These return an unsigned `AccountBlockTemplate` that you pass to `zenon.send(...)` — see [sending transactions](/guides/transactions).

| Method | Description |
| --- | --- |
| `createProject` | Submit a new project (costs the `1` `ZNN` project creation fee) |
| `addPhase` | Add a phase to an owned project |
| `updatePhase` | Update the current phase of an owned project |
| `donate` | Donate funds to the Accelerator-Z contract |
| `voteByName` | Vote on an id as a Pillar, identified by name |
| `voteByProdAddress` | Vote on an id as a Pillar, identified by producer address |

## getAll

```dart
Future<ProjectList> getAll({int pageIndex = 0, int pageSize = rpcMaxPageSize}) async
```

Returns a paginated `ProjectList` (`count` plus `list` of `Project`). Each `Project` carries its funding targets, status, `VoteBreakdown`, and its `phases`. `rpcMaxPageSize` is `1024`.

`ProjectList` also offers client-side lookups: `findId(Hash id)` and `findProjectByPhaseId(Hash id)`.

:::note Changed in 1.0.0
`ProjectList.findProjectByPhaseId` previously incremented the wrong loop variable and could hang; it now iterates phase ids correctly. See [the 1.0.0 changelog](/changelog).
:::

## getProjectById

```dart
Future<Project> getProjectById(String id) async
```

Returns the `Project` with the given id (hex hash string).

## getPhaseById

```dart
Future<Phase> getPhaseById(Hash id) async
```

Returns the `Phase` with the given id. A phase references its parent project through `projectId`.

## getPillarVotes

```dart
Future<List<PillarVote?>> getPillarVotes(String name, List<String> hashes) async
```

Returns the votes cast by the Pillar `name` for each hash in `hashes`. Entries are `null` where the Pillar has not voted.

## getVoteBreakdown

```dart
Future<VoteBreakdown> getVoteBreakdown(Hash id) async
```

Returns the `yes`/`no`/`total` vote counts for a project or phase id.

## createProject

```dart
AccountBlockTemplate createProject(String name, String description,
    String url, BigInt znnFundsNeeded, BigInt qsrFundsNeeded)
```

Builds a block that submits a new project. The block sends the project creation fee of `1` `ZNN` to the Accelerator-Z contract.

## addPhase / updatePhase

```dart
AccountBlockTemplate addPhase(Hash id, String name, String description,
    String url, BigInt znnFundsNeeded, BigInt qsrFundsNeeded)
```

```dart
AccountBlockTemplate updatePhase(Hash id, String name, String description,
    String url, BigInt znnFundsNeeded, BigInt qsrFundsNeeded)
```

`addPhase` adds a phase to the project `id`; `updatePhase` updates a phase (pass the phase `id`). Only the project owner can call these.

## donate

```dart
AccountBlockTemplate donate(BigInt amount, TokenStandard zts)
```

Builds a block donating `amount` of token `zts` to the Accelerator-Z contract.

## voteByName / voteByProdAddress

```dart
AccountBlockTemplate voteByName(Hash id, String pillarName, int vote)
```

```dart
AccountBlockTemplate voteByProdAddress(Hash id, int vote)
```

Cast a Pillar vote on a project or phase id. `vote` is `0` (yes), `1` (no), or `2` (abstain), matching the `AcceleratorProjectVote` enum.

## Examples

Query projects and their funding status:

```dart
final zenon = Zenon();
await zenon.wsClient.initialize('ws://127.0.0.1:35998');

final projects = await zenon.embedded.accelerator.getAll(pageIndex: 0, pageSize: 10);
for (final project in projects.list) {
  print('${project.name}: ${project.status} '
      '(${project.getRemainingZnnFunds()} ZNN remaining)');
}
```

Submit a new project:

```dart
final zenon = Zenon();
// ... connect and set zenon.defaultKeyPair (see /guides/wallets)

final block = zenon.embedded.accelerator.createProject(
  'My project',
  'A short description',
  'https://example.com',
  BigInt.from(5000 * 100000000), // 5000 ZNN, 8 decimals
  BigInt.from(50000 * 100000000), // 50000 QSR
);
await zenon.send(block);
```
