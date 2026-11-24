import 'package:equatable/equatable.dart';
import 'package:znn_sdk_dart/src/model/primitives.dart';
import 'package:znn_sdk_dart/src/utils/bytes.dart';

final emptyHashHeight = HashHeight(emptyHash, 0);

class HashHeight extends Equatable {
  Hash? hash;
  int? height;

  HashHeight(Hash hash, int height) {
    this.hash = hash;
    this.height = _validateHeight(height);
  }

  HashHeight.fromJson(Map<String, dynamic> json) {
    hash = Hash.parse(json['hash']);
    height = _validateHeight(json['height']);
  }

  // Dart ints are signed 64-bit, so values above 2^63-1 are unrepresentable
  // and heights that would overflow arrive here negative; rejecting negatives
  // therefore bounds heights to [0, 2^63).
  static int _validateHeight(int height) {
    if (height < 0) {
      throw ArgumentError('height must be a non-negative 64-bit integer');
    }
    return height;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['hash'] = hash.toString();
    data['height'] = height;
    return data;
  }

  List<int> getBytes() {
    return BytesUtils.merge(
        [hash!.getBytes(), BytesUtils.longToBytes(height!)]);
  }

  @override
  List<Object?> get props => [hash, height];
}
