---
sidebar_position: 6
title: Wallet
---

# Wallet

The wallet layer (`lib/src/wallet/`) manages key material: BIP-39 mnemonics, hierarchical key derivation, Ed25519 key pairs, and encrypted keystore files on disk. The main classes are `KeyStore` (an in-memory wallet derived from a mnemonic, seed, or entropy), `KeyPair` (a single account that can sign), `KeyStoreManager` (saves, reads, and lists encrypted keystore files), and `EncryptedFile` (the Argon2id + AES-256-GCM file format).

Everything is exported from `package:znn_sdk_dart/znn_sdk_dart.dart`. For a task-oriented walkthrough see [the wallets guide](/guides/wallets).

Addresses are derived on the BIP-44 path `m/44'/73404'/account'` (coin type `73404`), exposed by the `Derivation` helper:

```dart
class Derivation {
  static const String coinType = '73404';
  static const String derivationPath = "m/44'/$coinType'";

  static String getDerivationAccount([int account = 0]);
}
```

## KeyStore

`KeyStore` implements the `Wallet` interface. It holds the `mnemonic`, `entropy`, and `seed` (all hex/sentence strings) and derives `KeyPair` accounts by index.

| Member | Description |
| --- | --- |
| `KeyStore.fromMnemonic(String mnemonic)` | Build from a BIP-39 sentence (English wordlist; validates words and checksum) |
| `KeyStore.fromSeed(String seed)` | Build from a raw hex seed (no mnemonic/entropy available) |
| `KeyStore.fromEntropy(String seed)` | Build from hex entropy (128–256 bits, multiple of 32); derives the mnemonic and seed |
| `static Future<KeyStore> newRandom()` | Generate a keystore from 32 bytes of secure random entropy |
| `KeyPair getKeyPair([int index = 0])` | Derive the account at `index` |
| `Future<WalletAccount> getAccount([int index = 0])` | `Wallet` interface variant of `getKeyPair` |
| `Future<List<Address?>> deriveAddressesByRange(int left, int right)` | Derive addresses for indexes `[left, right)` |
| `Future<FindResponse?> findAddress(Address address, int numOfAddresses)` | Scan the first `numOfAddresses` indexes for `address` |

```dart
KeyStore.fromMnemonic(String mnemonic)
KeyStore.fromSeed(String seed)
KeyStore.fromEntropy(String seed)
static Future<KeyStore> newRandom()
KeyPair getKeyPair([int index = 0])
Future<List<Address?>> deriveAddressesByRange(int left, int right)
```

`KeyStore.fromMnemonic` and `KeyStore.fromEntropy` throw an `ArgumentError` when the input is invalid. `findAddress` returns a `FindResponse` (`path`, `index`, `keyPair`) or `null` if the address is not among the first `numOfAddresses` derived accounts.

### Create a wallet from a mnemonic and derive addresses

```dart
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

Future<void> main() async {
  // Generate a fresh 24-word mnemonic (256 bits of entropy)
  var mnemonic = Mnemonic.generateMnemonic(256);
  var keyStore = KeyStore.fromMnemonic(mnemonic);

  // The base address is account index 0
  var keyPair = keyStore.getKeyPair(0);
  var address = await keyPair.getAddress();
  print('Base address: $address');

  // Derive the first five addresses (indexes 0..4)
  var addresses = await keyStore.deriveAddressesByRange(0, 5);
  for (var a in addresses) {
    print(a);
  }
}
```

## KeyPair

`KeyPair` implements the `WalletAccount` interface: it holds the Ed25519 `privateKey` and `publicKey` byte lists and derives its `Address` lazily from the public key.

```dart
KeyPair(List<int>? privateKey, [List<int>? publicKey, Address? address])

List<int>? getPrivateKey()
Future<List<int>> getPublicKey()
Future<Address> getAddress()
Future<Address?> get address
Future<List<int>> sign(List<int> message)
Future<List<int>> signTx(AccountBlockTemplate tx)
Future<bool> verify(List<int> signature, List<int> message)
```

`sign` signs an arbitrary message; `signTx` signs the `hash` of an `AccountBlockTemplate` (see [Primitives](/api/primitives)). In practice you rarely call these directly — assign the pair to `zenon.defaultKeyPair` and let `zenon.send(...)` autofill, sign, and publish blocks (see [sending transactions](/guides/transactions)).

### clear

```dart
void clear()
```

:::note Added in 1.0.0
`KeyPair.clear()` zeroes the private and public key byte lists in place and then drops all references, including the cached address. The pair is unusable afterwards; signing or address derivation will fail. Call it when you are done with a key pair so key material does not linger in memory. See [the 1.0.0 changelog](/changelog).
:::

## KeyStoreManager

`KeyStoreManager` implements the `WalletManager` interface over a directory of encrypted keystore files. The `Zenon` singleton creates one at `znnDefaultWalletDirectory` as `zenon.keyStoreManager`.

| Method | Description |
| --- | --- |
| `saveKeyStore(KeyStore store, String password, {String? name})` | Encrypt the entropy and write a keystore file; the name defaults to the base address |
| `readKeyStore(String password, File keyStoreFile)` | Decrypt a keystore file back into a `KeyStore` |
| `findKeyStore(String name)` | Look up a keystore file by file name |
| `listAllKeyStores()` | List every keystore file in the wallet directory |
| `createNew(String passphrase, String? name)` | Generate a random keystore and save it |
| `createFromMnemonic(String mnemonic, String passphrase, String? name)` | Build a keystore from a mnemonic and save it |

