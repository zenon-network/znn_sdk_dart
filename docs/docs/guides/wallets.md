---
sidebar_position: 2
title: Wallets
---

# Wallets

Zenon accounts are Ed25519 key pairs derived from a BIP-39 mnemonic. The SDK
stores wallets as Argon2id-encrypted JSON key files, compatible with the
Syrius wallet.

## Create a wallet

```dart
// Fresh 24-word wallet
final keyStore = await KeyStore.newRandom();
print(keyStore.mnemonic);

// Or restore from an existing mnemonic
final restored = KeyStore.fromMnemonic('route become dream ...');
```

Derive accounts by index; each index yields a deterministic address:

```dart
final account0 = keyStore.getKeyPair(0);
final address = await account0.getAddress(); // z1q...
```

See the [wallet API reference](/api/wallet) for `KeyStore.fromSeed`,
`KeyStore.fromEntropy` and address-range derivation.

## Save an encrypted key file

`KeyStoreManager` manages key files in the platform's default wallet
directory (the same directory Syrius uses). `Zenon().keyStoreManager` holds
one, but exposes it through the generic `WalletManager` interface — for the
keystore-specific methods below, work with a typed instance:

```dart
final manager = KeyStoreManager(walletPath: znnDefaultWalletDirectory);
final definition = await manager.saveKeyStore(
  keyStore,
  'a strong password',
  name: 'my-wallet',
);
print('saved: ${definition.walletId}');
```

The file stores the wallet entropy encrypted with AES-256-GCM under an
Argon2id-derived key, together with metadata (wallet type and base address).

:::note Changed in 1.0.0
Key files now record their Argon2id parameters (`timeCost`, `memoryCost`,
`hashLength`, `parallelism`) instead of assuming hardcoded values, and
decryption validates the file's version, KDF, cipher and parameter bounds
before running the KDF. Legacy files without stored parameters still decrypt
using the historical defaults; check `EncryptedFile.needsUpgrade` and
re-save to upgrade them. See [the 1.0.0 changelog](/changelog).
:::

## Unlock a wallet

```dart
final definition = await manager.findKeyStore('my-wallet');
final wallet = await manager.readKeyStore(
  'a strong password',
  definition!.file,
);

Zenon().defaultKeyPair = wallet.getKeyPair(0);
```

A wrong password throws `IncorrectPasswordException`.

:::note Changed in 1.0.0
`readKeyStore` now verifies that the key file's stored base address matches
the address derived from the decrypted entropy, and throws
`WalletException` on mismatch — a corrupted or tampered key file can no
longer silently yield a different wallet.
:::

## Hygiene for key material

When you are done signing, wipe secrets instead of waiting for the garbage
collector:

```dart
keyPair.clear(); // zeroes private and public key buffers
```

`clear()` was added in [the 1.0.0 changelog](/changelog); a
cleared pair can no longer sign or derive addresses.
