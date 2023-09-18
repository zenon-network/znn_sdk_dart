import 'dart:async';
import 'package:znn_sdk_dart/src/client/client.dart';
import 'package:znn_sdk_dart/src/embedded/embedded.dart';
import 'package:znn_sdk_dart/src/model/model.dart';
import 'package:znn_sdk_dart/src/model/primitives.dart';

class SporkApi {
  late Client client;

  void setClient(Client client) {
    this.client = client;
  }

  // RPC
  Future<SporkList> getAll(
      {int pageIndex = 0, int pageSize = rpcMaxPageSize}) async {
    var response = await client
        .sendRequest('embedded.spork.getAll', [pageIndex, pageSize]);
    return SporkList.fromJson(response!);
  }

  // Contract methods
  AccountBlockTemplate createSpork(String name, String description) {
    return AccountBlockTemplate.callContract(sporkAddress, znnZts, BigInt.zero,
        Definitions.spork.encodeFunction('CreateSpork', [name, description]));
  }

  AccountBlockTemplate activateSpork(Hash id) {
    return AccountBlockTemplate.callContract(sporkAddress, znnZts, BigInt.zero,
        Definitions.spork.encodeFunction('ActivateSpork', [id.getBytes()]));
  }
}
