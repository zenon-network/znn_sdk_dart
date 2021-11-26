import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as path;
import 'package:znn_sdk_dart/src/global.dart';
import 'package:znn_sdk_dart/src/wallet/exceptions.dart';
import 'package:znn_sdk_dart/src/wallet/keyfile.dart';
import 'package:znn_sdk_dart/src/wallet/keystore.dart';

class SaveKeyStoreArguments {
  final KeyStore store;
  final String password;
  final String name;
  final SendPort port;

  SaveKeyStoreArguments(this.store, this.password, this.name, this.port);
}

void saveKeyStoreFunction(SaveKeyStoreArguments args) async {
  var encrypted = await KeyFile.encrypt(args.store, args.password);
  args.port.send(json.encode(encrypted));
}

class KeyStoreManager {
  Directory? walletPath;
  KeyStore? keyStoreInUse;

  KeyStoreManager({this.walletPath});

  Future<File> saveKeyStore(KeyStore store, String password,
      {String? name}) async {
    name ??= (await store.getKeyPair(0).address).toString();

    final port = ReceivePort();

    final args = SaveKeyStoreArguments(store, password, name, port.sendPort);
    Isolate? isolate = await Isolate.spawn<SaveKeyStoreArguments>(
        saveKeyStoreFunction, args,
        onError: port.sendPort, onExit: port.sendPort);

    StreamSubscription? sub;
    var completer = Completer<File>();

    sub = port.listen((data) async {
      if (data != null) {
        if (data is String) {
          logger.info(data);
          var location = File(path.join(walletPath!.path, name));
          await location.writeAsString(data);
          completer.complete(location);
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
      throw InvalidKeyStorePath(
          'Given keyStore does not exist ($keyStoreFile)');
    }

    var content = await keyStoreFile.readAsString();
    return KeyFile.fromJson(json.decode(content)).decrypt(password);
  }

  Future<File?> findKeyStore(String name) async {
    for (var file in walletPath!.listSync()) {
      if (path.basename(file.path) == name) {
        if (file is File) {
          return file;
        } else {
          throw InvalidKeyStorePath('Given keyStore is not a file ($name)');
        }
      }
    }
    return null;
  }

  Future<List<File>> listAllKeyStores() async {
    var keyStoreList = <File>[];
    for (var keyStore in walletPath!.listSync()) {
      if (keyStore is File) {
        keyStoreList.add(keyStore);
      }
    }
    return keyStoreList;
  }

  Future<File> createNew(String passphrase, String? name) async {
    var store = await KeyStore.newRandom();
    var keyStore = await saveKeyStore(store, passphrase, name: name);
    return keyStore;
  }

  Future<File> createFromMnemonic(
      String mnemonic, String passphrase, String? name) async {
    var store = KeyStore.fromMnemonic(mnemonic);
    var keyStore = await saveKeyStore(store, passphrase, name: name);
    return keyStore;
  }
}
