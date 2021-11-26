import 'package:znn_sdk_dart/src/model/primitives.dart';

class SentinelInfo {
  Address owner;
  int registrationTimestamp;
  bool isRevocable;
  int revokeCooldown;
  bool active;

  SentinelInfo.fromJson(Map<String, dynamic> json)
      : owner = Address.parse(json['owner']),
        registrationTimestamp = json['registrationTimestamp'],
        isRevocable = json['isRevocable'],
        revokeCooldown = json['revokeCooldown'],
        active = json['active'];

  Map<String, dynamic> toJson() => {
        'owner': stakeAddress.toString(),
        'registrationTimestamp': registrationTimestamp,
        'isRevocable': isRevocable,
        'revokeCooldown': revokeCooldown,
        'active': active
      };
}

class SentinelInfoList {
  int count;
  List<SentinelInfo> list;

  SentinelInfoList({required this.count, required this.list});

  SentinelInfoList.fromJson(Map<String, dynamic> json)
      : count = json['count'],
        list = (json['list'] as List)
            .map((entry) => SentinelInfo.fromJson(entry))
            .toList();

  Map<String, dynamic> toJson() =>
      {'count': count, 'list': list.map((v) => v.toJson()).toList()};
}
