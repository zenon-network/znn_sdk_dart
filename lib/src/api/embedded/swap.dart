import 'package:znn_sdk_dart/src/embedded/embedded.dart';
import 'package:znn_sdk_dart/src/client/client.dart';
import 'package:znn_sdk_dart/src/model/model.dart';

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
}
