import 'package:znn_sdk_dart/src/client/client.dart';
import 'package:znn_sdk_dart/src/embedded/embedded.dart';
import 'package:znn_sdk_dart/src/model/model.dart';
import 'package:znn_sdk_dart/src/model/primitives/address.dart';
import 'package:znn_sdk_dart/src/model/primitives/hash.dart';
import 'package:znn_sdk_dart/src/model/primitives/token_standard.dart';

class PlasmaApi {
  late Client client;

  void setClient(Client client) {
    this.client = client;
  }

  // RPC
  Future<PlasmaInfo> get(Address address) async {
    var response =
        await client.sendRequest('embedded.plasma.get', [address.toString()]);
    return PlasmaInfo.fromJson(response!);
  }

  Future<FusionEntryList> getEntriesByAddress(Address address,
      {int pageIndex = 0, int pageSize = rpcMaxPageSize}) async {
    var response = await client.sendRequest(
        'embedded.plasma.getEntriesByAddress',
        [address.toString(), pageIndex, pageSize]);
    return FusionEntryList.fromJson(response!);
  }

  Future<int> getRequiredFusionAmount(int requiredPlasma) async {
    return await client.sendRequest(
        'embedded.plasma.getRequiredFusionAmount', [requiredPlasma]);
  }

  BigInt getPlasmaByQsr(BigInt qsrAmount) {
    return qsrAmount * BigInt.from(2100);
  }

  Future<GetRequiredResponse> getRequiredPoWForAccountBlock(
      GetRequiredParam powParam) async {
    var response = await client.sendRequest(
        'embedded.plasma.getRequiredPoWForAccountBlock', [powParam.toJson()]);
    return GetRequiredResponse.fromJson(response);
  }

  // Contract methods
  AccountBlockTemplate fuse(Address beneficiary, BigInt amount) {
    return AccountBlockTemplate.callContract(
        client.protocolVersion,
        client.chainIdentifier,
        plasmaAddress, qsrZts, amount,
        Definitions.plasma.encodeFunction('Fuse', [beneficiary]));
  }

  AccountBlockTemplate cancel(Hash id) {
    return AccountBlockTemplate.callContract(
        client.protocolVersion,
        client.chainIdentifier,
        plasmaAddress, znnZts, BigInt.zero,
        Definitions.plasma.encodeFunction('CancelFuse', [id.getBytes()]));
  }
}
