import 'dart:convert';

import 'package:test/test.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

void main() {
  const ownerAddr = 'z1qzal6c5s9rjnnxd2z7dvdhjxpmmj4fmw56a0mz';
  const producerAddr = 'z1qr4pexnnfaexqqz8nscjjcsajy5hdqfkgadvwx';
  const withdrawAddr = 'z1qz8v73ea2vy2rrlq7skssngu8cm8mknjjkr2ju';

  Map<String, dynamic> buildPillarJson() => {
    'name': 'PillarAlpha',
    'rank': 3,
    'type': PillarInfo.regularPillarType,
    'ownerAddress': ownerAddr,
    'producerAddress': producerAddr,
    'withdrawAddress': withdrawAddr,
    'giveMomentumRewardPercentage': 15,
    'giveDelegateRewardPercentage': 85,
    'isRevocable': true,
    'revokeCooldown': 120,
    'revokeTimestamp': 1700000000,
    'currentStats': {'producedMomentums': 250, 'expectedMomentums': 255},
    'weight': '150000000000000000000',
  };

  group('PillarEpochStats', () {
    test('round-trips JSON and supports Equatable equality', () {
      final a = PillarEpochStats.fromJson({
        'producedMomentums': 100,
        'expectedMomentums': 105,
      });
      final b = PillarEpochStats.fromJson(a.toJson());

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(
        a,
        isNot(
          equals(
            PillarEpochStats.fromJson({
              'producedMomentums': 99,
              'expectedMomentums': 105,
            }),
          ),
        ),
      );
      expect(
        a,
        isNot(
          equals(
            PillarEpochStats.fromJson({
              'producedMomentums': 100,
              'expectedMomentums': 106,
            }),
          ),
        ),
      );
    });
  });

  group('PillarInfo', () {
    test(
      'toJson includes type and reward percentages and round-trips cleanly',
      () {
        final sourceJson = buildPillarJson();
        final pillar = PillarInfo.fromJson(sourceJson);
        final encoded = pillar.toJson();

        expect(encoded, equals(sourceJson));
        expect(encoded['type'], equals(PillarInfo.regularPillarType));
        expect(encoded['giveMomentumRewardPercentage'], equals(15));
        expect(encoded['giveDelegateRewardPercentage'], equals(85));

        final roundTripped = PillarInfo.fromJson(
          jsonDecode(jsonEncode(encoded)) as Map<String, dynamic>,
        );
        expect(roundTripped, equals(pillar));
        expect(roundTripped.hashCode, equals(pillar.hashCode));
      },
    );

    test('defaults type to unknownType when absent from JSON', () {
      final jsonWithoutType = buildPillarJson()..remove('type');
      final pillar = PillarInfo.fromJson(jsonWithoutType);

      expect(pillar.type, equals(PillarInfo.unknownType));
      expect(pillar.toJson()['type'], equals(PillarInfo.unknownType));
    });

    test('Equatable inequality detects changes in every field', () {
      final base = PillarInfo.fromJson(buildPillarJson());
      final equalCopy = PillarInfo.fromJson(buildPillarJson());

      expect(base, equals(equalCopy));
      expect(base.hashCode, equals(equalCopy.hashCode));

      final mutations = <String, void Function(Map<String, dynamic>)>{
        'name': (j) => j['name'] = 'PillarBeta',
        'rank': (j) => j['rank'] = 4,
        'type': (j) => j['type'] = PillarInfo.legacyPillarType,
        'ownerAddress': (j) => j['ownerAddress'] = withdrawAddr,
        'producerAddress': (j) => j['producerAddress'] = ownerAddr,
        'withdrawAddress': (j) => j['withdrawAddress'] = producerAddr,
        'giveMomentumRewardPercentage':
            (j) => j['giveMomentumRewardPercentage'] = 20,
        'giveDelegateRewardPercentage':
            (j) => j['giveDelegateRewardPercentage'] = 80,
        'isRevocable': (j) => j['isRevocable'] = false,
        'revokeCooldown': (j) => j['revokeCooldown'] = 0,
        'revokeTimestamp': (j) => j['revokeTimestamp'] = 1700000001,
        'currentStats.producedMomentums':
            (j) =>
                (j['currentStats']
                        as Map<String, dynamic>)['producedMomentums'] =
                    249,
        'currentStats.expectedMomentums':
            (j) =>
                (j['currentStats']
                        as Map<String, dynamic>)['expectedMomentums'] =
                    256,
        'weight': (j) => j['weight'] = '150000000000000000001',
      };

      for (final entry in mutations.entries) {
        final mutatedJson = buildPillarJson();
        entry.value(mutatedJson);
        expect(
          PillarInfo.fromJson(mutatedJson),
          isNot(equals(base)),
          reason: 'Expected inequality when ${entry.key} differs',
        );
      }

      final mutatedProduced = PillarInfo.fromJson(buildPillarJson())
        ..producedMomentums = 999;
      expect(mutatedProduced, isNot(equals(base)));

      final mutatedExpected = PillarInfo.fromJson(buildPillarJson())
        ..expectedMomentums = 999;
      expect(mutatedExpected, isNot(equals(base)));
    });
  });
}
