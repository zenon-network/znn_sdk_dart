import 'dart:async';

import 'package:znn_sdk_dart/src/embedded/embedded.dart';
import 'package:znn_sdk_dart/src/client/client.dart';
import 'package:znn_sdk_dart/src/model/model.dart';

class SentinelApi {
  late Client client;

  void setClient(Client client) {
    this.client = client;
  }

  // RPC
  Future<SentinelInfoList> getAllActive(
      {int pageIndex = 0, int pageSize = rpcMaxPageSize}) async {
    var response = await client
        .sendRequest('embedded.sentinel.getAllActive', [pageIndex, pageSize]);
    return SentinelInfoList.fromJson(response!);
  }

  Future<SentinelInfo?> getByOwner(Address owner) async {
    var response = await client
        .sendRequest('embedded.sentinel.getByOwner', [owner.toString()]);
    return response == null ? response : SentinelInfo.fromJson(response);
  }

  // Common RPC
  Future<int> getDepositedQsr(Address address) async {
    return await client
        .sendRequest('embedded.sentinel.getDepositedQsr', [address.toString()]);
  }

  Future<UncollectedReward> getUncollectedReward(Address address) async {
    var response = await client.sendRequest(
        'embedded.sentinel.getUncollectedReward', [address.toString()]);
    return UncollectedReward.fromJson(response!);
  }

  Future<RewardHistoryList> getFrontierRewardByPage(Address address,
      {int pageIndex = 0, int pageSize = rpcMaxPageSize}) async {
    var response = await client.sendRequest(
        'embedded.sentinel.getFrontierRewardByPage',
        [address.toString(), pageIndex, pageSize]);
    return RewardHistoryList.fromJson(response!);
  }

  // Contract methods
  AccountBlockTemplate register() {
    return AccountBlockTemplate.callContract(
        sentinelAddress,
        znnZts,
        sentinelRegisterZnnAmount,
        Definitions.sentinel.encodeFunction('Register', []));
  }

  AccountBlockTemplate revoke() {
    return AccountBlockTemplate.callContract(sentinelAddress, znnZts, 0,
        Definitions.sentinel.encodeFunction('Revoke', []));
  }

  // Common contract methods
  AccountBlockTemplate collectReward() {
    return AccountBlockTemplate.callContract(sentinelAddress, znnZts, 0,
        Definitions.common.encodeFunction('CollectReward', []));
  }

  AccountBlockTemplate depositQsr(int amount) {
    return AccountBlockTemplate.callContract(sentinelAddress, qsrZts, amount,
        Definitions.common.encodeFunction('DepositQsr', []));
  }

  AccountBlockTemplate withdrawQsr() {
    return AccountBlockTemplate.callContract(sentinelAddress, znnZts, 0,
        Definitions.common.encodeFunction('WithdrawQsr', []));
  }
}
