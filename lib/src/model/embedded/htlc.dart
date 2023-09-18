import 'package:znn_sdk_dart/src/model/primitives.dart';
import 'package:znn_sdk_dart/src/utils/utils.dart';

class HtlcInfo {
  Hash id;
  Address timeLocked;
  Address hashLocked;
  TokenStandard tokenStandard;
  BigInt amount;
  int expirationTime;
  int hashType;
  int keyMaxSize;
  List<int> hashLock;

  HtlcInfo(
      {required this.id,
      required this.timeLocked,
      required this.hashLocked,
      required this.tokenStandard,
      required this.amount,
      required this.expirationTime,
      required this.hashType,
      required this.keyMaxSize,
      required this.hashLock});

  HtlcInfo.fromJson(Map<String, dynamic> json)
      : id = Hash.parse(json['id']),
        timeLocked = Address.parse(json['timeLocked']),
        hashLocked = Address.parse(json['hashLocked']),
        tokenStandard = TokenStandard.parse(json['tokenStandard']),
        amount = BigInt.parse(json['amount']),
        expirationTime = json['expirationTime'],
        hashType = json['hashType'],
        keyMaxSize = json['keyMaxSize'],
        hashLock = BytesUtils.base64ToBytes(json['hashLock']) ?? [];

  Map<String, dynamic> toJson() => {
        'id': id.toString(),
        'timeLocked': timeLocked.toString(),
        'hashLocked': hashLocked.toString(),
        'tokenStandard': tokenStandard.toString(),
        'amount': amount.toString(),
        'expirationTime': expirationTime,
        'hashType': hashType,
        'keyMaxSize': keyMaxSize,
        'hashLock': BytesUtils.bytesToBase64(hashLock)
      };
}
