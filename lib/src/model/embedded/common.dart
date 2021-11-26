import 'package:znn_sdk_dart/src/model/primitives.dart';

class UncollectedReward {
  final Address address;
  final int znnAmount;
  final int qsrAmount;

  UncollectedReward.fromJson(Map<String, dynamic> json)
      : address = Address.parse(json['address']),
        znnAmount = json['znnAmount'],
        qsrAmount = json['qsrAmount'];
}

class RewardHistoryEntry {
  final int epoch;
  final int znnAmount;
  final int qsrAmount;

  RewardHistoryEntry.fromJson(Map<String, dynamic> json)
      : epoch = json['epoch'],
        znnAmount = json['znnAmount'],
        qsrAmount = json['qsrAmount'];

  Map<String, dynamic> toJson() => {
        'epoch': epoch,
        'znnAmount': znnAmount,
        'qsrAmount': qsrAmount,
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

class PillarVoteList {
  VoteBreakdown voteBreakdown;
  int count;
  List<PillarVote> list;

  PillarVoteList.fromJson(Map<String, dynamic> json)
      : voteBreakdown = VoteBreakdown.fromJson(json['breakdown']),
        count = json['count'],
        list =
            (json['list'] as List).map((j) => PillarVote.fromJson(j)).toList();

  Map<String, dynamic> toJson() => {
        'breakdown': voteBreakdown.toString(),
        'count': count,
        'list': list.map((v) => v.toJson()).toList(),
      };
}
