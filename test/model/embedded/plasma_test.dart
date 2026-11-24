import 'dart:convert';

import 'package:test/test.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

void main() {
  group('PlasmaInfo', () {
    test('round-trips JSON with large BigInt qsrAmount', () {
      final sampleJson = <String, dynamic>{
        'currentPlasma': 21000,
        'maxPlasma': 42000,
        'qsrAmount': '123456789012345678901234567890',
      };

      final plasmaInfo = PlasmaInfo.fromJson(sampleJson);
      final encoded = plasmaInfo.toJson();

      expect(encoded, equals(sampleJson));

      final roundTripped = PlasmaInfo.fromJson(
        jsonDecode(jsonEncode(encoded)) as Map<String, dynamic>,
      );
      expect(roundTripped.currentPlasma, equals(21000));
      expect(roundTripped.maxPlasma, equals(42000));
      expect(
        roundTripped.qsrAmount,
        equals(BigInt.parse('123456789012345678901234567890')),
      );
    });

    test('round-trips zero values', () {
      final plasmaInfo = PlasmaInfo(
        currentPlasma: 0,
        maxPlasma: 0,
        qsrAmount: BigInt.zero,
      );

      expect(
        plasmaInfo.toJson(),
        equals({'currentPlasma': 0, 'maxPlasma': 0, 'qsrAmount': '0'}),
      );
    });
  });

  group('FusionEntry', () {
    test('retains isRevocable field for backwards compatibility', () {
      final entry = FusionEntry(
        beneficiary: emptyAddress,
        expirationHeight: 100,
        id: emptyHash,
        qsrAmount: BigInt.from(1000000000),
      );

      expect(entry.isRevocable, isNull);
      entry.isRevocable = true;
      expect(entry.isRevocable, isTrue);
    });
  });
}
