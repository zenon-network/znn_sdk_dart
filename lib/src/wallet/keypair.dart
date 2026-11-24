import 'dart:async';

import 'package:znn_sdk_dart/src/crypto/crypto.dart';
import 'package:znn_sdk_dart/src/model/primitives.dart';
import 'package:znn_sdk_dart/src/wallet/interfaces.dart';
import 'package:znn_sdk_dart/src/model/nom/account_block_template.dart';

class KeyPair implements WalletAccount {
  List<int>? privateKey;
  List<int>? publicKey;
  Address? _address;

  KeyPair(List<int>? privateKey, [List<int>? publicKey, Address? address]) {
    this.privateKey = privateKey;
    this.publicKey = publicKey;
    _address = address;
  }

  List<int>? getPrivateKey() {
    return privateKey;
  }

  Future<List<int>> getPublicKey() async {
    publicKey ??= await Crypto.getPublicKey(privateKey);
    return publicKey!;
  }

  Future<Address?> get address async {
    return await getAddress();
  }

  Future<Address> getAddress() async {
    if (_address == null) {
      publicKey = await getPublicKey();
      _address = Address.fromPublicKey(publicKey!);
    }
    return _address!;
  }

  Future<List<int>> sign(List<int> message) async {
    return Crypto.sign(message, privateKey, (await getPublicKey()));
  }

  Future<List<int>> signTx(AccountBlockTemplate tx) async {
    return Crypto.sign(tx.hash.getBytes()!, privateKey, (await getPublicKey()));
  }

  Future<bool> verify(List<int> signature, List<int> message) async {
    return Crypto.verify(signature, message, (await getPublicKey()));
  }

  Future<List<int>> generatePublicKey(List<int> privateKey) async {
    return await Crypto.getPublicKey(privateKey);
  }

  /// Zeroes and drops the key material held by this pair.
  ///
  /// The pair is unusable afterwards; signing or address derivation will fail.
  void clear() {
    privateKey?.fillRange(0, privateKey!.length, 0);
    privateKey = null;
    publicKey?.fillRange(0, publicKey!.length, 0);
    publicKey = null;
    _address = null;
  }
}
