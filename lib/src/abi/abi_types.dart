import 'dart:convert';

import 'package:hex/hex.dart';
import 'package:znn_sdk_dart/src/global.dart';
import 'package:znn_sdk_dart/src/model/primitives.dart';
import 'package:znn_sdk_dart/src/utils/utils.dart';

class IntType extends NumericType {
  IntType(var name) : super(name);

  @override
  String? getCanonicalName() {
    if (getName() == 'int') return 'int256';
    return super.getCanonicalName();
  }

  static List<int> encodeInt(int i) {
    return encodeIntBig(BigInt.from(i));
  }

  static List<int> encodeIntBig(BigInt bigInt) {
    return BytesUtils.bigIntToBytesSigned(bigInt, AbiType.int32Size);
  }

  /// Decodes a 32-byte word as a signed (two's complement) integer.
  static BigInt decodeInt(List<int> encoded, int offset) {
    var word = encoded.sublist(offset, offset + 32);
    var unsigned = BytesUtils.decodeBigInt(word);
    if ((word[0] & 0x80) != 0) {
      return unsigned - (BigInt.one << 256);
    }
    return unsigned;
  }

  @override
  List<int> encode(var value) {
    var bigInt = encodeInternal(value);
    var bits = bitSize();
    var bound = BigInt.one << (bits - 1);
    if (bigInt < -bound || bigInt >= bound) {
      throw ZnnSdkException(
          'value $bigInt out of range for ${getCanonicalName()}');
    }
    return encodeIntBig(bigInt);
  }

  @override
  dynamic decode(List<int> encoded, [int offset = 0]) {
    var value = decodeInt(encoded, offset);
    var bits = bitSize();
    var bound = BigInt.one << (bits - 1);
    if (value < -bound || value >= bound) {
      throw ZnnSdkException(
          'decoded value $value out of range for ${getCanonicalName()}');
    }
    return value;
  }
}

abstract class ArrayType extends AbiType {
  static ArrayType getType(String typeName) {
    var idx1 = typeName.indexOf('[');
    var idx2 = typeName.indexOf(']', idx1);
    if (idx1 + 1 == idx2) {
      return DynamicArrayType(typeName);
    } else {
      return StaticArrayType(typeName);
    }
  }

  dynamic elementType;

  ArrayType(String name) : super(name) {
    var idx = name.indexOf('[');
    var st = name.substring(0, idx);
    var idx2 = name.indexOf(']', idx);
    var subDim = idx2 + 1 == name.length ? '' : name.substring(idx2 + 1);
    elementType = AbiType.getType(st + subDim);
  }

  AbiType? getElementType() {
    return elementType;
  }

  @override
  List<int> encode(var value) {
    if (value is List) {
      return encodeList(value);
    } else if (value is String) {
      var array = jsonDecode(value);
      if (array is! List) {
        throw ZnnSdkException('cannot encode $value as an array');
      }
      return encodeList(array);
    } else {
      throw ZnnSdkException('cannot encode $value as an array');
    }
  }

  List<int> encodeTuple(List l) {
    List<List<int>?> elems;
    if (elementType.isDynamicType()) {
      elems = List<List<int>>.filled(l.length * 2, [], growable: true);

      var offset = l.length * AbiType.int32Size;
      for (var i = 0; i < l.length; i++) {
        elems[i] = IntType.encodeInt(offset);
        List<int> encoded = elementType.encode(l[i]);
        elems[l.length + i] = encoded;
        offset +=
            (AbiType.int32Size * (encoded.length / AbiType.int32Size)).toInt();
      }
    } else {
      elems = List<List<int>>.filled(l.length, [], growable: true);
      for (var i = 0; i < l.length; i++) {
        elems[i] = elementType.encode(l[i]);
      }
    }
    return BytesUtils.merge(elems);
  }

  dynamic decodeTuple(List<int> encoded, int origOffset, int len) {
    var offset = origOffset;
    var ret = [];

    for (var i = 0; i < len; i++) {
      if (elementType.isDynamicType()) {
        ret.add(elementType.decode(
            encoded, origOffset + IntType.decodeInt(encoded, offset).toInt()));
      } else {
        ret.add(elementType.decode(encoded, offset));
      }
      offset += elementType.getFixedSize() as int;
    }
    return ret;
  }

