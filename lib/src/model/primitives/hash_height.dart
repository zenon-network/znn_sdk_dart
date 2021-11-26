import 'package:znn_sdk_dart/src/model/primitives.dart';
import 'package:znn_sdk_dart/src/utils/bytes.dart';

final emptyHashHeight = HashHeight(emptyHash, 0);

class HashHeight {
  Hash? hash;
  int? height;

  HashHeight(Hash hash, int height) {
    this.hash = hash;
    this.height = height;
  }

  HashHeight.fromJson(Map<String, dynamic> json) {
    hash = Hash.parse(json['hash']);
    height = json['height'];
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
}
