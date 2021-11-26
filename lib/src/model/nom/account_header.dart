import 'package:znn_sdk_dart/src/model/primitives.dart';

class AccountHeader {
  /// Added here for simplicity. Is not part of the RPC response.
  Address? address;
  Hash? hash;
  int? height;

  AccountHeader({this.hash, this.height});

  AccountHeader.fromJson(Map<String, dynamic> json) {
    address = Address.parse(json['address']);
    hash = Hash.parse(json['hash']);
    height = json['height'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['address'] = address.toString();
    data['hash'] = hash.toString();
    data['height'] = height;
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
