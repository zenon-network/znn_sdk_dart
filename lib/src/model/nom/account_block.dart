import 'package:znn_sdk_dart/src/model/model.dart';
import 'package:znn_sdk_dart/src/model/primitives.dart';

class AccountBlockConfirmationDetail {
  int numConfirmations;
  int momentumHeight;
  Hash momentumHash;
  int momentumTimestamp;

  AccountBlockConfirmationDetail.fromJson(Map<String, dynamic> json)
      : numConfirmations = json['numConfirmations'],
        momentumHeight = json['momentumHeight'],
        momentumHash = Hash.parse(json['momentumHash']),
        momentumTimestamp = json['momentumTimestamp'];

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['numConfirmations'] = numConfirmations;
    data['momentumHeight'] = momentumHeight;
    data['momentumHash'] = momentumHash.toString();
    data['momentumTimestamp'] = momentumTimestamp;
    return data;
  }
}

class AccountBlock extends AccountBlockTemplate {
  List<AccountBlock> descendantBlocks;
  int basePlasma;
  int usedPlasma;
  Hash changesHash;

  Token? token;

  /// Available if account-block is confirmed, null otherwise
  AccountBlockConfirmationDetail? confirmationDetail;

  AccountBlock? pairedAccountBlock;

  AccountBlock.fromJson(Map<String, dynamic> json)
      : descendantBlocks = (json['descendantBlocks'] as List)
            .map((j) => AccountBlock.fromJson(j))
            .toList(),
        basePlasma = json['basePlasma'],
        usedPlasma = json['usedPlasma'],
        changesHash = Hash.parse(json['changesHash']),
        super.fromJson(json) {
    token = json['token'] != null ? Token.fromJson(json['token']) : null;
    confirmationDetail = json['confirmationDetail'] != null
        ? AccountBlockConfirmationDetail.fromJson(json['confirmationDetail'])
        : null;
    pairedAccountBlock = json['pairedAccountBlock'] != null
        ? AccountBlock.fromJson(json['pairedAccountBlock'])
        : null;
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['descendantBlocks'] =
        descendantBlocks.map((block) => block.toJson()).toList();
    data['usedPlasma'] = usedPlasma;
    data['basePlasma'] = basePlasma;
    data['changesHash'] = changesHash.toString();

    data['token'] = token != null ? token!.toJson() : null;
    data['confirmationDetail'] =
        confirmationDetail != null ? confirmationDetail!.toJson() : null;
    data['pairedAccountBlock'] =
        pairedAccountBlock != null ? pairedAccountBlock!.toJson() : null;

    return data;
  }

  bool isCompleted() => confirmationDetail != null;
}

class AccountBlockList {
  int? count;
  List<AccountBlock>? list;

  /// If true, there are more elements that can be retrieved
  bool? more;

  AccountBlockList({this.count, this.list, this.more});

  AccountBlockList.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    if (json['list'] != null) {
      list = <AccountBlock>[];
      json['list'].forEach((v) {
        list!.add(AccountBlock.fromJson(v));
      });
    }
    more = json['more'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['count'] = count;
    if (list != null) {
      data['list'] = list!.map((v) => v.toJson()).toList();
    }
    data['more'] = more;
    return data;
  }
}
