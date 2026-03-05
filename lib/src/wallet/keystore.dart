import 'dart:io';
import 'dart:typed_data';

import 'package:bip39_mnemonic/bip39_mnemonic.dart' as bip39;
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

  /// Sets and validates a BIP-39 mnemonic using the English wordlist.
  ///
  /// This function uses the `bip39_mnemonic` package and replaces the legacy
  /// `bip39` API (`validateMnemonic`, `mnemonicToEntropy`, `mnemonicToSeedHex`).
  ///
  /// Behavior:
  /// - Uses the English BIP-39 wordlist only.
  /// - Validates words and checksum.
  /// - Normalizes the mnemonic sentence.
  /// - Derives entropy and seed as hexadecimal strings.
  ///
  /// Throws:
  /// - [ArgumentError] if the mnemonic is invalid.
  void setMnemonic(String sentence) {
    try {
      final m = bip39.Mnemonic.fromSentence(sentence, bip39.Language.english);

      mnemonic = m.sentence; // normalized
      entropy = HEX.encode(m.entropy); // hex string
      seed = HEX.encode(m.seed); // hex string
    } catch (_) {
      throw ArgumentError.value(sentence, 'mnemonic');
    }
  }

  void setSeed(String seed) {
    this.seed = seed;
  }

  /// Sets the mnemonic derived from the given BIP-39 entropy (hex).
  ///
  /// Entropy must be a valid hex string representing
  /// 128–256 bits (multiple of 32).
  ///
  /// Throws:
  /// - [ArgumentError] if the entropy is invalid.
  void setEntropy(String entropyHex) {
    try {
      final entropyBytes = Uint8List.fromList(HEX.decode(entropyHex));

      final m = bip39.Mnemonic(entropyBytes, bip39.Language.english);

      mnemonic = m.sentence;
      entropy = entropyHex.toLowerCase();
      seed = HEX.encode(m.seed);
    } catch (_) {
      throw ArgumentError.value(entropyHex, 'entropy');
    }
  }

  Future<WalletAccount> getAccount([int index = 0]) async {
    return getKeyPair(index);
  }

  KeyPair getKeyPair([int index = 0]) {
    return KeyPair(
      Crypto.deriveKey(Derivation.getDerivationAccount(index), seed!),
    );
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
      if ((await pair.address)!.equals(address)) {
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
