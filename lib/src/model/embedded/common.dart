import 'package:znn_sdk_dart/src/model/primitives.dart';

class UncollectedReward {
  final Address address;
  final BigInt znnAmount;
  final BigInt qsrAmount;

  UncollectedReward.fromJson(Map<String, dynamic> json)
      : address = Address.parse(json['address']),
        znnAmount = BigInt.parse(json['znnAmount']),
        qsrAmount = BigInt.parse(json['qsrAmount']);
}

class RewardHistoryEntry {
  final int epoch;
  final BigInt znnAmount;
  final BigInt qsrAmount;

  RewardHistoryEntry.fromJson(Map<String, dynamic> json)
      : epoch = json['epoch'],
        znnAmount = BigInt.parse(json['znnAmount']),
        qsrAmount = BigInt.parse(json['qsrAmount']);

  Map<String, dynamic> toJson() => {
        'epoch': epoch,
        'znnAmount': znnAmount.toString(),
        'qsrAmount': qsrAmount.toString(),
      };
}

class RewardHistoryList {
  int count;
  List<RewardHistoryEntry> list;

  RewardHistoryList.fromJson(Map<String, dynamic> json)
      : count = json['count'],
        list = (json['list'] as List)
            .map((entry) => RewardHistoryEntry.fromJson(entry))
            .toList();

  Map<String, dynamic> toJson() =>
      {'count': count, 'list': list.map((v) => v.toJson()).toList()};
}

class VoteBreakdown {
  Hash id;
  int yes;
  int no;
  int total;

  VoteBreakdown.fromJson(Map<String, dynamic> json)
      : id = Hash.parse(json['id']),
        yes = json['yes'],
        no = json['no'],
        total = json['total'];

  Map<String, dynamic> toJson() =>
      {'id': id.toString(), 'yes': yes, 'no': no, 'total': total};

  @override
  String toString() {
    return toJson().toString();
  }
}

class PillarVote {
  Hash id;
  String name;
  int vote;

  PillarVote.fromJson(Map<String, dynamic> json)
      : id = Hash.parse(json['id']),
        name = json['name'],
        vote = json['vote'];

  Map<String, dynamic> toJson() =>
      {'id': id.toString(), 'name': name, 'vote': vote};
}

class SecurityInfo {
  List<Address> guardians;
  List<Address> guardiansVotes;
  int administratorDelay;
  int softDelay;

  SecurityInfo.fromJson(Map<String, dynamic> json)
      : guardians = (json['guardians'] as List)
            .map((entry) => Address.parse(entry))
            .toList(),
        guardiansVotes = (json['guardiansVotes'] as List)
            .map((entry) => Address.parse(entry))
            .toList(),
        administratorDelay = json['administratorDelay'],
        softDelay = json['softDelay'];

  Map<String, dynamic> toJson() => {
        'guardians': guardians.map((v) => v.toString()).toList(),
        'guardiansVotes': guardiansVotes.map((v) => v.toString()).toList(),
        'administratorDelay': administratorDelay,
        'softDelay': softDelay,
      };
}

class RewardDeposit {
  Address address;
  BigInt znnAmount;
  BigInt qsrAmount;

  RewardDeposit({
    required this.address,
    required this.znnAmount,
    required this.qsrAmount,
  });

  RewardDeposit.fromJson(Map<String, dynamic> json)
      : address = Address.parse(json['address']),
        znnAmount = BigInt.parse(json['znnAmount']),
        qsrAmount = BigInt.parse(json['qsrAmount']);

  Map<String, dynamic> toJson() => {
        'address': address.toString(),
        'znnAmount': znnAmount.toString(),
        'qsrAmount': qsrAmount.toString(),
      };
}

class TimeChallengeInfo {
  String methodName;
  Hash paramsHash;
  int challengeStartHeight;

  TimeChallengeInfo({
    required this.methodName,
    required this.paramsHash,
    required this.challengeStartHeight,
  });

  TimeChallengeInfo.fromJson(Map<String, dynamic> json)
      : methodName = json['MethodName'],
        paramsHash = Hash.parse(json['ParamsHash']),
        challengeStartHeight = json['ChallengeStartHeight'];

  Map<String, dynamic> toJson() => {
        'MethodName': methodName,
        'ParamsHash': paramsHash.toString(),
        'ChallengeStartHeight': challengeStartHeight,
      };
}
