import 'package:test/test.dart';
import 'package:znn_sdk_dart/src/abi/abi_types.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

void main() {
  group('ABI conformance', () {
    test('signed integers round-trip at boundaries', () {
      for (var value in [BigInt.from(-128), BigInt.zero, BigInt.from(127)]) {
        var type = AbiType.getType('int8');
        expect(type.decode(type.encode(value)), value);
      }

      var type = AbiType.getType('int256');
      var bound = BigInt.one << 255;
      expect(type.decode(type.encode(-bound)), -bound);
      expect(type.decode(type.encode(bound - BigInt.one)), bound - BigInt.one);
    });

    test('integer encode and decode enforce declared widths', () {
      var int8 = AbiType.getType('int8');
      var uint8 = AbiType.getType('uint8');
      expect(() => int8.encode(-129), throwsA(isA<ZnnSdkException>()));
      expect(() => int8.encode(128), throwsA(isA<ZnnSdkException>()));
      expect(() => uint8.encode(-1), throwsA(isA<ZnnSdkException>()));
      expect(() => uint8.encode(256), throwsA(isA<ZnnSdkException>()));
      expect(
        () => int8.decode(IntType.encodeInt(128)),
        throwsA(isA<ZnnSdkException>()),
      );
      expect(
        () => int8.decode(IntType.encodeInt(-129)),
        throwsA(isA<ZnnSdkException>()),
      );
      expect(
        () => uint8.decode(UnsignedIntType.encodeInt(256)),
        throwsA(isA<ZnnSdkException>()),
      );
    });

    test('fixed bytes require exact length and canonical padding', () {
      var type = AbiType.getType('bytes3');
      for (var value in [
        '010203',
        '0x010203',
        <int>[1, 2, 3],
      ]) {
        expect(type.decode(type.encode(value)), [1, 2, 3]);
      }
      expect(() => type.encode('0102'), throwsA(isA<ZnnSdkException>()));
      expect(() => type.encode([1, 2, 3, 4]), throwsA(isA<ZnnSdkException>()));
      var invalid = List<int>.filled(32, 0)..[3] = 1;
      expect(() => type.decode(invalid), throwsA(isA<ZnnSdkException>()));
    });

    test('bool accepts only Dart bool and canonical words', () {
      var type = AbiType.getType('bool');
      expect(type.decode(type.encode(false)), isFalse);
      expect(type.decode(type.encode(true)), isTrue);
      expect(() => type.encode('true'), throwsA(isA<ZnnSdkException>()));
      expect(
        () => type.decode(IntType.encodeInt(2)),
        throwsA(isA<ZnnSdkException>()),
      );
    });

    test('function argument counts are exact', () {
      var abi = Abi.fromJson(
        '[{"type":"function","name":"f","inputs":[{"name":"x","type":"uint8"}]}]',
      );
      expect(
        () => abi.encodeFunction('f', []),
        throwsA(isA<ZnnSdkException>()),
      );
      expect(
        () => abi.encodeFunction('f', [1, 2]),
        throwsA(isA<ZnnSdkException>()),
      );
    });

    test('fixed arrays of dynamic elements are dynamic and round-trip', () {
      var type = AbiType.getType('string[2]');
      expect(type.isDynamicType(), isTrue);
      var abi = Abi.fromJson(
        '[{"type":"function","name":"f","inputs":[{"name":"values","type":"string[2]"}]}]',
      );
      var encoded = abi.encodeFunction('f', [
        ['alpha', 'beta'],
      ]);
      expect(abi.decodeFunction(encoded), [
        ['alpha', 'beta'],
      ]);
    });

    test('decodeCallData returns the function name and arguments', () {
      var abi = Abi.fromJson('''[
        {"type":"function","name":"first","inputs":[{"name":"x","type":"uint8"}]},
        {"type":"function","name":"second","inputs":[{"name":"value","type":"string"}]}
      ]''');
      var decoded = abi.decodeCallData(abi.encodeFunction('second', ['hello']));
      expect(decoded.name, 'second');
      expect(decoded.args, ['hello']);
      expect(
        () => abi.decodeCallData([0, 0, 0, 0]),
        throwsA(isA<ZnnSdkException>()),
      );
    });
  });
}
