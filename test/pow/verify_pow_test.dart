import 'package:hex/hex.dart';
import 'package:test/test.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

void main() {
  group('verifyPoW', () {
    test('difficulty zero accepts any eight-byte nonce', () {
      expect(verifyPoW(emptyHash, 0, '0000000000000000'), isTrue);
      expect(verifyPoW(emptyHash, 0, 'ffffffffffffffff'), isTrue);
    });

    test('rejects invalid nonce length and negative difficulty', () {
      expect(() => verifyPoW(emptyHash, 1, '00'), throwsArgumentError);
      expect(
        () => verifyPoW(emptyHash, -1, '0000000000000000'),
        throwsArgumentError,
      );
    });

    test('matches direct sha3 proof checks without native libpow', () {
      const difficulty = 2;
      String? passing;
      String? failing;
      for (var value = 0; passing == null || failing == null; value++) {
        var nonce = List<int>.generate(8, (i) => (value >> (8 * i)) & 0xff);
        var digest = Crypto.digest([...nonce, ...emptyHash.getBytes()!]);
        // At difficulty 2 the threshold is 2^63, so the high bit of the
        // little-endian 64-bit prefix determines acceptance.
        if ((digest[7] & 0x80) != 0) {
          passing ??= HEX.encode(nonce);
        } else {
          failing ??= HEX.encode(nonce);
        }
      }
      expect(verifyPoW(emptyHash, difficulty, passing), isTrue);
      expect(verifyPoW(emptyHash, difficulty, failing), isFalse);
    });
  });
}
