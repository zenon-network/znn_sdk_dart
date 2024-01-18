import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:hex/hex.dart';
import 'package:path/path.dart' as path;
import 'package:znn_sdk_dart/src/global.dart';
import 'package:znn_sdk_dart/src/wallet/exceptions.dart';
import 'package:znn_sdk_dart/src/wallet/keystore.dart';
import 'package:znn_sdk_dart/src/wallet/interfaces.dart';
import 'package:znn_sdk_dart/src/wallet/encryptedfile.dart';

class KeyStoreOptions implements WalletOptions {
  final String decryptionPassword;
  KeyStoreOptions(this.decryptionPassword);
}

class SaveKeyStoreArguments {
  final KeyStore store;
  final String password;
  final String name;
  final SendPort port;

  SaveKeyStoreArguments(this.store, this.password, this.name, this.port);
}

void saveKeyStoreFunction(SaveKeyStoreArguments args) async {
  var encrypted =
      await EncryptedFile.encrypt(HEX.decode(args.store.entropy), args.password);
  args.port.send(json.encode(encrypted));
}

class KeyStoreManager implements WalletManager {
  final Directory walletPath;
  KeyStore? keyStoreInUse;

  KeyStoreManager({required this.walletPath});

  Future<KeyStoreDefinition> saveKeyStore(KeyStore store, String password,
      {String? name}) async {
    name ??= (await store.getKeyPair(0).address).toString();

    final port = ReceivePort();

    final args = SaveKeyStoreArguments(store, password, name, port.sendPort);
    Isolate? isolate = await Isolate.spawn<SaveKeyStoreArguments>(
        saveKeyStoreFunction, args,
        onError: port.sendPort, onExit: port.sendPort);

    StreamSubscription? sub;
    var completer = Completer<KeyStoreDefinition>();

    sub = port.listen((data) async {
      if (data != null) {
        if (data is String) {
          logger.info(data);
          var location = File(path.join(walletPath.path, name));
          await location.writeAsString(data);
          completer.complete(KeyStoreDefinition(file: location));
        } else {
          throw data;
        }
        await sub?.cancel();
        if (isolate != null) {
          isolate!.kill(priority: Isolate.immediate);
          isolate = null;
        }
      }
    });
    return completer.future;
  }

  void setKeyStore(KeyStore keyStore) {
    keyStoreInUse = keyStore;
  }

  String? getMnemonicInUse() {
    if (keyStoreInUse == null) {
      throw ArgumentError('The keyStore in use is null');
    }
    return keyStoreInUse!.mnemonic;
  }

  Future<KeyStore> readKeyStore(String password, File keyStoreFile) async {
    if (!keyStoreFile.existsSync()) {
      throw InvalidWalletPath(
          'Given keyStore does not exist ($keyStoreFile)');
    }

    var content = await keyStoreFile.readAsString();
    var seed =
        await EncryptedFile.fromJson(json.decode(content)).decrypt(password);
    return KeyStore.fromEntropy(HEX.encode(seed));
  }

  Future<KeyStoreDefinition?> findKeyStore(String name) async {
    for (var file in walletPath.listSync()) {
      if (path.basename(file.path) == name) {
        if (file is File) {
          return KeyStoreDefinition(file: file);
        } else {
          throw InvalidWalletPath('Given keyStore is not a file ($name)');
        }
      }
    }
    return null;
  }

  Future<List<KeyStoreDefinition>> listAllKeyStores() async {
    var keyStoreList = <KeyStoreDefinition>[];
    for (var keyStore in walletPath.listSync()) {
      if (keyStore is File) {
        keyStoreList.add(KeyStoreDefinition(file: keyStore));
      }
    }
    return keyStoreList;
  }

  Future<KeyStoreDefinition> createNew(String passphrase, String? name) async {
    var store = await KeyStore.newRandom();
    var keyStore = await saveKeyStore(store, passphrase, name: name);
    return keyStore;
  }

  Future<KeyStoreDefinition> createFromMnemonic(
      String mnemonic, String passphrase, String? name) async {
    var store = KeyStore.fromMnemonic(mnemonic);
    return await saveKeyStore(store, passphrase, name: name);
  }

  Future<Iterable<WalletDefinition>> getWalletDefinitions() async {
    return listAllKeyStores();
  }

  Future<Wallet> getWallet(WalletDefinition walletDefinition,
      [WalletOptions? walletOptions]) async {
    if (!(walletDefinition is KeyStoreDefinition)) {
      throw Exception(
          "Unsupported wallet definition ${walletDefinition.runtimeType}.");
    }
    if (!(walletOptions is KeyStoreOptions)) {
      throw Exception(
          "Unsupported wallet options ${walletOptions.runtimeType}.");
    }
    return await readKeyStore(
        walletOptions.decryptionPassword, walletDefinition.file);
  }

  Future<bool> supportsWallet(WalletDefinition walletDefinition) async {
    if (walletDefinition is KeyStoreDefinition) {
      for (var definition in await getWalletDefinitions()) {
        if (definition.walletId == walletDefinition.walletId) return true;
      }
    }
    return false;
  }
}
