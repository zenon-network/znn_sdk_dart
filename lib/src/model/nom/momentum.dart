import 'package:znn_sdk_dart/src/model/primitives.dart';
import 'package:znn_sdk_dart/src/utils/bytes.dart';

import 'account_header.dart';

class Momentum {
  int version;
  int chainIdentifier;

  Hash hash;
  Hash previousHash;
  int height;
  int timestamp;

  List<int> data;
  List<AccountHeader> content;
  Hash? changesHash;

  String publicKey;
  String signature;
  Address producer;

  Momentum(
    this.version,
    this.chainIdentifier,
    this.hash,
    this.previousHash,
    this.height,
    this.timestamp,
    this.data,
    this.content,
    this.changesHash,
    this.publicKey,
    this.signature,
    this.producer,
  );

  Momentum.fromJson(Map<String, dynamic> json)
      : version = json['version'],
        chainIdentifier = json['chainIdentifier'],
        hash = Hash.parse(json['hash']),
        previousHash = Hash.parse(json['previousHash']),
        height = json['height'],
        timestamp = json['timestamp'],
        data =
            (json['data'] == '' ? [] : BytesUtils.base64ToBytes(json['data']))!,
        content = (json['content'] as List)
            .map((j) => AccountHeader.fromJson(j))
            .toList(),
        changesHash = Hash.parse(json['changesHash']),
        publicKey = json['publicKey'] ?? '',
        signature = json['signature'] ?? '',
        producer = Address.parse(json['producer']);

  Map<String, dynamic> toJson() {
    final j = <String, dynamic>{};
    j['version'] = version;
    j['chainIdentifier'] = chainIdentifier;
    j['hash'] = hash.toString();
    j['previousHash'] = previousHash.toString();
    j['height'] = height;
    j['timestamp'] = timestamp;
    j['data'] = data != [] ? BytesUtils.bytesToBase64(data) : '';
    j['content'] = [];
    for (var entry in content) {
      j['content'].add(entry.toString());
    }
    j['changesHash'] = changesHash.toString();
    j['publicKey'] = publicKey;
    j['signature'] = signature;
    j['producer'] = producer.toString();
    return j;
  }
}

class MomentumList {
  int count;
  List<Momentum> list;

  MomentumList(this.count, this.list);

  MomentumList.fromJson(Map<String, dynamic> json)
      : count = json['count'],
        list = (json['list'] as List).map((j) => Momentum.fromJson(j)).toList();

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['count'] = count;
    data['list'] = list.map((v) => v.toJson()).toList();
    return data;
  }
}

class MomentumShort {
  final Hash? hash;
  final int? height;
  final int? timestamp;

  MomentumShort({
    this.hash,
    this.height,
    this.timestamp,
  });

  MomentumShort.fromJson(Map<String, dynamic> json)
      : hash = Hash.parse(json['hash']),
        height = json['height'],
        timestamp = json['timestamp'];
}
