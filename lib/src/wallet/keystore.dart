import 'dart:io';

import 'package:bip39/bip39.dart' as bip39;
import 'package:cryptography/cryptography.dart' as cryptography;
import 'package:hex/hex.dart';
import 'package:path/path.dart' as path;
import 'package:znn_sdk_dart/src/crypto/crypto.dart';
import 'package:znn_sdk_dart/src/model/primitives.dart';
import 'package:znn_sdk_dart/src/wallet/derivation.dart';
import 'package:znn_sdk_dart/src/wallet/keypair.dart';
import 'package:znn_sdk_dart/src/wallet/exceptions.dart';
import 'package:znn_sdk_dart/src/wallet/interfaces.dart';

class KeyStoreDefinition implements WalletDefinition {
  final File file;

  KeyStoreDefinition({required this.file}) {
    if (!file.existsSync()) {
      throw WalletException('Given keyStore does not exist ($file)');
    }
  }

  String get walletId {
    return file.path;
  }

  String get walletName {
    return path.basename(file.path);
  }
}

class KeyStore implements Wallet {
  String? mnemonic;
  late String entropy;
  String? seed;

  KeyStore.fromMnemonic(String mnemonic) {
    setMnemonic(mnemonic);
  }

  KeyStore.fromSeed(String seed) {
    setSeed(seed);
  }

  KeyStore.fromEntropy(String seed) {
    setEntropy(seed);
  }

  static Future<KeyStore> newRandom() async {
    var entropy = await cryptography.SecretKeyData.random(length: 32).extract();
    return KeyStore.fromEntropy(HEX.encode(entropy.bytes));
  }

  void setMnemonic(String mnemonic) {
    if (!bip39.validateMnemonic(mnemonic)) {
      throw ArgumentError.value(mnemonic, 'mnemonic');
    }

    this.mnemonic = mnemonic;
    entropy = bip39.mnemonicToEntropy(this.mnemonic);
    seed = bip39.mnemonicToSeedHex(this.mnemonic!);
  }

  void setSeed(String seed) {
    this.seed = seed;
  }

  void setEntropy(String entropy) {
    setMnemonic(bip39.entropyToMnemonic(entropy));
  }

  Future<WalletAccount> getAccount([int index = 0]) async {
    return getKeyPair(index);
  }

  KeyPair getKeyPair([int index = 0]) {
    return KeyPair(
        Crypto.deriveKey(Derivation.getDerivationAccount(index), seed!));
  }

  Future<List<Address?>> deriveAddressesByRange(int left, int right) async {
    var addresses = <Address?>[];
    if (seed != null) {
      for (var i = left; i < right; i++) {
        addresses.add(await getKeyPair(i).address);
      }
    }
    return addresses;
  }

  Future<FindResponse?> findAddress(Address address, int numOfAddresses) async {
    for (var i = 0; i < numOfAddresses; i++) {
      var pair = getKeyPair(i);
      if ((await pair.address).equals(address)) {
        return FindResponse(path: null, index: i, keyPair: pair);
      }
    }
    return null;
  }
}

class FindResponse {
  File? path;
  int? index;
  KeyPair? keyPair;

  FindResponse({this.path, this.index, this.keyPair});

  FindResponse.fromJson(Map<String, dynamic> json) {
    path = File(json['keyStore']);
    index = json['index'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['keyStore'] = path!.path;
    data['index'] = index;
    return data;
  }
}
