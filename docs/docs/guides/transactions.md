---
sidebar_position: 3
title: Sending transactions
---

# Sending transactions

Every action on the Network of Momentum — a transfer, a receive, a contract
call — is an account block published to the sender's own chain. Transactions
are feeless: instead of a fee, each block spends plasma (from fused QSR) or,
if none is available, a one-off proof of work.

## Build a block

`AccountBlockTemplate` has three factory constructors:

```dart
// Transfer tokens
final send = AccountBlockTemplate.send(toAddress, znnZts, amount);

// Receive a pending transfer
final receive = AccountBlockTemplate.receive(fromBlockHash);

// Call an embedded contract with ABI-encoded data
final call = AccountBlockTemplate.callContract(
    toAddress, tokenStandard, amount, data);
```

Amounts are unscaled `BigInt` values (`ZNN`/`QSR` use 8 decimals); convert
with `AmountUtils` — see [primitives](/api/primitives). You rarely build
contract calls by hand: every [embedded contract API](/api/embedded/)
returns a ready-made `AccountBlockTemplate`, e.g.
`zenon.embedded.pillar.delegate('pillar-name')`.

## Publish it

```dart
final zenon = Zenon();
zenon.defaultKeyPair = keyPair; // or pass currentKeyPair: explicitly

await zenon.send(block, generatingPowCallback: (status) {
  // PowStatus.generating, PowStatus.done
});
```

`zenon.send` runs the full lifecycle:

1. **Autofill** — sets version, chain identifier, address, height,
   `previousHash`, and the momentum acknowledged.
2. **Plasma or PoW** — asks the node
   (`embedded.plasma.getRequiredPoWForAccountBlock`) how much plasma the
   block needs. If the account's fused plasma covers it, the block spends
   plasma; otherwise the SDK generates proof of work for the required
   difficulty, reporting progress through `generatingPowCallback`.
3. **Hash and sign** — computes the block hash and signs it with the
   account's Ed25519 key.
4. **Publish** — `ledger.publishRawTransaction`.

Pass `waitForRequiredPlasma: true` to wait for plasma instead of generating
PoW.

Check ahead of time whether a block will need PoW:

```dart
final needsPow = await zenon.requiresPoW(block);
```

## Prepare without publishing

:::note Added in 1.0.0
`prepareBlock` is new — see [the 1.0.0 changelog](/changelog).
:::

`zenon.prepareBlock` performs steps 1–3 and returns the signed block without
sending it. Use it to inspect, queue, or broadcast blocks through your own
channel:

```dart
final signed = await zenon.prepareBlock(block);
// later, or elsewhere:
await zenon.ledger.publishRawTransaction(signed);
```

`publishRawTransaction` completes with `null` when the node accepts the
block, and throws if the node reports an error (as an `RpcError`) or returns
an unexpected non-null result.

## Complete the transfer

Transfers finish when the recipient publishes a receive block. Poll
`ledger.getUnreceivedBlocksByAddress`, or react in real time with a
[subscription](/api/subscribe):

```dart
final unreceived =
    await zenon.ledger.getUnreceivedBlocksByAddress(address);
for (final b in unreceived.list!) {
  await zenon.send(AccountBlockTemplate.receive(b.hash));
}
```

## Related pages

- [Plasma API](/api/embedded/plasma) — fuse QSR so your accounts never need
  PoW
- [Proof of work](/api/pow) — custom PoW backends and nonce verification
- [Ledger API](/api/ledger) — account blocks and momentums
