---
sidebar_position: 9
title: Bridge
---

# BridgeApi

Accessed via `zenon.embedded.bridge`.

The bridge embedded contract moves assets between Zenon and external networks. Wrapping locks a ZTS token on Zenon and mints it on the destination network; unwrapping burns or locks it there and redeems it back on Zenon. The contract is operated by an orchestrator network and protected by guardians and an administrator.

:::note Changed in 1.0.0
`getSecurityInfo`, `getTimeChallengesInfo`, and `getBridgeInfo` now send an explicit empty params list (`[]`) instead of omitting the `params` field, which some nodes reject. `getAllNetworks` previously ignored its `pageSize` argument and always sent `rpcMaxPageSize`; it now passes `pageSize` through. See [the 1.0.0 changelog](/changelog).
:::

## Methods

| Method | RPC | Description |
| --- | --- | --- |
| `getSecurityInfo` | `embedded.bridge.getSecurityInfo` | Guardians, guardian votes, and administrative delays |
| `getTimeChallengesInfo` | `embedded.bridge.getTimeChallengesInfo` | Active time challenges for security-sensitive methods |
| `getBridgeInfo` | `embedded.bridge.getBridgeInfo` | Global bridge state (administrator, TSS key, halt status, metadata) |
| `getOrchestratorInfo` | `embedded.bridge.getOrchestratorInfo` | Orchestrator parameters (window size, key-gen threshold, confirmations) |
| `getNetworkInfo` | `embedded.bridge.getNetworkInfo` | A connected network by class and chain id |
| `getAllNetworks` | `embedded.bridge.getAllNetworks` | Paginated list of connected networks |
| `getWrapTokenRequestById` | `embedded.bridge.getWrapTokenRequestById` | A wrap request by id |
| `getAllWrapTokenRequests` | `embedded.bridge.getAllWrapTokenRequests` | Paginated list of wrap requests |
| `getAllWrapTokenRequestsByToAddress` | `embedded.bridge.getAllWrapTokenRequestsByToAddress` | Wrap requests for a destination address |
| `getAllWrapTokenRequestsByToAddressNetworkClassAndChainId` | `embedded.bridge.getAllWrapTokenRequestsByToAddressNetworkClassAndChainId` | Wrap requests filtered by destination address and network |
| `getAllUnsignedWrapTokenRequests` | `embedded.bridge.getAllUnsignedWrapTokenRequests` | Wrap requests not yet signed by the orchestrator |
| `getUnwrapTokenRequestByHashAndLog` | `embedded.bridge.getUnwrapTokenRequestByHashAndLog` | An unwrap request by source transaction hash and log index |
| `getAllUnwrapTokenRequests` | `embedded.bridge.getAllUnwrapTokenRequests` | Paginated list of unwrap requests |
| `getAllUnwrapTokenRequestsByToAddress` | `embedded.bridge.getAllUnwrapTokenRequestsByToAddress` | Unwrap requests for a destination address |
| `getFeeTokenPair` | `embedded.bridge.getFeeTokenPair` | Accumulated fees for a ZTS token |

### Contract methods

These return an unsigned `AccountBlockTemplate` that you pass to `zenon.send(...)` — see [sending transactions](/guides/transactions).

| Method | Description |
| --- | --- |
| `wrapToken` | Lock tokens for transfer to an external network |
| `updateWrapRequest` | Attach an orchestrator signature to a wrap request |
| `redeem` | Redeem a finalized unwrap request on Zenon |
| `unwrapToken` | Register an unwrap request (with orchestrator signature) |
| `halt` | Halt bridge operation (administrator, or with signature) |
| `proposeAdministrator` | Propose a new administrator (guardian, in emergency) |
| `setNetwork` | Add or configure a connected network (administrator) |
| `removeNetwork` | Remove a connected network (administrator) |
| `setNetworkMetadata` | Update a network's metadata (administrator) |
| `setTokenPair` | Add or update a ZTS/external token pair (administrator) |
| `removeTokenPair` | Remove a token pair (administrator) |
| `changeTssECDSAPubKey` | Rotate the TSS ECDSA public key |
| `unhalt` | Resume bridge operation (administrator) |
| `emergency` | Put the bridge into emergency mode (administrator) |
| `changeAdministrator` | Transfer the administrator role (administrator) |
| `setAllowKeyGen` | Allow or disallow TSS key generation (administrator) |
| `setBridgeMetadata` | Update global bridge metadata (administrator) |
| `revokeUnwrapRequest` | Revoke an unwrap request (administrator) |
| `nominateGuardians` | Nominate the guardian set (administrator) |
| `setOrchestratorInfo` | Update orchestrator parameters (administrator) |

