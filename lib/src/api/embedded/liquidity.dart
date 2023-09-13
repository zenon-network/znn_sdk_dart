import 'dart:async';

import 'package:znn_sdk_dart/src/client/client.dart';
import 'package:znn_sdk_dart/src/embedded/embedded.dart';
import 'package:znn_sdk_dart/src/model/model.dart';
import 'package:znn_sdk_dart/src/model/primitives.dart';

class LiquidityApi {
  late Client client;

  void setClient(Client client) {
    this.client = client;
  }

  // Common RPC
  Future<RewardDeposit> getUncollectedReward(Address address) async {
    var response = await client.sendRequest(
        'embedded.liquidity.getUncollectedReward', [address.toString()]);
    return RewardDeposit.fromJson(response!);
  }

  Future<RewardHistoryList> getFrontierRewardByPage(Address address,
      {int pageIndex = 0, int pageSize = rpcMaxPageSize}) async {
    var response = await client.sendRequest(
        'embedded.liquidity.getFrontierRewardByPage',
        [address.toString(), pageIndex, pageSize]);
    return RewardHistoryList.fromJson(response!);
  }

  Future<SecurityInfo> getSecurityInfo() async {
    var response =
        await client.sendRequest('embedded.liquidity.getSecurityInfo');
    return SecurityInfo.fromJson(response!);
  }

  Future<TimeChallengesList> getTimeChallengesInfo() async {
    var response =
        await client.sendRequest('embedded.liquidity.getTimeChallengesInfo');
    return TimeChallengesList.fromJson(response!);
  }

  // RPC
  Future<LiquidityInfo> getLiquidityInfo() async {
    var response =
        await client.sendRequest('embedded.liquidity.getLiquidityInfo');
    return LiquidityInfo.fromJson(response!);
  }

  Future<LiquidityStakeList> getLiquidityStakeEntriesByAddress(Address address,
      {int pageIndex = 0, int pageSize = memoryPoolPageSize}) async {
    var response = await client.sendRequest(
        'embedded.liquidity.getLiquidityStakeEntriesByAddress',
        [address.toString(), pageIndex, pageSize]);
    return LiquidityStakeList.fromJson(response!);
  }

  // Contract methods
  AccountBlockTemplate liquidityStake(
      int durationInSec, BigInt amount, TokenStandard zts) {
    return AccountBlockTemplate.callContract(
        liquidityAddress,
        zts,
        amount,
        Definitions.liquidity
            .encodeFunction('LiquidityStake', [durationInSec]));
  }

  AccountBlockTemplate cancelLiquidityStake(Hash id) {
    return AccountBlockTemplate.callContract(
        liquidityAddress,
        znnZts,
        BigInt.zero,
        Definitions.liquidity
            .encodeFunction('CancelLiquidityStake', [id.toString()]));
  }

  AccountBlockTemplate unlockLiquidityStakeEntries(TokenStandard zts) {
    return AccountBlockTemplate.callContract(
        liquidityAddress,
        zts,
        BigInt.zero,
        Definitions.liquidity
            .encodeFunction('UnlockLiquidityStakeEntries', []));
  }

  // Administrator contract methods
  AccountBlockTemplate setTokenTuple(
      List<String> tokenStandards,
      List<int> znnPercentages,
      List<int> qsrPercentages,
      List<BigInt> minAmounts) {
    return AccountBlockTemplate.callContract(
        liquidityAddress,
        znnZts,
        BigInt.zero,
        Definitions.liquidity.encodeFunction('SetTokenTuple',
            [tokenStandards, znnPercentages, qsrPercentages, minAmounts]));
  }

  AccountBlockTemplate nominateGuardians(List<Address> guardians) {
    return AccountBlockTemplate.callContract(
        liquidityAddress,
        znnZts,
        BigInt.zero,
        Definitions.liquidity.encodeFunction('NominateGuardians', [guardians]));
  }

  AccountBlockTemplate proposeAdministrator(Address address) {
    return AccountBlockTemplate.callContract(
        liquidityAddress,
        znnZts,
        BigInt.zero,
        Definitions.liquidity
            .encodeFunction('ProposeAdministrator', [address.toString()]));
  }

  AccountBlockTemplate setIsHalted(bool isHalted) {
    return AccountBlockTemplate.callContract(
        liquidityAddress,
        znnZts,
        BigInt.zero,
        Definitions.liquidity.encodeFunction('SetIsHalted', [isHalted]));
  }

  AccountBlockTemplate setAdditionalReward(int znnReward, int qsrReward) {
    return AccountBlockTemplate.callContract(
        liquidityAddress,
        znnZts,
        BigInt.zero,
        Definitions.liquidity
            .encodeFunction('SetAdditionalReward', [znnReward, qsrReward]));
  }

  AccountBlockTemplate changeAdministrator(Address administrator) {
    return AccountBlockTemplate.callContract(
        liquidityAddress,
        znnZts,
        BigInt.zero,
        Definitions.liquidity
            .encodeFunction('ChangeAdministrator', [administrator]));
  }

  // Common contract methods
  AccountBlockTemplate collectReward() {
    return AccountBlockTemplate.callContract(liquidityAddress, znnZts,
        BigInt.zero, Definitions.liquidity.encodeFunction('CollectReward', []));
  }

  // Administrator common contract methods
  AccountBlockTemplate emergency() {
    return AccountBlockTemplate.callContract(liquidityAddress, znnZts,
        BigInt.zero, Definitions.liquidity.encodeFunction('Emergency', []));
  }
}
