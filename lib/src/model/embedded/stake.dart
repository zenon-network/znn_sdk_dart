import 'package:znn_sdk_dart/src/model/primitives.dart';

class StakeList {
  int totalAmount;
  int totalWeightedAmount;
  int count;
  List<StakeEntry> list;

  StakeList(
      {required this.totalAmount,
      required this.totalWeightedAmount,
      required this.count,
      required this.list});

  StakeList.fromJson(Map<String, dynamic> json)
      : totalAmount = json['totalAmount'],
        totalWeightedAmount = json['totalWeightedAmount'],
        count = json['count'],
        list = (json['list'] as List)
            .map((entry) => StakeEntry.fromJson(entry))
            .toList();
}

class StakeEntry {
  final int amount;
  final int weightedAmount;
  final int startTimestamp;
  final int expirationTimestamp;
  final Address address;
  final Hash id;

  StakeEntry(
      {required this.amount,
      required this.weightedAmount,
      required this.startTimestamp,
      required this.expirationTimestamp,
      required this.address,
      required this.id});

  factory StakeEntry.fromJson(Map<String, dynamic> json) => StakeEntry(
      amount: json['amount'],
      weightedAmount: json['weightedAmount'],
      startTimestamp: json['startTimestamp'],
      expirationTimestamp: json['expirationTimestamp'],
      address: Address.parse(json['address']),
      id: Hash.parse(json['id']));
}
