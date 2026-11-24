import 'dart:convert';
import 'dart:typed_data';

import 'package:argon2_ffi_base/argon2_ffi_base.dart';
import 'package:cryptography/cryptography.dart';
import 'package:cryptography/cryptography.dart' as cryptography;
import 'package:hex/hex.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

/// Default Argon2id KDF parameters for key files that do not carry their own
/// (legacy files store only the salt).
const int argon2DefaultTimeCost = 1;
const int argon2DefaultMemoryCostKiB = 64 * 1024;
const int argon2DefaultHashLength = 32;
const int argon2DefaultParallelism = 4;

const String _keyFileKdf = 'argon2.IDKey';
const String _keyFileCipher = 'aes-256-gcm';
const int _keyFileVersion = 1;

class EncryptedFile {
  Map<String, dynamic>? metadata;
  _Crypto? crypto;
  int? timestamp;
  int? version;

  EncryptedFile({this.metadata, this.crypto, this.timestamp, this.version});

  static Future<EncryptedFile> encrypt(List<int> data, String password,
      {Map<String, dynamic>? metadata}) async {
    var timestamp = ((DateTime.now()).millisecondsSinceEpoch / 1000).round();
    var stored = EncryptedFile(
        metadata: metadata,
        timestamp: timestamp,
        version: _keyFileVersion,
        crypto: _Crypto(
            argon2Params: _Argon2Params(
                salt: Uint8List(0),
                timeCost: argon2DefaultTimeCost,
                memoryCost: argon2DefaultMemoryCostKiB,
                hashLength: argon2DefaultHashLength,
                parallelism: argon2DefaultParallelism),
            cipherData: Uint8List(0),
            cipherName: _keyFileCipher,
            kdf: _keyFileKdf,
            nonce: Uint8List(0)));
    return stored._encryptData(data, password);
  }

  /// Whether this key file predates self-describing KDF parameters and should
  /// be re-encrypted so it stores its full Argon2 configuration.
  bool get needsUpgrade {
    var params = crypto?.argon2Params;
    if (params == null) return true;
    return params.timeCost == null ||
        params.memoryCost == null ||
        params.hashLength == null ||
        params.parallelism == null;
  }

  void _validate() {
    if (version != _keyFileVersion) {
      throw WalletException('Unsupported key file version ($version)');
    }
    if (crypto == null || crypto!.argon2Params?.salt == null) {
      throw WalletException('Malformed key file: missing KDF parameters');
    }
    if (crypto!.kdf != _keyFileKdf) {
      throw WalletException('Unsupported key file KDF (${crypto!.kdf})');
    }
    if (crypto!.cipherName != _keyFileCipher) {
      throw WalletException(
          'Unsupported key file cipher (${crypto!.cipherName})');
    }
    if (crypto!.cipherData == null || crypto!.nonce == null) {
      throw WalletException('Malformed key file: missing cipher data');
    }
    var params = crypto!.argon2Params!;
    if (params.salt!.isEmpty) {
      throw WalletException('Malformed key file: empty KDF salt');
    }
    var hashLength = params.hashLength ?? argon2DefaultHashLength;
    if (hashLength != argon2DefaultHashLength) {
      throw WalletException(
          'Unsupported key file KDF hash length ($hashLength); '
          'aes-256-gcm requires a 32-byte key');
    }
    var timeCost = params.timeCost ?? argon2DefaultTimeCost;
    if (timeCost < 1 || timeCost > 0xffffff) {
      throw WalletException('Invalid key file KDF time cost ($timeCost)');
    }
    var parallelism = params.parallelism ?? argon2DefaultParallelism;
    if (parallelism < 1 || parallelism > 255) {
      throw WalletException(
          'Invalid key file KDF parallelism ($parallelism)');
    }
    // Bound memory to [8 KiB per lane, 4 GiB] so a malformed or hostile key
    // file cannot request pathological KDF resources.
    var memoryCost = params.memoryCost ?? argon2DefaultMemoryCostKiB;
    if (memoryCost < 8 * parallelism || memoryCost > 4 * 1024 * 1024) {
      throw WalletException(
          'Invalid key file KDF memory cost ($memoryCost KiB)');
    }
  }

  Future<List<int>> decrypt(String password) async {
    _validate();
    var params = crypto!.argon2Params!;
    try {
      var key = initArgon2().argon2(Argon2Arguments(
          Uint8List.fromList(utf8.encode(password)),
          params.salt!,
          params.memoryCost ?? argon2DefaultMemoryCostKiB,
          params.timeCost ?? argon2DefaultTimeCost,
          params.hashLength ?? argon2DefaultHashLength,
          params.parallelism ?? argon2DefaultParallelism,
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
    final data = {...json};
    crypto =
        json['crypto'] != null ? _Crypto.fromJson(data.remove('crypto')) : null;
    timestamp = data.remove('timestamp');
    version = data.remove('version');
    metadata = data.isNotEmpty ? {...data} : null;
  }

  Map<String, dynamic> toJson() {
    final data = metadata != null ? {...metadata!} : <String, dynamic>{};
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
    var params = crypto!.argon2Params!;
    var key = initArgon2().argon2(Argon2Arguments(
        Uint8List.fromList(utf8.encode(password)),
        salt,
        params.memoryCost ?? argon2DefaultMemoryCostKiB,
        params.timeCost ?? argon2DefaultTimeCost,
        params.hashLength ?? argon2DefaultHashLength,
        params.parallelism ?? argon2DefaultParallelism,
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
  int? timeCost;
  int? memoryCost;
  int? hashLength;
  int? parallelism;

  _Argon2Params(
      {this.salt,
      this.timeCost,
      this.memoryCost,
      this.hashLength,
      this.parallelism});

  _Argon2Params.fromJson(Map<String, dynamic> json) {
    salt = _fromHexString(json['salt']);
    timeCost = json['timeCost'];
    memoryCost = json['memoryCost'];
    hashLength = json['hashLength'];
    parallelism = json['parallelism'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['salt'] = _toHexString(salt!);
    if (timeCost != null) data['timeCost'] = timeCost;
    if (memoryCost != null) data['memoryCost'] = memoryCost;
    if (hashLength != null) data['hashLength'] = hashLength;
    if (parallelism != null) data['parallelism'] = parallelism;
    return data;
  }
}
