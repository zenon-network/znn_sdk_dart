import 'dart:typed_data';

import 'package:cryptography/dart.dart';
import 'package:sha3/sha3.dart';
import 'package:znn_sdk_dart/src/crypto/ed25519.dart' as ed25519;

class Crypto {
  static Future<Uint8List> _ed25519HashFunc(Uint8List? m) async {
    final sink = const DartSha512().newHashSink();
    sink.add(m!);
    sink.close();
    var hash = await sink.hash();
    return Uint8List.fromList(hash.bytes);
  }

  static Future<List<int>> getPublicKey(var privateKey) {
    return ed25519.Ed25519.publickey(
        Crypto._ed25519HashFunc, Uint8List.fromList(privateKey));
  }

  static Future<List<int>> sign(
      List<int> message, List<int>? privateKey, List<int> publicKey) {
    return ed25519.Ed25519.signature(
        Crypto._ed25519HashFunc,
        Uint8List.fromList(message),
        privateKey == null ? null : Uint8List.fromList(privateKey),
        Uint8List.fromList(publicKey));
  }

  static Future<bool> verify(
      List<int> signature, List<int> message, List<int> publicKey) {
    return ed25519.Ed25519.checkvalid(Crypto._ed25519HashFunc,
        signature as Uint8List, message as Uint8List, publicKey as Uint8List);
  }

  static List<int> deriveKey(String path, String seed) {
    return ed25519.Ed25519.derivePath(path, seed).key!;
  }

  static List<int> digest(List<int> data, [int digestSize = 32]) {
    var sha3 = SHA3(256, SHA3_PADDING, digestSize * 8);
    sha3.update(data);
    return sha3.digest();
  }
}
