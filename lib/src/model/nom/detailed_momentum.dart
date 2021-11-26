import 'package:znn_sdk_dart/src/model/nom/account_block.dart';
import 'package:znn_sdk_dart/src/model/nom/momentum.dart';

class DetailedMomentum {
  late List<AccountBlock> blocks;
  late Momentum momentum;

  DetailedMomentum.fromJson(Map<String, dynamic> json) {
    blocks = (json['blocks'] as List).fold<List<AccountBlock>>([],
        (previousValue, j) {
      previousValue.add(AccountBlock.fromJson(j));
      return previousValue;
    });
    momentum = Momentum.fromJson(json['momentum']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['blocks'] = blocks.map((j) => j.toJson()).toList();
    data['momentum'] = momentum.toJson();
    return data;
  }
}

class DetailedMomentumList {
  int? count;
  List<DetailedMomentum>? list;

  DetailedMomentumList({this.count, this.list});

  DetailedMomentumList.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    if (json['list'] != null) {
      list = <DetailedMomentum>[];
      json['list'].forEach((v) {
        list!.add(DetailedMomentum.fromJson(v));
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
