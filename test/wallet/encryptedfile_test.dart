import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

void main() {
  group('EncryptedFile', () {
    late EncryptedFile encrypted;
    late Map<String, dynamic> json;
    const password = 'correct horse battery staple';
    final data = List<int>.generate(32, (i) => i);

    setUpAll(() async {
      encrypted = await EncryptedFile.encrypt(data, password);
      json = jsonDecode(jsonEncode(encrypted.toJson()));
    });

    test('round-trips and stores complete KDF parameters', () async {
      expect(await encrypted.decrypt(password), data);
      var params = json['crypto']['argon2Params'] as Map<String, dynamic>;
      expect(
        params.keys,
        containsAll([
          'salt',
          'timeCost',
          'memoryCost',
          'hashLength',
          'parallelism',
        ]),
      );
      expect(encrypted.needsUpgrade, isFalse);
    });

    test('legacy salt-only files use historical defaults', () async {
      var legacy = jsonDecode(jsonEncode(json)) as Map<String, dynamic>;
      var params = legacy['crypto']['argon2Params'] as Map<String, dynamic>;
      params.remove('timeCost');
      params.remove('memoryCost');
      params.remove('hashLength');
      params.remove('parallelism');
      var file = EncryptedFile.fromJson(legacy);
      expect(file.needsUpgrade, isTrue);
      expect(await file.decrypt(password), data);
    });

    test('wrong password throws IncorrectPasswordException', () async {
      expect(
        encrypted.decrypt('wrong password'),
        throwsA(isA<IncorrectPasswordException>()),
      );
    });

    test('rejects invalid or unsupported key-file settings', () async {
      Future<void> expectInvalid(
        void Function(Map<String, dynamic>) mutate, [
        Matcher matcher = const TypeMatcher<WalletException>(),
      ]) async {
        var changed = jsonDecode(jsonEncode(json)) as Map<String, dynamic>;
        mutate(changed);
        await expectLater(
          EncryptedFile.fromJson(changed).decrypt(password),
          throwsA(matcher),
        );
      }

      await expectInvalid((j) => j['crypto']['argon2Params']['memoryCost'] = 1);
      await expectInvalid(
        (j) => j['crypto']['argon2Params']['parallelism'] = 0,
      );
      await expectInvalid(
        (j) => j['crypto']['argon2Params']['hashLength'] = 16,
      );
      await expectInvalid((j) => j['crypto']['kdf'] = 'scrypt');
      await expectInvalid((j) => j['crypto']['cipherName'] = 'aes-128-gcm');
      await expectInvalid((j) => j['version'] = 2);
      await expectInvalid((j) => j['crypto']['argon2Params']['salt'] = '0x');
    });
  });

  test('KeyStoreManager rejects mismatched baseAddress metadata', () async {
    var directory = await Directory.systemTemp.createTemp('znn-keystore-test-');
    addTearDown(() => directory.delete(recursive: true));
    var store = KeyStore.fromMnemonic(
      'route become dream access impulse price inform obtain engage ski believe awful '
      'absent pig thing vibrant possible exotic flee pepper marble rural fire fancy',
    );
    var manager = KeyStoreManager(walletPath: directory);
    var definition = await manager.saveKeyStore(store, 'password', name: 'key');
    var contents =
        jsonDecode(await definition.file.readAsString())
            as Map<String, dynamic>;
    contents['baseAddress'] = 'z1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqsggv2f';
    await definition.file.writeAsString(jsonEncode(contents));

    expect(
      manager.readKeyStore('password', definition.file),
      throwsA(isA<WalletException>()),
    );
  });
}
