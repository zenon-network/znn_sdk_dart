import 'dart:async';

import 'package:znn_sdk_dart/src/client/client.dart';
import 'package:znn_sdk_dart/src/model/primitives/address.dart';

class SubscribeApi {
  late Client client;

  void setClient(Client client) {
    this.client = client;
  }

  Future<String?> toMomentums() async {
    return await client.sendRequest('ledger.subscribe', ['momentums'])
        as String?;
  }

  Future<String?> toAllAccountBlocks() async {
    return await client.sendRequest('ledger.subscribe', ['allAccountBlocks'])
        as String?;
  }

  Future<String?> toAccountBlocksByAddress(Address address) async {
    return await client.sendRequest(
            'ledger.subscribe', ['accountBlocksByAddress', address.toString()])
        as String?;
  }

  Future<String?> toUnreceivedAccountBlocksByAddress(Address address) async {
    return await client.sendRequest('ledger.subscribe',
        ['unreceivedAccountBlocksByAddress', address.toString()]) as String?;
  }
}
