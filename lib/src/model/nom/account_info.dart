import 'package:collection/collection.dart' show IterableExtension;
import 'package:equatable/equatable.dart';
import 'package:znn_sdk_dart/src/model/nom.dart';
import 'package:znn_sdk_dart/src/model/primitives.dart';

class AccountInfo extends Equatable {
  String? address;
  int? blockCount;
  List<BalanceInfoListItem>? balanceInfoList;

  AccountInfo({this.address, this.blockCount, this.balanceInfoList});

  AccountInfo.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    blockCount = json['accountHeight'];
    balanceInfoList = blockCount! > 0
        ? json['balanceInfoMap']
            .keys
            .map<BalanceInfoListItem>(
                (e) => BalanceInfoListItem.fromJson(json['balanceInfoMap'][e]))
            .toList()
        : [];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (address != null) {
      data['address'] = address;
    }
    if (blockCount != null) {
      data['accountHeight'] = blockCount;
    }
    if (balanceInfoList != null) {
      final Iterable<String> keys =
          balanceInfoList!.map((e) => e.token!.tokenStandard.toString());
      final Iterable<Map<String, dynamic>> values =
          balanceInfoList!.map((e) => e.toJson());
      final Map<String, dynamic> finalMap = Map.fromIterables(keys, values);
      data['balanceInfoMap'] = finalMap;
    }
    return data;
  }

  BigInt? znn() => getBalance(znnZts);

  BigInt? qsr() => getBalance(qsrZts);

  BigInt getBalance(TokenStandard tokenStandard) {
    var info = balanceInfoList!.firstWhereOrNull(
        (element) => element.token!.tokenStandard == tokenStandard);
    return info?.balance ?? BigInt.zero;
  }

  Token? findTokenByTokenStandard(TokenStandard tokenStandard) {
    try {
      return balanceInfoList!
          .firstWhere(
            (element) => element.token!.tokenStandard == tokenStandard,
          )
          .token;
    } catch (e) {
      return null;
    }
  }

  @override
  List<Object?> get props => [address, blockCount, balanceInfoList];
}

class BalanceInfoListItem extends Equatable {
  Token? token;
  BigInt? balance;

  BalanceInfoListItem({required this.token, required this.balance}) {}

  factory BalanceInfoListItem.fromJson(Map<String, dynamic> json) =>
      BalanceInfoListItem(
        token: json['token'] != null ? Token.fromJson(json['token']) : null,
        balance: BigInt.parse(json['balance']),
      );

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (token != null) {
      data['token'] = token!.toJson();
    }
    data['balance'] = balance.toString();
    return data;
  }

  @override
  List<Object?> get props => [token, balance];
}
