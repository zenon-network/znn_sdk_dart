import 'dart:async';

import 'package:znn_sdk_dart/src/client/client.dart';
import 'package:znn_sdk_dart/src/embedded/embedded.dart';
import 'package:znn_sdk_dart/src/model/model.dart';
import 'package:znn_sdk_dart/src/model/primitives/address.dart';
import 'package:znn_sdk_dart/src/model/primitives/hash.dart';
import 'package:znn_sdk_dart/src/model/primitives/token_standard.dart';

class StakeApi {
  late Client client;

  void setClient(Client client) {
    this.client = client;
  }

  // RPC
  Future<StakeList> getEntriesByAddress(Address address,
      {int pageIndex = 0, int pageSize = rpcMaxPageSize}) async {
    var response = await client.sendRequest(
        'embedded.stake.getEntriesByAddress',
        [address.toString(), pageIndex, pageSize]);
    return StakeList.fromJson(response!);
  }

  // Common RPC
  Future<UncollectedReward> getUncollectedReward(Address address) async {
    var response = await client.sendRequest(
        'embedded.stake.getUncollectedReward', [address.toString()]);
    return UncollectedReward.fromJson(response!);
  }

  Future<RewardHistoryList> getFrontierRewardByPage(Address address,
      {int pageIndex = 0, int pageSize = rpcMaxPageSize}) async {
    var response = await client.sendRequest(
        'embedded.stake.getFrontierRewardByPage',
        [address.toString(), pageIndex, pageSize]);
    return RewardHistoryList.fromJson(response!);
  }

  // Contract methods
  AccountBlockTemplate stake(int durationInSec, BigInt amount) {
    return AccountBlockTemplate.callContract(
        client.protocolVersion,
        client.chainIdentifier,
        stakeAddress, znnZts, amount,
        Definitions.stake.encodeFunction('Stake', [durationInSec.toString()]));
  }

  AccountBlockTemplate cancel(Hash id) {
    return AccountBlockTemplate.callContract(
        client.protocolVersion,
        client.chainIdentifier,
        stakeAddress, znnZts, BigInt.zero,
        Definitions.stake.encodeFunction('Cancel', [id.getBytes()]));
  }

  // Common contract methods
  AccountBlockTemplate collectReward() {
    return AccountBlockTemplate.callContract(
        client.protocolVersion,
        client.chainIdentifier,
        stakeAddress, znnZts, BigInt.zero,
        Definitions.common.encodeFunction('CollectReward', []));
  }
}
