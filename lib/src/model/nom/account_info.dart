import 'package:collection/collection.dart' show IterableExtension;
import 'package:znn_sdk_dart/src/model/nom.dart';
import 'package:znn_sdk_dart/src/model/primitives.dart';

class AccountInfo {
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
}

class BalanceInfoListItem {
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
}
