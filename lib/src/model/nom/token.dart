import 'dart:math';

import 'package:znn_sdk_dart/src/model/primitives.dart';

class Token {
  String name;
  String symbol;
  String domain;
  BigInt totalSupply;
  int decimals;
  Address owner;
  TokenStandard tokenStandard;
  BigInt maxSupply;
  bool isBurnable;
  bool isMintable;
  bool isUtility;

  Token(
    this.name,
    this.symbol,
    this.domain,
    this.totalSupply,
    this.decimals,
    this.owner,
    this.tokenStandard,
    this.maxSupply,
    this.isBurnable,
    this.isMintable,
    this.isUtility,
  );

  factory Token.fromJson(Map<String, dynamic> json) => Token(
        json['name'],
        json['symbol'],
        json['domain'],
        BigInt.parse(json['totalSupply']),
        json['decimals'],
        Address.parse(json['owner']),
        TokenStandard.parse(json['tokenStandard']),
        BigInt.parse(json['maxSupply']),
        json['isBurnable'],
        json['isMintable'],
        json['isUtility'],
      );

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['symbol'] = symbol;
    data['domain'] = domain;
    data['totalSupply'] = totalSupply.toString();
    data['decimals'] = decimals;
    data['owner'] = owner.toString();
    data['tokenStandard'] = tokenStandard.toString();
    data['maxSupply'] = maxSupply.toString();
    data['isBurnable'] = isBurnable;
    data['isMintable'] = isMintable;
    data['isUtility'] = isUtility;
    return data;
  }

  int decimalsExponent() {
    return pow(10, decimals) as int;
  }

  bool operator ==(Object other) =>
      other is Token &&
      other.runtimeType == runtimeType &&
      other.tokenStandard == tokenStandard;

  @override
  int get hashCode => tokenStandard.toString().hashCode;
}

class TokenList {
  int? count;
  List<Token>? list;

  TokenList({this.count, this.list});

  TokenList.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    if (json['list'] != null) {
      list = <Token>[];
      json['list'].forEach((v) {
        list!.add(Token.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['count'] = count;
    if (list != null) {
      data['list'] = list!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
