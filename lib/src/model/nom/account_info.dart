import 'package:collection/collection.dart' show IterableExtension;
import 'package:znn_sdk_dart/src/model/nom.dart';
import 'package:znn_sdk_dart/src/model/primitives.dart';
import 'package:znn_sdk_dart/src/utils/utils.dart';

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

  int? znn() => getBalance(znnZts);

  int? qsr() => getBalance(qsrZts);

  int getBalance(TokenStandard tokenStandard) {
    var info = balanceInfoList!.firstWhereOrNull(
        (element) => element.token!.tokenStandard == tokenStandard);
    return info?.balance ?? 0;
  }

  num getBalanceWithDecimals(TokenStandard tokenStandard) {
    var info = balanceInfoList!.firstWhereOrNull(
        (element) => element.token!.tokenStandard == tokenStandard);
    return info?.balanceWithDecimals! ?? 0;
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
  int? balance;
  num? balanceWithDecimals;
  String? balanceFormatted;

  BalanceInfoListItem({this.token, this.balance}) {
    balanceWithDecimals = AmountUtils.addDecimals(balance!, token!.decimals);
    balanceFormatted = '$balanceWithDecimals ${token!.symbol}';
  }

  factory BalanceInfoListItem.fromJson(Map<String, dynamic> json) =>
      BalanceInfoListItem(
        token: json['token'] != null ? Token.fromJson(json['token']) : null,
        balance: json['balance'].toInt(),
      );

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (token != null) {
      data['token'] = token!.toJson();
    }
    data['balance'] = balance;
    return data;
  }
}
