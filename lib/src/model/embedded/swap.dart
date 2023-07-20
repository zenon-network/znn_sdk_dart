import 'package:znn_sdk_dart/src/model/primitives.dart';

class SwapAssetEntry {
  Hash keyIdHash;
  BigInt qsr;
  BigInt znn;

  SwapAssetEntry(
      {required this.keyIdHash, required this.qsr, required this.znn});

  SwapAssetEntry.fromJson(this.keyIdHash, Map<String, dynamic> json)
      : qsr = BigInt.parse(json['qsr']),
        znn = BigInt.parse(json['znn']);

  Map<String, dynamic> toJson() => {
        'keyIdHash': keyIdHash.toString(),
        'qsr': qsr.toString(),
        'znn': znn.toString()
      };

  bool hasBalance() => qsr > BigInt.zero || znn > BigInt.zero;
}

class SwapLegacyPillarEntry {
  int numPillars;
  Hash keyIdHash;

  SwapLegacyPillarEntry({required this.numPillars, required this.keyIdHash});

  SwapLegacyPillarEntry.fromJson(Map<String, dynamic> json)
      : numPillars = json['numPillars'],
        keyIdHash = Hash.parse(json['keyIdHash']);

  Map<String, dynamic> toJson() =>
      {'numPillars': numPillars, 'keyIdHash': keyIdHash.toString()};
}
