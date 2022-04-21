import 'package:collection/collection.dart';
import 'package:hex/hex.dart';
import 'package:znn_sdk_dart/src/crypto/crypto.dart';

Hash emptyHash = Hash.parse(
    '0000000000000000000000000000000000000000000000000000000000000000');

class Hash {
  final List<int> hash;
  static const int length = 32;

  Hash.fromBytes(List<int> hash) : hash = hash {
    if (hash.length != length) {
      throw ArgumentError('Invalid hash length');
    }
  }

  Hash.parse(String hash) : hash = HEX.decode(hash) {
    if (hash.length != 2 * length) {
      throw ArgumentError('Invalid hash length');
    }
  }

  Hash.digest(List<int> byteArrays) : hash = Crypto.digest(byteArrays, length);

  List<int>? getBytes() {
    return hash;
  }

  @override
  String toString() {
    return HEX.encode(hash);
  }

  String toShortString() {
    var longString = toString();
    return longString.substring(0, 6) +
        '...' +
        longString.substring(longString.length - 6);
  }

  bool equals(Hash hash) {
    if (this == hash) {
      return true;
    }

    return DeepCollectionEquality().equals(this.getBytes(), hash.getBytes());
  }

  int compareTo(Hash otherHash) =>
      hash.toString().compareTo(otherHash.toString());

  bool operator ==(Object other) =>
      other is Hash &&
      other.runtimeType == runtimeType &&
      other.toString() == toString();

  @override
  int get hashCode => toString().hashCode;
}
