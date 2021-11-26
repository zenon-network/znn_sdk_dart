import 'dart:async';

import 'package:znn_sdk_dart/src/embedded/embedded.dart';
import 'package:znn_sdk_dart/src/client/client.dart';
import 'package:znn_sdk_dart/src/model/model.dart';

class PillarApi {
  late Client client;

  void setClient(Client client) {
    this.client = client;
  }

  // Common RPC
  Future<int> getDepositedQsr(Address address) async {
    return await client
        .sendRequest('embedded.pillar.getDepositedQsr', [address.toString()]);
  }

  Future<UncollectedReward> getUncollectedReward(Address address) async {
    var response = await client.sendRequest(
        'embedded.pillar.getUncollectedReward', [address.toString()]);
    return UncollectedReward.fromJson(response!);
  }

  Future<RewardHistoryList> getFrontierRewardByPage(Address address,
      {int pageIndex = 0, int pageSize = rpcMaxPageSize}) async {
    var response = await client.sendRequest(
        'embedded.pillar.getFrontierRewardByPage',
        [address.toString(), pageIndex, pageSize]);
    return RewardHistoryList.fromJson(response!);
  }

  // RPC
  Future<int> getQsrRegistrationCost() async {
    return await client
        .sendRequest('embedded.pillar.getQsrRegistrationCost', []);
  }

  Future<PillarInfoList> getAll(
      {int pageIndex = 0, int pageSize = rpcMaxPageSize}) async {
    var response = await client
        .sendRequest('embedded.pillar.getAll', [pageIndex, pageSize]);
    return PillarInfoList.fromJson(response!);
  }

  Future<List<PillarInfo>> getByOwner(Address address) async {
    var response = await client.sendRequest(
        'embedded.pillar.getByOwner', [address.toString()]) as List;
    return response.map((entry) => PillarInfo.fromJson(entry)).toList();
  }

  Future<PillarInfo?> getByName(String name) async {
    var response =
        await client.sendRequest('embedded.pillar.getByName', [name]);
    return response == null ? null : PillarInfo.fromJson(response);
  }

  Future<bool> checkNameAvailability(String name) async {
    return await client
        .sendRequest('embedded.pillar.checkNameAvailability', [name]);
  }

  Future<DelegationInfo?> getDelegatedPillar(Address address) async {
    var response = await client.sendRequest(
        'embedded.pillar.getDelegatedPillar', [address.toString()]);
    return response == null ? null : DelegationInfo.fromJson(response);
  }

  Future<PillarEpochHistoryList> getPillarEpochHistory(String name,
      {int pageIndex = 0, int pageSize = rpcMaxPageSize}) async {
    var response = await client.sendRequest(
        'embedded.pillar.getPillarEpochHistory', [name, pageIndex, pageSize]);
    return PillarEpochHistoryList.fromJson(response!);
  }

  Future<PillarEpochHistoryList> getPillarsHistoryByEpoch(int epoch,
      {int pageIndex = 0, int pageSize = rpcMaxPageSize}) async {
    var response = await client.sendRequest(
        'embedded.pillar.getPillarsHistoryByEpoch',
        [epoch, pageIndex, pageSize]);
    return PillarEpochHistoryList.fromJson(response!);
  }

  // Contract methods
  AccountBlockTemplate register(
      String name, Address producerAddress, Address rewardAddress,
      [int giveBlockRewardPercentage = 0,
      int giveDelegateRewardPercentage = 100]) {
    return AccountBlockTemplate.callContract(
        pillarAddress,
        znnZts,
        pillarRegisterZnnAmount,
        Definitions.pillar.encodeFunction('Register', [
          name,
          producerAddress,
          rewardAddress,
          giveBlockRewardPercentage,
          giveDelegateRewardPercentage
        ]));
  }

  AccountBlockTemplate registerLegacy(String name, Address producerAddress,
      Address rewardAddress, String publicKey, String signature,
      [int giveBlockRewardPercentage = 0,
      int giveDelegateRewardPercentage = 100]) {
    return AccountBlockTemplate.callContract(
        pillarAddress,
        znnZts,
        pillarRegisterZnnAmount,
        Definitions.pillar.encodeFunction('RegisterLegacy', [
          name,
          producerAddress,
          rewardAddress,
          giveBlockRewardPercentage,
          giveDelegateRewardPercentage,
          publicKey,
          signature
        ]));
  }

  AccountBlockTemplate updatePillar(
      String name,
      Address producerAddress,
      Address rewardAddress,
      int giveBlockRewardPercentage,
      int giveDelegateRewardPercentage) {
    return AccountBlockTemplate.callContract(
        pillarAddress,
        znnZts,
        0,
        Definitions.pillar.encodeFunction('UpdatePillar', [
          name,
          producerAddress,
          rewardAddress,
          giveBlockRewardPercentage,
          giveDelegateRewardPercentage
        ]));
  }

  AccountBlockTemplate revoke(String name) {
    return AccountBlockTemplate.callContract(pillarAddress, znnZts, 0,
        Definitions.pillar.encodeFunction('Revoke', [name]));
  }

  AccountBlockTemplate delegate(String name) {
    return AccountBlockTemplate.callContract(pillarAddress, znnZts, 0,
        Definitions.pillar.encodeFunction('Delegate', [name]));
  }

  AccountBlockTemplate undelegate() {
    return AccountBlockTemplate.callContract(pillarAddress, znnZts, 0,
        Definitions.pillar.encodeFunction('Undelegate', []));
  }

  // Common contract methods
  AccountBlockTemplate collectReward() {
    return AccountBlockTemplate.callContract(pillarAddress, znnZts, 0,
        Definitions.common.encodeFunction('CollectReward', []));
  }

  AccountBlockTemplate depositQsr(int amount) {
    return AccountBlockTemplate.callContract(pillarAddress, qsrZts, amount,
        Definitions.common.encodeFunction('DepositQsr', []));
  }

  AccountBlockTemplate withdrawQsr() {
    return AccountBlockTemplate.callContract(pillarAddress, znnZts, 0,
        Definitions.common.encodeFunction('WithdrawQsr', []));
  }
}
