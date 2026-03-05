import 'package:test/test.dart';
import 'package:znn_sdk_dart/src/wallet/mnemonic.dart';

void main() {
  group('Mnemonic (English-only)', () {
    test(
      'generateMnemonic returns a valid mnemonic for supported strengths',
      () {
        for (final strength in [128, 160, 192, 224, 256]) {
          final sentence = Mnemonic.generateMnemonic(strength);
          final words =
              sentence
                  .split(RegExp(r'\s+'))
                  .where((w) => w.isNotEmpty)
                  .toList();

          expect(Mnemonic.validateMnemonic(words), isTrue);

          for (final w in words) {
            expect(
              Mnemonic.isValidWord(w),
              isTrue,
              reason: 'Not in EN wordlist: $w',
            );
          }
        }
      },
    );

    test(
      'validateMnemonic returns false for invalid checksum / invalid word',
      () {
        expect(Mnemonic.validateMnemonic(['notaword', 'alsofake']), isFalse);

        final sentence = Mnemonic.generateMnemonic(128);
        final words = sentence.split(' ').toList();
        words[0] = 'notaword';
        
        expect(Mnemonic.validateMnemonic(words), isFalse);
      },
    );

    test('isValidWord works (positive + negative)', () {
      expect(Mnemonic.isValidWord('abandon'), isTrue);
      expect(Mnemonic.isValidWord('abandon!'), isFalse);
      expect(Mnemonic.isValidWord(''), isFalse);
    });
  });
}