  List<int> encodeList(List l);
}

class StaticArrayType extends ArrayType {
  int size = 0;

  StaticArrayType(String name) : super(name) {
    var idx1 = name.indexOf('[');
    var idx2 = name.indexOf(']', idx1);
    var dim = name.substring(idx1 + 1, idx2);
    size = int.parse(dim);
  }

  @override
  String? getCanonicalName() {
    return '${elementType.getCanonicalName()}[$size]';
  }

  @override
  List<int> encodeList(List l) {
    if (l.length != size) {
      throw ZnnSdkException(
          'expected $size array elements, got ${l.length}');
    }
    return encodeTuple(l);
  }

  @override
  dynamic decode(List<int> encoded, [int offset = 0]) {
    return decodeTuple(encoded, offset, size);
  }

  @override
  bool isDynamicType() {
    // A fixed-length array is itself dynamic when its elements are.
    return elementType.isDynamicType();
  }

  @override
  int? getFixedSize() {
    if (isDynamicType()) {
      return AbiType.int32Size;
    }
    return elementType.getFixedSize() * size;
  }
}

class DynamicArrayType extends ArrayType {
  DynamicArrayType(var name) : super(name);

  @override
  String? getCanonicalName() {
    return elementType.getCanonicalName() + '[]';
  }

  @override
  List<int> encodeList(List l) {
    return BytesUtils.merge([IntType.encodeInt(l.length), encodeTuple(l)]);
  }

  @override
  dynamic decode(List<int> encoded, [int origOffset = 0]) {
    var len = IntType.decodeInt(encoded, origOffset).toInt();
    origOffset += 32;
    return decodeTuple(encoded, origOffset, len);
  }

  @override
  bool isDynamicType() {
    return true;
  }
}

class BytesType extends AbiType {
  BytesType(String name) : super(name);

  BytesType.bytes() : super('bytes');

  @override
  List<int> encode(var value) {
    List<int> bb;

    if (value is List<int>) {
      bb = value;
    } else if (value is String) {
      bb = HEX.decode(value);
    } else {
      throw Error();
    }
    var ret = List<int>.filled(
        bb.isEmpty ? 0 : ((((bb.length - 1) ~/ AbiType.int32Size) + 1) * AbiType.int32Size)
            .toInt(),
        0,
        growable: true);
    for (var i = 0; i < ret.length; i++) {
      ret[i] = 0;
    }

    BytesUtils.arraycopy(bb, 0, ret, 0, bb.length);

    return BytesUtils.merge([IntType.encodeInt(bb.length), ret]);
  }

  @override
  dynamic decode(List<int> encoded, [int offset = 0]) {
    var len = IntType.decodeInt(encoded, offset).toInt();
    if (len == 0) {
      return List.filled(0, 0);
    }
    offset += 32;
    var l = List.filled(len, 0, growable: true);
    BytesUtils.arraycopy(encoded, offset, l, 0, len);
    return l;
  }

  @override
  bool isDynamicType() {
    return true;
  }
}

class StringType extends BytesType {
  StringType() : super('string');

  @override
  List<int> encode(var value) {
    if (value is! String) throw Error();
    return super.encode(utf8.encode(value));
  }

  @override
  dynamic decode(List<int> encoded, [int offset = 0]) {
    return utf8.decode((super.decode(encoded, offset)));
  }
}

class Bytes32Type extends AbiType {
  /// Number of bytes a value of this fixed-byte type must contain.
  ///
  /// Parsed from the type name (`bytes1` … `bytes32`); types without a
  /// numeric suffix (e.g. `function`) span the full 32-byte word.
  late final int size;

  Bytes32Type(String s) : super(s) {
    if (s.startsWith('bytes') && s.length > 'bytes'.length) {
      var parsed = int.tryParse(s.substring('bytes'.length));
      if (parsed == null || parsed < 1 || parsed > 32) {
        throw UnsupportedError('The type $s is not supported');
      }
      size = parsed;
    } else {
      size = AbiType.int32Size;
    }
  }

