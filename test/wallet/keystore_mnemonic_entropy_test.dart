import 'package:test/test.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

void main() {
  group('KeyStore mnemonic/entropy migration (bip39_mnemonic)', () {
    const validMnemonic =
        'route become dream access impulse price inform obtain engage ski believe awful '
        'absent pig thing vibrant possible exotic flee pepper marble rural fire fancy';

    test('fromMnemonic derives entropy + seed', () {
      final ks = KeyStore.fromMnemonic(validMnemonic);

      expect(ks.mnemonic, isNotNull);
      expect(ks.entropy, isNotNull);
      expect(ks.seed, isNotNull);

      expect(ks.mnemonic, equals(validMnemonic));
      expect(ks.entropy, matches(RegExp(r'^[0-9a-f]+$')));
      expect(ks.seed, matches(RegExp(r'^[0-9a-f]+$')));
      expect(ks.seed!.length, 128); // 64 bytes seed => 128 hex chars
    });

    test(
      'setMnemonic accepts a valid sentence and derives consistent values',
      () {
        final ks = KeyStore.fromMnemonic(validMnemonic);
        final originalEntropy = ks.entropy;
        final originalSeed = ks.seed;

        // Same mnemonic, already normalized
        ks.setMnemonic(validMnemonic);

        expect(ks.mnemonic, equals(validMnemonic));
        expect(ks.entropy, equals(originalEntropy));
        expect(ks.seed, equals(originalSeed));
      },
    );

    test(
      'setMnemonic rejects non-normalized input (uppercase / extra whitespace)',
      () {
        final ks = KeyStore.fromMnemonic(validMnemonic);

        final messy =
            '  ROUTE   become  DREAM access   impulse price inform obtain '
            'engage ski believe awful absent pig thing vibrant possible exotic '
            'flee pepper marble rural fire fancy  ';

        expect(
          () => ks.setMnemonic(messy),
          throwsA(
            isA<ArgumentError>().having((e) => e.name, 'name', 'mnemonic'),
          ),
        );
      },
    );

    test('setMnemonic throws ArgumentError on invalid mnemonic', () {
      final ks = KeyStore.fromMnemonic(validMnemonic);

      expect(
        () => ks.setMnemonic('this is not a valid bip39 mnemonic'),
        throwsA(isA<ArgumentError>().having((e) => e.name, 'name', 'mnemonic')),
      );
    });

    test('setEntropy derives mnemonic/seed, stores entropy lowercase', () {
      final ks = KeyStore.fromMnemonic(validMnemonic);
      final entropyHex = ks.entropy;
      final entropyUpper = entropyHex.toUpperCase();

      ks.setEntropy(entropyUpper);

      expect(ks.entropy, equals(entropyHex));
      expect(ks.mnemonic, equals(validMnemonic));
      expect(ks.seed, matches(RegExp(r'^[0-9a-f]+$')));
      expect(ks.seed!.length, 128);
    });

    test(
      'setEntropy throws ArgumentError on invalid hex / invalid entropy length',
      () {
        final ks = KeyStore.fromMnemonic(validMnemonic);

        expect(
          () => ks.setEntropy('zzzz'),
          throwsA(
            isA<ArgumentError>().having((e) => e.name, 'name', 'entropy'),
          ),
        );

        expect(
          () => ks.setEntropy('00'), // 8 bits, invalid size
          throwsA(
            isA<ArgumentError>().having((e) => e.name, 'name', 'entropy'),
          ),
        );
      },
    );
  });
}