```dart
KeyStoreManager({required Directory walletPath})

Future<KeyStoreDefinition> saveKeyStore(KeyStore store, String password, {String? name})
Future<KeyStore> readKeyStore(String password, File keyStoreFile)
Future<KeyStoreDefinition?> findKeyStore(String name)
Future<List<KeyStoreDefinition>> listAllKeyStores()
Future<KeyStoreDefinition> createNew(String passphrase, String? name)
Future<KeyStoreDefinition> createFromMnemonic(String mnemonic, String passphrase, String? name)
```

`KeyStoreDefinition` implements `WalletDefinition` and wraps the on-disk `File`; `walletId` is the file path and `walletName` its basename. The keystore file stores the encrypted entropy plus two metadata keys: `baseAddress` (the address of account 0) and `walletType` (`keystore`). `readKeyStore` throws a `WalletException` for a missing file or an unsupported wallet type, and an `IncorrectPasswordException` for a wrong password.

:::note Changed in 1.0.0
`readKeyStore` now verifies the stored `baseAddress` metadata against the address actually derived from the decrypted entropy, and throws a `WalletException` on mismatch. This detects corrupted or tampered keystore files whose metadata no longer matches the key material. See [the 1.0.0 changelog](/changelog).
:::

### Save and read a keystore

```dart
import 'dart:io';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

Future<void> main() async {
  var manager = KeyStoreManager(walletPath: znnDefaultWalletDirectory);

  // Create and save a wallet from a mnemonic
  var mnemonic = Mnemonic.generateMnemonic(256);
  var definition =
      await manager.createFromMnemonic(mnemonic, 'strong password', 'my-wallet');
  print('Saved keystore ${definition.walletName} at ${definition.walletId}');

  // Read it back later
  var keyStore =
      await manager.readKeyStore('strong password', File(definition.walletId));
  var address = await keyStore.getKeyPair(0).getAddress();
  print('Unlocked wallet with base address $address');
}
```

Through the generic `WalletManager` interface the same flow is `getWalletDefinitions()` followed by `getWallet(definition, KeyStoreOptions('strong password'))`.

## EncryptedFile

`EncryptedFile` is the keystore file format: the payload (the wallet entropy) is encrypted with AES-256-GCM under a key derived from the password with Argon2id.

```dart
static Future<EncryptedFile> encrypt(List<int> data, String password,
    {Map<String, dynamic>? metadata})
Future<List<int>> decrypt(String password)
EncryptedFile.fromJson(Map<String, dynamic> json)
Map<String, dynamic> toJson()
```

`decrypt` throws `IncorrectPasswordException` when GCM authentication fails.

:::note Changed in 1.0.0
Key files are now self-describing: `encrypt` stores the Argon2id KDF parameters (`timeCost`, `memoryCost`, `hashLength`, `parallelism`) alongside the salt, and `decrypt` uses the stored parameters instead of hard-coded values. Legacy files without stored parameters fall back to the defaults `timeCost` 1, `memoryCost` 65536 KiB, `hashLength` 32, `parallelism` 4 (exposed as the constants `argon2DefaultTimeCost`, `argon2DefaultMemoryCostKiB`, `argon2DefaultHashLength`, `argon2DefaultParallelism`).

A new getter reports whether a file predates self-describing parameters and should be re-encrypted:

```dart
bool get needsUpgrade
```

`decrypt` also strictly validates the file before deriving any key, throwing a `WalletException` for an unsupported `version` (only 1 is accepted), KDF (only `argon2.IDKey`), or cipher (only `aes-256-gcm`), for missing salt, nonce, or cipher data, and for out-of-bounds KDF parameters (`hashLength` must be 32; `timeCost` in `[1, 0xffffff]`; `parallelism` in `[1, 255]`; `memoryCost` in `[8 * parallelism, 4194304]` KiB), so a malformed or hostile key file cannot request pathological KDF resources. See [the 1.0.0 changelog](/changelog).
:::

## Mnemonic

Static helpers for BIP-39 mnemonics (English wordlist only).

```dart
static String generateMnemonic(int strength)
static bool validateMnemonic(List<String> words)
static bool isValidWord(String word)
```

`strength` is the entropy size in bits: 128, 160, 192, 224, or 256 (12–24 words). `validateMnemonic` checks words and checksum; `isValidWord` checks membership in the English wordlist.

## Exceptions

```dart
class WalletException implements Exception {
  String message;
  WalletException(this.message);
}

class IncorrectPasswordException extends ZnnSdkException {
  IncorrectPasswordException() : super('Incorrect password');
}
```

`WalletException` signals structural problems (missing files, unsupported wallet types, malformed key files, base-address mismatches); `IncorrectPasswordException` signals a failed decryption.

## Interfaces

`lib/src/wallet/interfaces.dart` defines the abstractions the keystore classes implement, so other wallet backends (for example hardware wallets) can plug into the same APIs:

```dart
abstract class WalletDefinition {
  String get walletId;
  String get walletName;
}

abstract class WalletOptions {}

abstract class WalletManager {
  Future<Iterable<WalletDefinition>> getWalletDefinitions();
  Future<Wallet> getWallet(WalletDefinition walletDefinition,
      [WalletOptions? options]);
  Future<bool> supportsWallet(WalletDefinition walletDefinition);
}

abstract class Wallet {
  Future<WalletAccount> getAccount([int index = 0]);
}

abstract class WalletAccount {
  Future<List<int>> getPublicKey();
  Future<Address> getAddress();
  Future<List<int>> sign(List<int> message);
  Future<List<int>> signTx(AccountBlockTemplate tx);
}
```

The concrete mappings are `KeyStoreDefinition` → `WalletDefinition`, `KeyStoreOptions(String decryptionPassword)` → `WalletOptions`, `KeyStoreManager` → `WalletManager`, `KeyStore` → `Wallet`, and `KeyPair` → `WalletAccount`. `zenon.defaultKeyPair` accepts any `WalletAccount`.