  @override
  List<int> encode(var value) {
    List<int> bytes;
    if (value is String) {
      bytes = HEX.decode(value.startsWith('0x') ? value.substring(2) : value);
    } else if (value is List<int>) {
      bytes = value;
    } else {
      throw ZnnSdkException('cannot encode $value as ${getCanonicalName()}');
    }
    if (bytes.length != size) {
      throw ZnnSdkException(
          'expected $size bytes for ${getCanonicalName()}, got ${bytes.length}');
    }
    var ret = List.filled(AbiType.int32Size, 0, growable: true);
    BytesUtils.arraycopy(bytes, 0, ret, 0, bytes.length);
    return ret;
  }

  @override
  dynamic decode(List<int> encoded, [int offset = 0]) {
    for (var i = size; i < AbiType.int32Size; i++) {
      if (encoded[offset + i] != 0) {
        throw ZnnSdkException(
            'non-zero padding in ${getCanonicalName()} word');
      }
    }
    var l = List.filled(size, 0, growable: true);
    BytesUtils.arraycopy(encoded, offset, l, 0, size);
    return l;
  }
}

class HashType extends AbiType {
  HashType(var s) : super(s);

  @override
  List<int> encode(var value) {
    if (value is num) {
      var bigInt = BigInt.from(value);
      return IntType.encodeIntBig(bigInt);
    } else if (value is String) {
      var ret = List.filled(AbiType.int32Size, 0, growable: true);
      var bytes = HEX.decode(value);
      BytesUtils.arraycopy(bytes, 0, ret, 0, bytes.length);
      return ret;
    } else if (value is List<int>) {
      var bytes = value;
      var ret = List.filled(AbiType.int32Size, 0, growable: true);
      BytesUtils.arraycopy(bytes, 0, ret, 0, bytes.length);
      return ret;
    }

    throw Error();
  }

  @override
  dynamic decode(List<int> encoded, [int offset = 0]) {
    var l = List.filled(AbiType.int32Size, 0, growable: true);
    BytesUtils.arraycopy(encoded, offset, l, 0, getFixedSize());
    return Hash.fromBytes(l);
  }
}

class TokenStandardType extends IntType {
  TokenStandardType() : super('tokenStandard');

  @override
  List<int> encode(var value) {
    if (value is String) {
      return BytesUtils.leftPadBytes(TokenStandard.parse(value).getBytes(), 32);
    }
    if (value is TokenStandard) {
      return BytesUtils.leftPadBytes(value.getBytes(), 32);
    }
    throw Error();
  }

  @override
  dynamic decode(List<int> encoded, [int offset = 0]) {
    var l = List.filled(10, 0, growable: true);
    BytesUtils.arraycopy(encoded, offset + 22, l, 0, 10);
    return TokenStandard.fromBytes(l);
  }
}

class UnsignedIntType extends NumericType {
  UnsignedIntType(String name) : super(name);

  @override
  String? getCanonicalName() {
    if (getName() == 'uint') return 'uint256';
    return super.getCanonicalName();
  }

  static BigInt decodeInt(List<int> encoded, int offset) {
    return BytesUtils.decodeBigInt(encoded.sublist(offset, offset + 32));
  }

  static List<int> encodeInt(int i) {
    return encodeIntBig(BigInt.from(i));
  }

  static List<int> encodeIntBig(BigInt bigInt) {
    if (bigInt.sign == -1) {
      throw ZnnSdkException('cannot encode negative value as unsigned integer');
    }
    return BytesUtils.bigIntToBytes(bigInt, 32);
  }

  @override
  List<int> encode(var value) {
    var bigInt = encodeInternal(value);
    var bits = bitSize();
    if (bigInt.sign == -1 || bigInt >= (BigInt.one << bits)) {
      throw ZnnSdkException(
          'value $bigInt out of range for ${getCanonicalName()}');
    }
    return encodeIntBig(bigInt);
  }

  @override
  dynamic decode(List<int> encoded, [int offset = 0]) {
    var value = decodeInt(encoded, offset);
    var bits = bitSize();
    if (value >= (BigInt.one << bits)) {
      throw ZnnSdkException(
          'decoded value $value out of range for ${getCanonicalName()}');
    }
    return value;
  }
}

class BoolType extends IntType {
  BoolType() : super('bool');

  @override
  List<int> encode(var value) {
    if (value is bool) {
      return super.encode(value ? 1 : 0);
    }
    throw ZnnSdkException('cannot encode $value as bool');
  }

