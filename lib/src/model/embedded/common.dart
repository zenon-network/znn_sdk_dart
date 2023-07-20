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
