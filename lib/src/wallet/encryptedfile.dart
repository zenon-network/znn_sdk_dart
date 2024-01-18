import 'dart:convert';
import 'dart:typed_data';

import 'package:argon2_ffi_base/argon2_ffi_base.dart';
import 'package:cryptography/cryptography.dart';
import 'package:cryptography/cryptography.dart' as cryptography;
import 'package:hex/hex.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class EncryptedFile {
  _Crypto? crypto;
  int? timestamp;
  int? version;

  EncryptedFile({this.crypto, this.timestamp, this.version});

  static Future<EncryptedFile> encrypt(List<int> data, String password) async {
    var timestamp = ((DateTime.now()).millisecondsSinceEpoch / 1000).round();
    var stored = EncryptedFile(
        timestamp: timestamp,
        version: 1,
        crypto: _Crypto(
            argon2Params: _Argon2Params(salt: Uint8List(0)),
            cipherData: Uint8List(0),
            cipherName: 'aes-256-gcm',
            kdf: 'argon2.IDKey',
            nonce: Uint8List(0)));
    return stored._encryptData(data, password);
  }

  Future<List<int>> decrypt(String password) async {
    try {
      var key = initArgon2().argon2(Argon2Arguments(
          Uint8List.fromList(utf8.encode(password)),
          crypto!.argon2Params!.salt!,
          64 * 1024,
          1,
          32,
          4,
          2,
          13));
      final algorithm = cryptography.AesGcm.with256bits();
      var data = await algorithm.decrypt(
          cryptography.SecretBox(
            crypto!.cipherData!.sublist(0, crypto!.cipherData!.length - 16),
            nonce: crypto!.nonce!,
            mac: cryptography.Mac(crypto!.cipherData!.sublist(
                crypto!.cipherData!.length - 16, crypto!.cipherData!.length)),
          ),
          secretKey: cryptography.SecretKey(key),
          aad: utf8.encode('zenon'));

      return data;
    } on SecretBoxAuthenticationError {
      throw IncorrectPasswordException();
    } catch (e) {
      rethrow;
    }
  }

  EncryptedFile.fromJson(Map<String, dynamic> json) {
    crypto = json['crypto'] != null ? _Crypto.fromJson(json['crypto']) : null;
    timestamp = json['timestamp'];
    version = json['version'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (crypto != null) {
      data['crypto'] = crypto!.toJson();
    }
    data['timestamp'] = timestamp;
    data['version'] = version;
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }

  Future<EncryptedFile> _encryptData(List<int> data, String password) async {
    var salt_1 = await cryptography.SecretKeyData.random(length: 16).extract();
    var salt = Uint8List.fromList(salt_1.bytes);
    var nonce_1 = await cryptography.SecretKeyData.random(length: 12).extract();
    var nonce = Uint8List.fromList(nonce_1.bytes);
    var key = initArgon2().argon2(Argon2Arguments(
        Uint8List.fromList(utf8.encode(password)),
        salt,
        64 * 1024,
        1,
        32,
        4,
        2,
        13));

    final algorithm = cryptography.AesGcm.with256bits();
    var encrypted = await algorithm.encrypt(data,
        secretKey: cryptography.SecretKey(key),
        nonce: nonce,
        aad: utf8.encode('zenon'));
    crypto!.cipherData =
        Uint8List.fromList(encrypted.cipherText + encrypted.mac.bytes);
    crypto!.nonce = nonce;
    crypto!.argon2Params!.salt = salt;
    return this;
  }
}

Uint8List _fromHexString(String s) {
  return Uint8List.fromList(HEX.decode(s.substring(2)));
}

String _toHexString(Uint8List l) {
  return '0x${HEX.encode(l)}';
}

class _Crypto {
  _Argon2Params? argon2Params;
  Uint8List? cipherData;
  String? cipherName;
  String? kdf;
  Uint8List? nonce;

  _Crypto(
      {this.argon2Params,
      this.cipherData,
      this.cipherName,
      this.kdf,
      this.nonce});

  _Crypto.fromJson(Map<String, dynamic> json) {
    argon2Params = json['argon2Params'] != null
        ? _Argon2Params.fromJson(json['argon2Params'])
        : null;
    cipherData = _fromHexString(json['cipherData']);
    cipherName = json['cipherName'];
    kdf = json['kdf'];
    nonce = _fromHexString(json['nonce']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (argon2Params != null) {
      data['argon2Params'] = argon2Params!.toJson();
    }
    data['cipherData'] = _toHexString(cipherData!);
    data['cipherName'] = cipherName;
    data['kdf'] = kdf;
    data['nonce'] = _toHexString(nonce!);
    return data;
  }
}

class _Argon2Params {
  Uint8List? salt;

  _Argon2Params({this.salt});

  _Argon2Params.fromJson(Map<String, dynamic> json) {
    salt = _fromHexString(json['salt']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['salt'] = _toHexString(salt!);
    return data;
  }
}