  @override
  dynamic decode(List<int> encoded, [int offset = 0]) {
    var value = IntType.decodeInt(encoded, offset);
    if (value == BigInt.zero) return false;
    if (value == BigInt.one) return true;
    throw ZnnSdkException('decoded word is not a canonical bool');
  }
}

class FunctionType extends Bytes32Type {
  FunctionType() : super('function');

  @override
  List<int> encode(var value) {
    if (value is! List) throw Error();
    if (value.length != 24) throw Error();
    return super.encode(BytesUtils.merge(
        [value as List<int>?, List.filled(8, 0, growable: true)]));
  }

  @override
  dynamic decode(encoded, [offset = 0]) {
    throw UnimplementedError();
  }
}

abstract class NumericType extends AbiType {
  NumericType(String name) : super(name);

  /// Bit width of this numeric type, parsed from the `intN`/`uintN` name.
  ///
  /// Non-numeric subtypes (bool, address, tokenStandard) and the bare
  /// `int`/`uint` aliases span the full 256-bit word.
  int bitSize() {
    var n = getName()!;
    String suffix;
    if (n.startsWith('uint')) {
      suffix = n.substring(4);
    } else if (n.startsWith('int')) {
      suffix = n.substring(3);
    } else {
      return 256;
    }
    if (suffix.isEmpty) return 256;
    var bits = int.tryParse(suffix);
    if (bits == null || bits < 8 || bits > 256 || bits % 8 != 0) {
      throw UnsupportedError('The type $n is not supported');
    }
    return bits;
  }

  BigInt encodeInternal(Object? value) {
    BigInt bigInt;
    if (value is String) {
      var s = value.toLowerCase().trim();
      var radix = 10;
      if (s.startsWith('0x')) {
        s = s.substring(2);
        radix = 16;
      } else if (s.contains('a') ||
          s.contains('b') ||
          s.contains('c') ||
          s.contains('d') ||
          s.contains('e') ||
          s.contains('f')) {
        radix = 16;
      }
      bigInt = BigInt.parse(s, radix: radix);
    } else if (value is BigInt) {
      bigInt = value;
    } else if (value is num) {
      bigInt = BigInt.from(value);
    } else if (value is List) {
      bigInt = BytesUtils.bytesToBigInt(value as List<int>);
    } else {
      throw Error();
    }
    return bigInt;
  }
}

class AddressType extends IntType {
  AddressType() : super('address');

  @override
  List<int> encode(var value) {
    if (value is String) {
      return BytesUtils.leftPadBytes(Address.parse(value).getBytes()!, 32);
    }
    if (value is Address) {
      return BytesUtils.leftPadBytes(value.getBytes()!, 32);
    }
    throw Error();
  }

  @override
  dynamic decode(List<int> encoded, [int offset = 0]) {
    var l = List.filled(20, 0);
    BytesUtils.arraycopy(encoded, offset + 12, l, 0, 20);
    var a = Address('z', l);
    return a;
  }
}

abstract class AbiType {
  static int int32Size = 32;

  String? name;

  AbiType(var name) {
    this.name = name;
  }

  String? getName() {
    return name;
  }

  String? getCanonicalName() {
    return getName();
  }

  static AbiType getType(String typeName) {
    if (typeName.contains('[')) return ArrayType.getType(typeName);
    if ('bool' == typeName) return BoolType();
    if (typeName.startsWith('int')) return IntType(typeName);
    if (typeName.startsWith('uint')) return UnsignedIntType(typeName);
    if ('address' == typeName) return AddressType();
    if ('tokenStandard' == typeName) return TokenStandardType();
    if ('string' == typeName) return StringType();
    if ('bytes' == typeName) return BytesType.bytes();
    if ('function' == (typeName)) return FunctionType();
    if ('hash' == (typeName)) return HashType(typeName);
    if (typeName.startsWith('bytes')) return Bytes32Type(typeName);

    throw UnsupportedError('The type $typeName is not supported');
  }

  List<int> encode(Object? value);

  dynamic decode(List<int> encoded, [int offset = 0]);

  int? getFixedSize() {
    return 32;
  }

  bool isDynamicType() {
    return false;
  }

  @override
  String toString() {
    return getName()!;
  }
}
