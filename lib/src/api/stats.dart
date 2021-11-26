import 'dart:async';

import 'package:znn_sdk_dart/src/client/client.dart';
import 'package:znn_sdk_dart/src/model/model.dart';

class StatsApi {
  late Client client;

  void setClient(Client client) {
    this.client = client;
  }

  Future<OsInfo> osInfo() async {
    var response = await client.sendRequest('stats.osInfo', []);
    return OsInfo.fromJson(response);
  }

  Future<ProcessInfo> processInfo() async {
    var response = await client.sendRequest('stats.processInfo', []);
    return ProcessInfo.fromJson(response);
  }

  Future<NetworkInfo> networkInfo() async {
    var response = await client.sendRequest('stats.networkInfo', []);
    return NetworkInfo.fromJson(response);
  }
}
