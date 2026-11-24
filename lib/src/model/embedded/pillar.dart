import 'package:equatable/equatable.dart';
import 'package:znn_sdk_dart/src/model/primitives.dart';

// ignore: must_be_immutable
class PillarInfo extends Equatable {
  static const int unknownType = 0;
  static const int legacyPillarType = 1;
  static const int regularPillarType = 2;

  String name;
  int rank;
  int type;
  Address ownerAddress;
  Address producerAddress;
  Address withdrawAddress;
  int giveMomentumRewardPercentage;
  int giveDelegateRewardPercentage;
  bool isRevocable;
  int revokeCooldown;
  int revokeTimestamp;
  PillarEpochStats currentStats;
  BigInt weight;
  int producedMomentums;
  int expectedMomentums;

  PillarInfo.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        rank = json['rank'],
        type = json['type'] ?? unknownType,
        ownerAddress = Address.parse(json['ownerAddress']),
        producerAddress = Address.parse(json['producerAddress']),
        withdrawAddress = Address.parse(json['withdrawAddress']),
        giveMomentumRewardPercentage = json['giveMomentumRewardPercentage'],
        giveDelegateRewardPercentage = json['giveDelegateRewardPercentage'],
        isRevocable = json['isRevocable'],
        revokeCooldown = json['revokeCooldown'],
        revokeTimestamp = json['revokeTimestamp'],
        currentStats = PillarEpochStats.fromJson(json['currentStats']),
        weight = BigInt.parse(json['weight']),
        producedMomentums = json['currentStats']['producedMomentums'],
        expectedMomentums = json['currentStats']['expectedMomentums'];

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['rank'] = rank;
    data['type'] = type;
    data['ownerAddress'] = ownerAddress.toString();
    data['producerAddress'] = producerAddress.toString();
    data['withdrawAddress'] = withdrawAddress.toString();
    data['giveMomentumRewardPercentage'] = giveMomentumRewardPercentage;
    data['giveDelegateRewardPercentage'] = giveDelegateRewardPercentage;
    data['isRevocable'] = isRevocable;
    data['revokeCooldown'] = revokeCooldown;
    data['revokeTimestamp'] = revokeTimestamp;
    data['currentStats'] = currentStats.toJson();
    data['weight'] = weight.toString();
    return data;
  }

  @override
  List<Object?> get props => [
        name,
        rank,
        type,
        ownerAddress,
        producerAddress,
        withdrawAddress,
        giveMomentumRewardPercentage,
        giveDelegateRewardPercentage,
        isRevocable,
        revokeCooldown,
        revokeTimestamp,
        currentStats,
        weight,
        producedMomentums,
        expectedMomentums,
      ];
}

class PillarInfoList {
  int count;
  List<PillarInfo> list;

  PillarInfoList.fromJson(Map<String, dynamic> json)
      : count = json['count'],
        list =
            (json['list'] as List).map((j) => PillarInfo.fromJson(j)).toList();

  Map<String, dynamic> toJson() =>
      {'count': count, 'list': list.map((v) => v.toJson()).toList()};
}

// ignore: must_be_immutable
class PillarEpochStats extends Equatable {
  int producedMomentums;
  int expectedMomentums;

  PillarEpochStats.fromJson(Map<String, dynamic> json)
      : producedMomentums = json['producedMomentums'],
        expectedMomentums = json['expectedMomentums'];

  Map<String, dynamic> toJson() => {
        'producedMomentums': producedMomentums,
        'expectedMomentums': expectedMomentums
      };

  @override
  List<Object?> get props => [producedMomentums, expectedMomentums];
}

class PillarEpochHistory {
  String name;
  int epoch;
  int giveBlockRewardPercentage;
  int giveDelegateRewardPercentage;
  int producedBlockNum;
  int expectedBlockNum;
  BigInt weight;

  PillarEpochHistory(
      this.name,
      this.epoch,
      this.giveBlockRewardPercentage,
      this.giveDelegateRewardPercentage,
      this.producedBlockNum,
      this.expectedBlockNum,
      this.weight);

  PillarEpochHistory.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        epoch = json['epoch'],
        giveBlockRewardPercentage = json['giveBlockRewardPercentage'],
        giveDelegateRewardPercentage = json['giveDelegateRewardPercentage'],
        producedBlockNum = json['producedBlockNum'],
        expectedBlockNum = json['expectedBlockNum'],
        weight = BigInt.parse(json['weight']);

  Map<String, dynamic> toJson() => {
        'name': name,
        'epoch': epoch,
        'giveBlockRewardPercentage': giveBlockRewardPercentage,
        'giveDelegateRewardPercentage': giveDelegateRewardPercentage,
        'producedBlockNum': producedBlockNum,
        'expectedBlockNum': expectedBlockNum,
        'weight': weight.toString()
      };
}

class PillarEpochHistoryList {
  int count;
  List<PillarEpochHistory> list;

  PillarEpochHistoryList.fromJson(Map<String, dynamic> json)
      : count = json['count'],
        list = (json['list'] as List)
            .map((entry) => PillarEpochHistory.fromJson(entry))
            .toList();

  Map<String, dynamic> toJson() =>
      {'count': count, 'list': list.map((v) => v.toJson()).toList()};
}

class DelegationInfo {
  String name;
  int status;
  BigInt weight;

  DelegationInfo(
      {required this.name, required this.status, required this.weight}) {}

  factory DelegationInfo.fromJson(Map<String, dynamic> json) => DelegationInfo(
        name: json['name'],
        status: json['status'],
        weight: BigInt.parse(json['weight']),
      );

  Map<String, dynamic> toJson() =>
      {'name': name, 'status': status, 'weight': weight.toString()};

  bool isPillarActive() {
    return status == 1;
  }

  @override
  bool operator ==(Object other) =>
      other is DelegationInfo &&
          other.runtimeType == runtimeType &&
          other.name == name &&
          other.status == status &&
          other.weight.toString() == weight.toString();

  @override
  int get hashCode => Object.hash(name, status, weight);
}
