import 'package:znn_sdk_dart/src/client/client.dart';
import 'package:znn_sdk_dart/src/embedded/embedded.dart';
import 'package:znn_sdk_dart/src/model/model.dart';
import 'package:znn_sdk_dart/src/model/primitives/address.dart';
import 'package:znn_sdk_dart/src/model/primitives/hash.dart';
import 'package:znn_sdk_dart/src/model/primitives/token_standard.dart';

class SwapApi {
  late Client client;

  void setClient(Client client) {
    this.client = client;
  }

  // RPC
  Future<SwapAssetEntry> getAssetsByKeyIdHash(String keyIdHash) async {
    var response = await client
        .sendRequest('embedded.swap.getAssetsByKeyIdHash', [keyIdHash]);
    return SwapAssetEntry.fromJson(Hash.parse(keyIdHash), response);
  }

  Future<Map<String, SwapAssetEntry>> getAssets() async {
    var response = await client.sendRequest('embedded.swap.getAssets', []);
    return {
      for (var entry in (response as Map<String, dynamic>).entries)
        entry.key: SwapAssetEntry.fromJson(Hash.parse(entry.key), entry.value)
    };
  }

  Future<List<SwapLegacyPillarEntry>> getLegacyPillars() async {
    var response =
        await client.sendRequest('embedded.swap.getLegacyPillars', []) as List;
    return response
        .map((entry) => SwapLegacyPillarEntry.fromJson(entry))
        .toList();
  }

  // Contract methods
  AccountBlockTemplate retrieveAssets(String pubKey, String signature) {
    return AccountBlockTemplate.callContract(swapAddress, znnZts, 0,
        Definitions.swap.encodeFunction('RetrieveAssets', [pubKey, signature]));
  }

  int getSwapDecayPercentage(int currentTimestamp) {
    var percentageToGive = 100;
    var currentEpoch =
        (currentTimestamp - genesisTimestamp) / Duration.secondsPerDay;
    if (currentTimestamp < swapAssetDecayTimestampStart) {
      percentageToGive = 100;
    } else {
      var numTicks = ((currentEpoch - swapAssetDecayEpochsOffset + 1) ~/
          swapAssetDecayTickEpochs);
      var decayFactor = swapAssetDecayTickValuePercentage * numTicks;
      if (decayFactor > 100) {
        percentageToGive = 0;
      } else {
        percentageToGive = 100 - decayFactor;
      }
    }
    return 100 - percentageToGive;
  }
}
