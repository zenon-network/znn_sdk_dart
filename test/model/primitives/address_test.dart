import 'dart:convert';

import 'package:test/test.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

void main() {
  group('Address JSON serialization', () {
    test('round-trips user, empty, and embedded contract addresses', () {
      final addresses = <Address>[
        Address.parse('z1qzal6c5s9rjnnxd2z7dvdhjxpmmj4fmw56a0mz'),
        emptyAddress,
        pillarAddress,
        plasmaAddress,
      ];

      for (final address in addresses) {
        final json = address.toJson();
        expect(json, equals({'address': address.toString()}));

        final decoded = Address.fromJson(
          jsonDecode(jsonEncode(address)) as Map<String, dynamic>,
        );
        expect(decoded, equals(address));
        expect(decoded.hashCode, equals(address.hashCode));
      }
    });

    test('fromJson throws on invalid bech32 address', () {
      expect(
        () => Address.fromJson({'address': 'not-a-valid-address'}),
        throwsA(anything),
      );
    });
  });
}
