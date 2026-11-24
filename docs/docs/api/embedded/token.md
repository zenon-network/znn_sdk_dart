---
sidebar_position: 6
title: Token
---

# TokenApi

Accessed via `zenon.embedded.token`.

The token embedded contract manages Zenon Token Standard (ZTS) tokens. This namespace queries the token registry and builds transactions for issuing, minting, burning, and updating tokens.

## Methods

| Method | RPC | Description |
|---|---|---|
| `getAll` | `embedded.token.getAll` | Paginated list of all ZTS tokens |
| `getByOwner` | `embedded.token.getByOwner` | Tokens owned by an address |
| `getByZts` | `embedded.token.getByZts` | A single token by its ZTS identifier, or `null` |

### Contract methods

Each returns an unsigned `AccountBlockTemplate` addressed to the token contract; pass it to `zenon.send(...)` (see [the transactions guide](/guides/transactions)).

| Method | Description |
|---|---|
| `issueToken` | Issue a new ZTS token; sends the fee `tokenZtsIssueFeeInZnn` (`1` ZNN) |
| `mintToken` | Mint additional supply of a mintable token (owner only) |
| `burnToken` | Burn an amount of a token; sends the tokens themselves |
| `updateToken` | Change a token's owner and mintable/burnable flags (owner only) |

## Query methods

### getAll

```dart
Future<TokenList> getAll({int pageIndex = 0, int pageSize = rpcMaxPageSize})
```

Returns the token registry as a `TokenList` (`count` plus a list of `Token`). A `Token` carries `name`, `symbol`, `domain`, `totalSupply` and `maxSupply` (`BigInt`), `decimals`, `owner`, `tokenStandard`, and the `isMintable`, `isBurnable`, and `isUtility` flags. `rpcMaxPageSize` is `1024`.

### getByOwner

```dart
Future<TokenList> getByOwner(Address address,
    {int pageIndex = 0, int pageSize = rpcMaxPageSize})
```

Returns the tokens whose `owner` is `address`.

### getByZts

```dart
Future<Token?> getByZts(TokenStandard tokenStandard)
```

Returns the token identified by `tokenStandard` (a `zts…` identifier, see [primitives](/api/primitives)), or `null` if it does not exist.

## Contract methods

### issueToken

```dart
AccountBlockTemplate issueToken(
    String tokenName,
    String tokenSymbol,
    String tokenDomain,
    BigInt totalSupply,
    BigInt maxSupply,
    int decimals,
    bool mintable,
    bool burnable,
    bool utility)
```

Builds an `IssueToken` call that sends the issuance fee `tokenZtsIssueFeeInZnn` (`1` ZNN) to the token contract. `totalSupply` and `maxSupply` are in the token's own base units as defined by `decimals`. Validation constraints from `lib/src/embedded/constants.dart`:

- `tokenName`: at most `40` characters, matching `^([a-zA-Z0-9]+[-._]?)*[a-zA-Z0-9]$`
- `tokenSymbol`: at most `10` characters, matching `^[A-Z0-9]+$`; `ZNN` and `QSR` are reserved
- `tokenDomain`: a valid domain name
- `maxSupply` at least `1` and at most `2^255 - 1`

The new token's ZTS identifier is derived on-chain; after the block is confirmed you can find the token via `getByOwner`.

### mintToken

```dart
AccountBlockTemplate mintToken(
    TokenStandard tokenStandard, BigInt amount, Address receiveAddress)
```

Builds a `Mint` call (zero ZNN) that mints `amount` base units of `tokenStandard` to `receiveAddress`. Only the token owner can mint, and only if the token `isMintable`.

### burnToken

```dart
AccountBlockTemplate burnToken(TokenStandard tokenStandard, BigInt amount)
```

Builds a `Burn` call that sends `amount` base units of `tokenStandard` itself to the token contract, permanently destroying them. The token must be `isBurnable` for non-owners.

### updateToken

```dart
AccountBlockTemplate updateToken(TokenStandard tokenStandard, Address owner,
    bool isMintable, bool isBurnable)
```

Builds an `UpdateToken` call (zero ZNN) that transfers ownership to `owner` and sets the `isMintable` and `isBurnable` flags. Only the current owner can update a token. The `isUtility` flag is not part of the update call and cannot be changed.

## Examples

Issue a token and mint additional supply:

```dart
final zenon = Zenon();
final address = await zenon.defaultKeyPair!.getAddress();

// 100.00000000 total supply with 8 decimals; sends the 1 ZNN issuance fee
await zenon.send(zenon.embedded.token.issueToken(
    'MyToken',
    'MYT',
    'mytoken.example.com',
    AmountUtils.extractDecimals('100', 8),
    AmountUtils.extractDecimals('1000', 8),
    8,
    true, // mintable
    true, // burnable
    false // utility
    ));

// Once confirmed, look the token up and mint 50 more to yourself
final tokens = await zenon.embedded.token.getByOwner(address);
final myToken = tokens.list!.firstWhere((t) => t.symbol == 'MYT');
await zenon.send(zenon.embedded.token.mintToken(
    myToken.tokenStandard, AmountUtils.extractDecimals('50', 8), address));
```

Burn part of a balance:

```dart
final zenon = Zenon();

final token = await zenon.embedded.token.getByZts(myTokenStandard);
if (token != null && token.isBurnable) {
  await zenon.send(zenon.embedded.token.burnToken(
      token.tokenStandard, AmountUtils.extractDecimals('10', token.decimals)));
}
```
