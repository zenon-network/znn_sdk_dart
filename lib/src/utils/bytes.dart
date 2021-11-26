import 'dart:convert';
import 'dart:math';

import 'package:hex/hex.dart';

class BytesUtils {
  static dynamic arraycopy(var src, var startPos, var dest, var destPos, var len) {
    for (var i = 0; i < len; i++) {
      dest[destPos + i] = src[startPos + i];
    }
    return dest;
  }

  static BigInt decodeBigInt(List<int> bytes) {
    var result = BigInt.from(0);
    for (var i = 0; i < bytes.length; i++) {
      result *= BigInt.from(256);
      result += BigInt.from(bytes[i]);
    }
    return result;
  }

  static List<int> encodeBigInt(BigInt number) {
    var size = (number.bitLength + 7) >> 3;
    var result = List<int>.filled(size, 0, growable: true);
    for (var i = 0; i < size; i++) {
      result[i] = 0;
    }
    var _byteMask = BigInt.from(0xff);
    for (var i = 0; i < size; i++) {
      result[size - i - 1] = (number & _byteMask).toInt();
      number = number >> 8;
    }
    return result;
  }

  static List<int> bigIntToBytes(BigInt b, int numBytes) {
    var bytes = List<int>.filled(numBytes, 0, growable: true);
    for (var i = 0; i < numBytes; i++) {
      bytes[i] = 0;
    }
    var biBytes = encodeBigInt(b);
    var start = (biBytes.length == numBytes + 1) ? 1 : 0;
    var length = min(biBytes.length, numBytes);
    BytesUtils.arraycopy(biBytes, start, bytes, numBytes - length, length);
    return bytes;
  }

  static List<int> bigIntToBytesSigned(BigInt b, int numBytes) {
    var bytes = List<int>.filled(numBytes, b.sign < 0 ? 0xFF : 0x00, growable: true);
    var biBytes = encodeBigInt(b);
    var start = (biBytes.length == numBytes + 1) ? 1 : 0;
    var length = min(biBytes.length, numBytes);
    BytesUtils.arraycopy(biBytes, start, bytes, numBytes - length, length);
    return bytes;
  }

  static BigInt bytesToBigInt(List<int> bb) {
    return (bb.isEmpty) ? BigInt.from(0) : decodeBigInt(bb);
  }

  static List<int> merge(List<List<int>?> arrays) {
    var count = 0;
    for (var array in arrays) {
      count += array!.length;
    }
    if (count == 0) return <int>[];
    var mergedArray = List<int>.filled(count, 0, growable: true);
    var start = 0;
    for (var array in arrays) {
      if (array != []) {
        if (array is List<int>) {
          BytesUtils.arraycopy(array, 0, mergedArray, start, array.length);
          start += array.length;
        }
      }
    }
    return mergedArray;
  }

  static List<int> intToBytes(int integer) {
    var bytes = List<int>.filled(4, 0, growable: true);
    bytes[0] = (integer >> 24);
    bytes[1] = (integer >> 16);
    bytes[2] = (integer >> 8);
    bytes[3] = integer;
    return bytes;
  }

  static List<int> longToBytes(var longValue) {
    var buffer = List<int>.filled(8, 0, growable: true);
    for (var i = 0; i < 8; i++) {
      var offset = 64 - (i + 1) * 8;
      buffer[i] = ((longValue >> offset) & 0xff);
    }
    return buffer;
  }

  static List<int>? base64ToBytes(String base64Str) {
    return base64Str.isEmpty ? null : base64Decode(base64Str);
  }

  static String bytesToBase64(List<int> bytes) {
    return base64Encode(bytes);
  }

  static String bytesToHex(List<int> bytes) => HEX.encode(bytes);

  static List<int> leftPadBytes(List<int> bytes, int size) {
    if (bytes.length >= size) {
      return bytes;
    }
    var result = List<int>.filled(size, 0, growable: true);
    for (var i = 0; i < size; i++) {
      result[i] = 0;
    }
    BytesUtils.arraycopy(bytes, 0, result, size - bytes.length, bytes.length);
    return result;
  }
}
