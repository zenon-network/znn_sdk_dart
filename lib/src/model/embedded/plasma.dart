import 'package:znn_sdk_dart/src/model/nom.dart';
import 'package:znn_sdk_dart/src/model/primitives.dart';
import 'package:znn_sdk_dart/src/utils/utils.dart';

class FusionEntryList {
  int qsrAmount;
  int count;
  List<FusionEntry> list;

  FusionEntryList.fromJson(Map<String, dynamic> json)
      : qsrAmount = json['qsrAmount'],
        count = json['count'],
        list =
            (json['list'] as List).map((j) => FusionEntry.fromJson(j)).toList();

  Map<String, dynamic> toJson() => {
        'count': count,
        'list': list.map((v) => v.toJson()).toList(),
        'qsrAmount': qsrAmount
      };
}

class FusionEntry {
  int qsrAmount;
  Address beneficiary;
  int expirationHeight;
  Hash id;
  bool? isRevocable;

  FusionEntry(
      {required this.beneficiary,
      required this.expirationHeight,
      required this.id,
      required this.qsrAmount});

  FusionEntry.fromJson(Map<String, dynamic> json)
      : qsrAmount = json['qsrAmount'],
        beneficiary = Address.parse(json['beneficiary']),
        expirationHeight = json['expirationHeight'],
        id = Hash.parse(json['id']);

  Map<String, dynamic> toJson() => {
        'qsrAmount': qsrAmount,
        'beneficiary': beneficiary.toString(),
        'expirationHeight': expirationHeight,
        'id': id.toString()
      };
}

class PlasmaInfo {
  final int currentPlasma;
  final int maxPlasma;
  final int qsrAmount;

  PlasmaInfo(
      {required this.currentPlasma,
      required this.maxPlasma,
      required this.qsrAmount});

  factory PlasmaInfo.fromJson(Map<String, dynamic> json) => PlasmaInfo(
        currentPlasma: json['currentPlasma'],
        maxPlasma: json['maxPlasma'],
        qsrAmount: json['qsrAmount'],
      );
}

class GetRequiredParam {
  Address address;
  int blockType;
  Address? toAddress;

  List<int>? data;

  GetRequiredParam(
      {required this.address,
      required this.blockType,
      this.toAddress,
      required this.data}) {
    if (blockType == BlockTypeEnum.userReceive.index) {
      toAddress = address;
    }
  }

  GetRequiredParam.fromJson(Map<String, dynamic> json)
      : address = Address.parse(json['address']),
        blockType = int.parse(json['blockType']),
        toAddress = Address.parse(json['toAddress']),
        data = BytesUtils.base64ToBytes(json['data']);

  Map<String, dynamic> toJson() => {
        'address': address.toString(),
        'blockType': blockType,
        'toAddress': toAddress == null ? null : toAddress.toString(),
        'data': BytesUtils.bytesToBase64(data!)
      };

  @override
  String toString() {
    return toJson().toString();
  }
}

class GetRequiredResponse {
  int availablePlasma;
  int basePlasma;
  int requiredDifficulty;

  GetRequiredResponse.fromJson(Map<String, dynamic> json)
      : availablePlasma = json['availablePlasma'],
        basePlasma = json['basePlasma'],
        requiredDifficulty = json['requiredDifficulty'];
}