## Query methods

### getSecurityInfo

```dart
Future<SecurityInfo> getSecurityInfo() async
```

Returns the `SecurityInfo`: current `guardians`, pending `guardiansVotes`, and the `administratorDelay` and `softDelay` applied to sensitive operations.

### getTimeChallengesInfo

```dart
Future<TimeChallengesList> getTimeChallengesInfo() async
```

Returns the list of active time challenges — security-sensitive contract methods that must be invoked twice, separated by a delay, before taking effect.

### getBridgeInfo

```dart
Future<BridgeInfo> getBridgeInfo() async
```

Returns the global `BridgeInfo` state, including the administrator address, the current TSS ECDSA public key, halt/unhalt state, and metadata.

### getOrchestratorInfo

```dart
Future<OrchestratorInfo> getOrchestratorInfo() async
```

Returns the `OrchestratorInfo`: window size, key-gen threshold, confirmations to finality, and estimated momentum time.

### getNetworkInfo / getAllNetworks

```dart
Future<BridgeNetworkInfo> getNetworkInfo(int networkClass, int chainId) async
```

```dart
Future<BridgeNetworkInfoList> getAllNetworks(
    {int pageIndex = 0, int pageSize = rpcMaxPageSize}) async
```

Return one or all connected networks. A network is identified by its `networkClass` (e.g. `2` for EVM networks) and `chainId`; each `BridgeNetworkInfo` includes its name, contract address, metadata, and configured token pairs.

### Wrap request queries

```dart
Future<WrapTokenRequest> getWrapTokenRequestById(Hash id) async
```

```dart
Future<WrapTokenRequestList> getAllWrapTokenRequests(
    {int pageIndex = 0, int pageSize = rpcMaxPageSize}) async
```

```dart
Future<WrapTokenRequestList> getAllWrapTokenRequestsByToAddress(
    String toAddress, {int pageIndex = 0, int pageSize = rpcMaxPageSize}) async
```

```dart
Future<WrapTokenRequestList>
    getAllWrapTokenRequestsByToAddressNetworkClassAndChainId(
        String toAddress, int networkClass, int chainId,
        {int pageIndex = 0, int pageSize = rpcMaxPageSize}) async
```

```dart
Future<WrapTokenRequestList> getAllUnsignedWrapTokenRequests(
    {int pageIndex = 0, int pageSize = rpcMaxPageSize}) async
```

Query wrap (Zenon to external network) requests, optionally filtered by destination address and network. `toAddress` is the address on the destination network, passed as a string.

### Unwrap request queries

```dart
Future<UnwrapTokenRequest> getUnwrapTokenRequestByHashAndLog(
    Hash txHash, int logIndex) async
```

```dart
Future<UnwrapTokenRequestList> getAllUnwrapTokenRequests(
    {int pageIndex = 0, int pageSize = rpcMaxPageSize}) async
```

```dart
Future<UnwrapTokenRequestList> getAllUnwrapTokenRequestsByToAddress(
    String toAddress, {int pageIndex = 0, int pageSize = rpcMaxPageSize}) async
```

Query unwrap (external network to Zenon) requests. An unwrap request is identified by the source-network transaction hash and log index.

### getFeeTokenPair

```dart
Future<ZtsFeesInfo> getFeeTokenPair(TokenStandard zts) async
```

Returns the accumulated bridge fees for the given ZTS token.

## User contract methods

### wrapToken

