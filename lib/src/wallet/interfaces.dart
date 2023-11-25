import 'package:znn_sdk_dart/src/model/primitives.dart';
import 'package:znn_sdk_dart/src/model/nom/account_block_template.dart';

// Represents the definition of a wallet.
abstract class WalletDefinition {
  // Gets the id or path of the wallet.
  String get walletId;

  // Gets the name of the wallet.
  String get walletName;
}

// Represents the options for retrieving a wallet.
abstract class WalletOptions {}

// Represents the wallet manager for interacting with wallets.
abstract class WalletManager {
  // Gets the definition of wallets
  Future<Iterable<WalletDefinition>> getWalletDefinitions();

  // Gets a wallet by wallet definition.
  Future<Wallet> getWallet(WalletDefinition walletDefinition,
      WalletOptions? options);

  // Determines whether or not the manager supports the given wallet definition.
  // Returns true if the wallet is supported; otherwise false.
  Future<bool> supportsWallet(WalletDefinition walletDefinition);
}

// Represents a wallet.
abstract class Wallet {
  // Gets a wallet account by index.
  Future<WalletAccount> getAccount([int index = 0]);
}

// Represents the account of a wallet.
abstract class WalletAccount {
  // Gets the public key of the wallet account as an array of bytes.
  Future<List<int>> getPublicKey();

  // Gets the address of the wallet account.
  Future<Address> getAddress();

  // Signs an arbitrary message and returns the signature as an array of bytes.
  Future<List<int>> sign(List<int> message);

  // Signs a transaction and returns the signature as an array of bytes.
  Future<List<int>> signTx(AccountBlockTemplate tx);
}
