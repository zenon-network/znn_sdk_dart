import 'dart:async';

import 'package:znn_sdk_dart/src/client/client.dart';
import 'package:znn_sdk_dart/src/model/model.dart';

class SubscribeApi {
  late Client client;

  void setClient(Client client) {
    this.client = client;
  }

  Future<String?> toMomentums() async {
    return await client.sendRequest('ledger.subscribe', ['momentums'])
        as String?;
  }

  Future<String?> toAllAccountEvents() async {
    return await client.sendRequest('ledger.subscribe', ['allAccountBlocks'])
        as String?;
  }

  Future<String?> toAccountEvents(Address address) async {
    return await client.sendRequest(
            'ledger.subscribe', ['accountBlocksByAddress', address.toString()])
        as String?;
  }

  Future<String?> toUnreceivedAccountBlocks(Address address) async {
    return await client.sendRequest('ledger.subscribe',
        ['unreceivedAccountBlocksByAddress', address.toString()]) as String?;
  }
}
