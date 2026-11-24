import 'dart:convert';

import 'package:test/test.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

void main() {
  const userAddressA = 'z1qzal6c5s9rjnnxd2z7dvdhjxpmmj4fmw56a0mz';
  const userAddressB = 'z1qr4pexnnfaexqqz8nscjjcsajy5hdqfkgadvwx';

  group('UncollectedReward', () {
    final sampleJson = <String, dynamic>{
      'address': userAddressA,
      'znnAmount': '123456789012345678901234567890',
      'qsrAmount': '987654321098765432109876543210',
    };

    test('round-trips JSON including large BigInt values', () {
      final reward = UncollectedReward.fromJson(sampleJson);
      final encoded = reward.toJson();

      expect(encoded, equals(sampleJson));
      expect(
        UncollectedReward.fromJson(
          jsonDecode(jsonEncode(encoded)) as Map<String, dynamic>,
        ),
        equals(reward),
      );
    });

    test(
      'supports Equatable value equality and hashCode across all fields',
      () {
        final a = UncollectedReward.fromJson(sampleJson);
        final b = UncollectedReward.fromJson(
          Map<String, dynamic>.from(sampleJson),
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));

        expect(
          a,
          isNot(
            equals(
              UncollectedReward.fromJson({
                ...sampleJson,
                'address': userAddressB,
              }),
            ),
          ),
        );
        expect(
          a,
          isNot(
            equals(
              UncollectedReward.fromJson({...sampleJson, 'znnAmount': '0'}),
            ),
          ),
        );
        expect(
          a,
          isNot(
            equals(
              UncollectedReward.fromJson({...sampleJson, 'qsrAmount': '0'}),
            ),
          ),
        );
      },
    );
  });

  group('RewardHistoryEntry', () {
    final sampleJson = <String, dynamic>{
      'epoch': 42,
      'znnAmount': '5000000000',
      'qsrAmount': '25000000000',
    };

    test(
      'round-trips JSON and supports Equatable equality across all fields',
      () {
        final a = RewardHistoryEntry.fromJson(sampleJson);
        final b = RewardHistoryEntry.fromJson(a.toJson());

        expect(a.toJson(), equals(sampleJson));
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));

        expect(
          a,
          isNot(
            equals(RewardHistoryEntry.fromJson({...sampleJson, 'epoch': 43})),
          ),
        );
        expect(
          a,
          isNot(
            equals(
              RewardHistoryEntry.fromJson({...sampleJson, 'znnAmount': '1'}),
            ),
          ),
        );
        expect(
          a,
          isNot(
            equals(
              RewardHistoryEntry.fromJson({...sampleJson, 'qsrAmount': '1'}),
            ),
          ),
        );
      },
    );
  });

  group('RewardHistoryList', () {
    final sampleJson = <String, dynamic>{
      'count': 2,
      'list': [
        {'epoch': 10, 'znnAmount': '100000000', 'qsrAmount': '200000000'},
        {'epoch': 11, 'znnAmount': '300000000', 'qsrAmount': '400000000'},
      ],
    };

    test('round-trips JSON and compares count and nested entries by value', () {
      final a = RewardHistoryList.fromJson(sampleJson);
      final b = RewardHistoryList.fromJson(a.toJson());

      expect(a.toJson(), equals(sampleJson));
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));

      expect(
        a,
        isNot(equals(RewardHistoryList.fromJson({...sampleJson, 'count': 3}))),
      );
      expect(
        a,
        isNot(
          equals(
            RewardHistoryList.fromJson({
              'count': 2,
              'list': [
                {
                  'epoch': 10,
                  'znnAmount': '100000000',
                  'qsrAmount': '200000000',
                },
                {
                  'epoch': 11,
                  'znnAmount': '999999999',
                  'qsrAmount': '400000000',
                },
              ],
            }),
          ),
        ),
      );
    });
  });
}
