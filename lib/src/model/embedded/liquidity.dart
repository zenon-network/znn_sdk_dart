import 'package:znn_sdk_dart/src/model/primitives.dart';

class LiquidityInfo {
  Address administrator;
  bool isHalted;
  BigInt znnReward;
  BigInt qsrReward;
  List<TokenTuple> tokenTuples;

  LiquidityInfo({
    required this.administrator,
    required this.isHalted,
    required this.znnReward,
    required this.qsrReward,
    required this.tokenTuples,
  });

  LiquidityInfo.fromJson(Map<String, dynamic> json)
      : administrator = Address.parse(json['administrator']),
        isHalted = json['isHalted'],
        znnReward = BigInt.parse(json['znnReward']),
        qsrReward = BigInt.parse(json['qsrReward']),
        tokenTuples = (json['tokenTuples'] as List)
            .map((entry) => TokenTuple.fromJson(entry))
            .toList();

  Map<String, dynamic> toJson() => {
        'administrator': administrator.toString(),
        'isHalted': isHalted,
        'znnReward': znnReward.toString(),
        'qsrReward': qsrReward.toString(),
        'tokenTuples': tokenTuples,
      };
}

class TokenTuple {
  TokenStandard tokenStandard;
  int znnPercentage;
  int qsrPercentage;
  BigInt minAmount;

  TokenTuple({
    required this.tokenStandard,
    required this.znnPercentage,
    required this.qsrPercentage,
    required this.minAmount,
  });

  TokenTuple.fromJson(Map<String, dynamic> json)
      : tokenStandard = TokenStandard.parse(json['tokenStandard']),
        znnPercentage = json['znnPercentage'],
        qsrPercentage = json['qsrPercentage'],
        minAmount = BigInt.parse(json['minAmount']);

  Map<String, dynamic> toJson() => {
        'tokenStandard': tokenStandard.toString(),
        'znnPercentage': znnPercentage,
        'qsrPercentage': qsrPercentage,
        'minAmount': minAmount.toString(),
      };
}

class LiquidityStakeEntry {
  BigInt amount;
  TokenStandard tokenStandard;
  BigInt weightedAmount;
  int startTime;
  int revokeTime;
  int expirationTime;
  Address stakeAddress;
  Hash id;

  LiquidityStakeEntry({
    required this.amount,
    required this.tokenStandard,
    required this.weightedAmount,
    required this.startTime,
    required this.revokeTime,
    required this.expirationTime,
    required this.stakeAddress,
    required this.id,
  });

  LiquidityStakeEntry.fromJson(Map<String, dynamic> json)
      : amount = BigInt.parse(json['amount']),
        tokenStandard = TokenStandard.parse(json['tokenStandard']),
        weightedAmount = BigInt.parse(json['weightedAmount']),
        startTime = json['startTime'],
        revokeTime = json['revokeTime'],
        expirationTime = json['expirationTime'],
        stakeAddress = Address.parse(json['stakeAddress']),
        id = Hash.parse(json['id']);

  Map<String, dynamic> toJson() => {
        'amount': amount.toString(),
        'tokenStandard': tokenStandard.toString(),
        'weightedAmount': weightedAmount.toString(),
        'startTime': startTime,
        'revokeTime': revokeTime,
        'expirationTime': expirationTime,
        'stakeAddress': stakeAddress.toString(),
        'id': id.toString(),
      };
}

class LiquidityStakeList {
  BigInt totalAmount;
  BigInt totalWeightedAmount;
  int count;
  List<LiquidityStakeEntry> list;

  LiquidityStakeList({
    required this.totalAmount,
    required this.totalWeightedAmount,
    required this.count,
    required this.list,
  });

  LiquidityStakeList.fromJson(Map<String, dynamic> json)
      : totalAmount = BigInt.parse(json['totalAmount']),
        totalWeightedAmount = BigInt.parse(json['totalWeightedAmount']),
        count = json['count'],
        list = (json['list'] as List)
            .map((entry) => LiquidityStakeEntry.fromJson(entry))
            .toList();

  Map<String, dynamic> toJson() => {
        'totalAmount': totalAmount.toString(),
        'totalWeightedAmount': totalWeightedAmount.toString(),
        'count': count,
        'list': list.map((v) => v.toJson()).toList(),
      };
}
