import 'dart:convert';
import 'package:test/test.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

void main() async {
  var keyStoreString = '''
  {
    "crypto": {
        "argon2Params": {
          "salt": "0x5b85100f186953332faddeaf2b6d68de"
        },
        "cipherData": "0xcfe2e1aa498229aaf78ab9634592a19c1f45ad5178ed4d530fdeef8fe528e4b78955a389e0d1e832fd0c21346b3a45cd",
        "cipherName": "aes-256-gcm",
        "kdf": "argon2.IDKey",
        "nonce": "0x86d6b27ba67a72238af12958"
      },
    "timestamp": 1707418422,
    "version": 1
  }
  ''';
  var keyStoreStringWithMeta = '''
  {
    "baseAddress": "z1qqjnwjjpnue8xmmpanz6csze6tcmtzzdtfsww7",
    "walletType": "keystore",
    "crypto": {
        "argon2Params": {
          "salt": "0x5b85100f186953332faddeaf2b6d68de"
        },
        "cipherData": "0xcfe2e1aa498229aaf78ab9634592a19c1f45ad5178ed4d530fdeef8fe528e4b78955a389e0d1e832fd0c21346b3a45cd",
        "cipherName": "aes-256-gcm",
        "kdf": "argon2.IDKey",
        "nonce": "0x86d6b27ba67a72238af12958"
      },
    "timestamp": 1707418422,
    "version": 1
  }
  ''';
  var encryptedFile = EncryptedFile.fromJson(jsonDecode(keyStoreString));
  test('same json', () {
    expect(encryptedFile.toJson(), jsonDecode(keyStoreString));
  });
  test('same metadata', () {
    expect(encryptedFile.metadata, null);
  });

  var encryptedFileWithMeta =
      EncryptedFile.fromJson(jsonDecode(keyStoreStringWithMeta));
  test('same json', () {
    expect(encryptedFileWithMeta.toJson(), jsonDecode(keyStoreStringWithMeta));
  });
  test('same metadata', () {
    expect(encryptedFileWithMeta.metadata, {
      "baseAddress": "z1qqjnwjjpnue8xmmpanz6csze6tcmtzzdtfsww7",
      "walletType": "keystore",
    });
  });
}