```dart
AccountBlockTemplate wrapToken(int networkClass, int chainId,
    String toAddress, BigInt amount, TokenStandard tokenStandard)
```

Builds a block that sends `amount` of `tokenStandard` to the bridge for wrapping to `toAddress` on the destination network.

### redeem

```dart
AccountBlockTemplate redeem(Hash transactionHash, int logIndex)
```

Builds a block redeeming a finalized unwrap request, releasing the tokens to the request's Zenon destination address. Callable once the request's redeem delay has passed.

### updateWrapRequest / unwrapToken

```dart
AccountBlockTemplate updateWrapRequest(Hash id, String signature)
```

```dart
AccountBlockTemplate unwrapToken(int networkClass, int chainId,
    Hash transactionHash, int logIndex, Address toAddress,
    String tokenAddress, BigInt amount, String signature)
```

Orchestrator-facing methods: `updateWrapRequest` attaches the TSS `signature` to a wrap request; `unwrapToken` registers an unwrap request observed on the source network, again authenticated by `signature`.

## Guardian and administrator contract methods

```dart
AccountBlockTemplate proposeAdministrator(Address address)
```

```dart
AccountBlockTemplate halt(String signature)
```

```dart
AccountBlockTemplate unhalt()
```

```dart
AccountBlockTemplate emergency()
```

```dart
AccountBlockTemplate changeAdministrator(Address administrator)
```

```dart
AccountBlockTemplate nominateGuardians(List<Address> guardians)
```

```dart
AccountBlockTemplate changeTssECDSAPubKey(
    String pubKey, String oldPubKeySignature, String newPubKeySignature)
```

```dart
AccountBlockTemplate setAllowKeyGen(bool allowKeyGen)
```

```dart
AccountBlockTemplate setBridgeMetadata(String metadata)
```

```dart
AccountBlockTemplate revokeUnwrapRequest(Hash transactionHash, int logIndex)
```

```dart
AccountBlockTemplate setOrchestratorInfo(int windowSize, int keyGenThreshold,
    int confirmationsToFinality, int estimatedMomentumTime)
```

Governance operations. `halt` accepts either an empty `signature` when sent by the administrator or a valid TSS signature otherwise; `proposeAdministrator` is used by guardians during emergency to elect a new administrator; the rest are administrator-only.

### Network and token pair management

```dart
AccountBlockTemplate setNetwork(int networkClass, int chainId, String name,
    String contractAddress, String metadata)
```

```dart
AccountBlockTemplate removeNetwork(int networkClass, int chainId)
```

```dart
AccountBlockTemplate setNetworkMetadata(int networkClass, int chainId, String metadata)
```

```dart
AccountBlockTemplate setTokenPair(int networkClass, int chainId,
    TokenStandard tokenStandard, String tokenAddress, bool bridgeable,
    bool redeemable, bool owned, BigInt minAmount, int feePercentage,
    int redeemDelay, String metadata)
```

```dart
AccountBlockTemplate removeTokenPair(int networkClass, int chainId,
    TokenStandard tokenStandard, String tokenAddress)
```

Administrator-only configuration of connected networks and of the ZTS/external token pairs that can cross the bridge.

## Examples

List connected networks and inspect the bridge state:

```dart
final zenon = Zenon();
await zenon.wsClient.initialize('ws://127.0.0.1:35998');

final bridgeInfo = await zenon.embedded.bridge.getBridgeInfo();
final networks = await zenon.embedded.bridge.getAllNetworks(pageSize: 10);
for (final network in networks.list) {
  print('${network.name} (class ${network.networkClass}, '
      'chainId ${network.chainId})');
}
```

Wrap `100` `ZNN` to an EVM address:

```dart
final zenon = Zenon();
// ... connect and set zenon.defaultKeyPair (see /guides/wallets)

final block = zenon.embedded.bridge.wrapToken(
  2, // networkClass: EVM
  1, // chainId: Ethereum mainnet
  '0x1234567890123456789012345678901234567890',
  BigInt.from(100 * 100000000), // 100 ZNN, 8 decimals
  znnZts,
);
await zenon.send(block);
```
