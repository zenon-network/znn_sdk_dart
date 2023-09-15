import 'dart:async';

import 'package:znn_sdk_dart/src/client/client.dart';
import 'package:znn_sdk_dart/src/embedded/embedded.dart';
import 'package:znn_sdk_dart/src/model/model.dart';
import 'package:znn_sdk_dart/src/model/primitives/address.dart';
import 'package:znn_sdk_dart/src/model/primitives/hash.dart';
import 'package:znn_sdk_dart/src/model/primitives/token_standard.dart';

class BridgeApi {
  late Client client;

  void setClient(Client client) {
    this.client = client;
  }

  // Common RPC
  Future<SecurityInfo> getSecurityInfo() async {
    var response = await client.sendRequest('embedded.bridge.getSecurityInfo');
    return SecurityInfo.fromJson(response!);
  }

  Future<TimeChallengesList> getTimeChallengesInfo() async {
    var response =
        await client.sendRequest('embedded.bridge.getTimeChallengesInfo');
    return TimeChallengesList.fromJson(response!);
  }

  // RPC
  Future<BridgeInfo> getBridgeInfo() async {
    var response = await client.sendRequest('embedded.bridge.getBridgeInfo');
    return BridgeInfo.fromJson(response!);
  }

  Future<OrchestratorInfo> getOrchestratorInfo() async {
    var response =
        await client.sendRequest('embedded.bridge.getOrchestratorInfo', []);
    return OrchestratorInfo.fromJson(response!);
  }

  Future<BridgeNetworkInfo> getNetworkInfo(
    int networkClass,
    int chainId,
  ) async {
    var response = await client.sendRequest('embedded.bridge.getNetworkInfo', [
      networkClass,
      chainId,
    ]);
    return BridgeNetworkInfo.fromJson(response!);
  }

  Future<BridgeNetworkInfoList> getAllNetworks(
      {int pageIndex = 0, int pageSize = rpcMaxPageSize}) async {
    var response = await client.sendRequest('embedded.bridge.getAllNetworks', [
      pageIndex,
      rpcMaxPageSize,
    ]);
    return BridgeNetworkInfoList.fromJson(response!);
  }

  Future<WrapTokenRequest> getWrapTokenRequestById(Hash id) async {
    var response = await client.sendRequest(
        'embedded.bridge.getWrapTokenRequestById', [id.toString()]);
    return WrapTokenRequest.fromJson(response!);
  }

  Future<WrapTokenRequestList> getAllWrapTokenRequests(
      {int pageIndex = 0, int pageSize = rpcMaxPageSize}) async {
    var response = await client.sendRequest(
        'embedded.bridge.getAllWrapTokenRequests', [pageIndex, pageSize]);
    return WrapTokenRequestList.fromJson(response!);
  }

  Future<WrapTokenRequestList> getAllWrapTokenRequestsByToAddress(
    String toAddress, {
    int pageIndex = 0,
    int pageSize = rpcMaxPageSize,
  }) async {
    var response = await client
        .sendRequest('embedded.bridge.getAllWrapTokenRequestsByToAddress', [
      toAddress,
      pageIndex,
      pageSize,
    ]);
    return WrapTokenRequestList.fromJson(response!);
  }

  Future<WrapTokenRequestList>
      getAllWrapTokenRequestsByToAddressNetworkClassAndChainId(
    String toAddress,
    int networkClass,
    int chainId, {
    int pageIndex = 0,
    int pageSize = rpcMaxPageSize,
  }) async {
    var response = await client.sendRequest(
        'embedded.bridge.getAllWrapTokenRequestsByToAddressNetworkClassAndChainId',
        [
          toAddress,
          networkClass,
          chainId,
          pageIndex,
          pageSize,
        ]);
    return WrapTokenRequestList.fromJson(response!);
  }

  Future<WrapTokenRequestList> getAllUnsignedWrapTokenRequests(
      {int pageIndex = 0, int pageSize = rpcMaxPageSize}) async {
    var response = await client
        .sendRequest('embedded.bridge.getAllUnsignedWrapTokenRequests', [
      pageIndex,
      pageSize,
    ]);
    return WrapTokenRequestList.fromJson(response!);
  }

  Future<UnwrapTokenRequest> getUnwrapTokenRequestByHashAndLog(
      Hash txHash, int logIndex) async {
    var response = await client
        .sendRequest('embedded.bridge.getUnwrapTokenRequestByHashAndLog', [
      txHash.toString(),
      logIndex,
    ]);
    return UnwrapTokenRequest.fromJson(response!);
  }

  Future<UnwrapTokenRequestList> getAllUnwrapTokenRequests(
      {int pageIndex = 0, int pageSize = rpcMaxPageSize}) async {
    var response =
        await client.sendRequest('embedded.bridge.getAllUnwrapTokenRequests', [
      pageIndex,
      pageSize,
    ]);
    return UnwrapTokenRequestList.fromJson(response!);
  }

  Future<UnwrapTokenRequestList> getAllUnwrapTokenRequestsByToAddress(
      String toAddress,
      {int pageIndex = 0,
      int pageSize = rpcMaxPageSize}) async {
    var response = await client
        .sendRequest('embedded.bridge.getAllUnwrapTokenRequestsByToAddress', [
      toAddress,
      pageIndex,
      pageSize,
    ]);
    return UnwrapTokenRequestList.fromJson(response!);
  }

  Future<ZtsFeesInfo> getFeeTokenPair(TokenStandard zts) async {
    var response = await client
        .sendRequest('embedded.bridge.getFeeTokenPair', [zts.toString()]);
    return ZtsFeesInfo.fromJson(response!);
  }

  // Contract methods
  AccountBlockTemplate wrapToken(
    int networkClass,
    int chainId,
    String toAddress,
    BigInt amount,
    TokenStandard tokenStandard,
  ) {
    return AccountBlockTemplate.callContract(
        bridgeAddress,
        tokenStandard,
        amount,
        Definitions.bridge.encodeFunction('WrapToken', [
          networkClass,
          chainId,
          toAddress,
        ]));
  }

  AccountBlockTemplate updateWrapRequest(Hash id, String signature) {
    return AccountBlockTemplate.callContract(
        bridgeAddress,
        znnZts,
        BigInt.zero,
        Definitions.bridge
            .encodeFunction('UpdateWrapRequest', [id.toString(), signature]));
  }

  AccountBlockTemplate halt(String signature) {
    return AccountBlockTemplate.callContract(bridgeAddress, znnZts, BigInt.zero,
        Definitions.bridge.encodeFunction('Halt', [signature]));
  }

  AccountBlockTemplate changeTssECDSAPubKey(
    String pubKey,
    String oldPubKeySignature,
    String newPubKeySignature,
  ) {
    return AccountBlockTemplate.callContract(
        bridgeAddress,
        znnZts,
        BigInt.zero,
        Definitions.bridge.encodeFunction('ChangeTssECDSAPubKey', [
          pubKey,
          oldPubKeySignature,
          newPubKeySignature,
        ]));
  }

  AccountBlockTemplate redeem(Hash transactionHash, int logIndex) {
    return AccountBlockTemplate.callContract(
        bridgeAddress,
        znnZts,
        BigInt.zero,
        Definitions.bridge
            .encodeFunction('Redeem', [transactionHash.toString(), logIndex]));
  }

  AccountBlockTemplate unwrapToken(
    int networkClass,
    int chainId,
    Hash transactionHash,
    int logIndex,
    Address toAddress,
    String tokenAddress,
    BigInt amount,
    String signature,
  ) {
    return AccountBlockTemplate.callContract(
        bridgeAddress,
        znnZts,
        BigInt.zero,
        Definitions.bridge.encodeFunction('UnwrapToken', [
          networkClass,
          chainId,
          transactionHash.toString(),
          logIndex,
          toAddress.toString(),
          tokenAddress,
          amount,
          signature,
        ]));
  }

  // Guardian contract methods
  AccountBlockTemplate proposeAdministrator(Address address) {
    return AccountBlockTemplate.callContract(
        bridgeAddress,
        znnZts,
        BigInt.zero,
        Definitions.bridge
            .encodeFunction('ProposeAdministrator', [address.toString()]));
  }

  // Administrator contract methods
  AccountBlockTemplate setNetwork(
    int networkClass,
    int chainId,
    String name,
    String contractAddress,
    String metadata,
  ) {
    return AccountBlockTemplate.callContract(
        bridgeAddress,
        znnZts,
        BigInt.zero,
        Definitions.bridge.encodeFunction('SetNetwork', [
          networkClass,
          chainId,
          name,
          contractAddress,
          metadata,
        ]));
  }

  AccountBlockTemplate removeNetwork(int networkClass, int chainId) {
    return AccountBlockTemplate.callContract(
        bridgeAddress,
        znnZts,
        BigInt.zero,
        Definitions.bridge
            .encodeFunction('RemoveNetwork', [networkClass, chainId]));
  }

  AccountBlockTemplate setTokenPair(
    int networkClass,
    int chainId,
    TokenStandard tokenStandard,
    String tokenAddress,
    bool bridgeable,
    bool redeemable,
    bool owned,
    BigInt minAmount,
    int feePercentage,
    int redeemDelay,
    String metadata,
  ) {
    return AccountBlockTemplate.callContract(
        bridgeAddress,
        znnZts,
        BigInt.zero,
        Definitions.bridge.encodeFunction('SetTokenPair', [
          networkClass,
          chainId,
          tokenStandard.toString(),
          tokenAddress,
          bridgeable,
          redeemable,
          owned,
          minAmount.toString(),
          feePercentage,
          redeemDelay,
          metadata,
        ]));
  }

  AccountBlockTemplate setNetworkMetadata(
    int networkClass,
    int chainId,
    String metadata,
  ) {
    return AccountBlockTemplate.callContract(
        bridgeAddress,
        znnZts,
        BigInt.zero,
        Definitions.bridge.encodeFunction('SetNetworkMetadata', [
          networkClass,
          chainId,
          metadata,
        ]));
  }

  AccountBlockTemplate removeTokenPair(
    int networkClass,
    int chainId,
    TokenStandard tokenStandard,
    String tokenAddress,
  ) {
    return AccountBlockTemplate.callContract(
        bridgeAddress,
        znnZts,
        BigInt.zero,
        Definitions.bridge.encodeFunction('RemoveTokenPair', [
          networkClass,
          chainId,
          tokenStandard.toString(),
          tokenAddress,
        ]));
  }

  AccountBlockTemplate unhalt() {
    return AccountBlockTemplate.callContract(bridgeAddress, znnZts, BigInt.zero,
        Definitions.bridge.encodeFunction('Unhalt', []));
  }

  AccountBlockTemplate emergency() {
    return AccountBlockTemplate.callContract(bridgeAddress, znnZts, BigInt.zero,
        Definitions.bridge.encodeFunction('Emergency', []));
  }

  AccountBlockTemplate changeAdministrator(Address administrator) {
    return AccountBlockTemplate.callContract(
        bridgeAddress,
        znnZts,
        BigInt.zero,
        Definitions.bridge
            .encodeFunction('ChangeAdministrator', [administrator.toString()]));
  }

  AccountBlockTemplate setAllowKeyGen(bool allowKeyGen) {
    return AccountBlockTemplate.callContract(bridgeAddress, znnZts, BigInt.zero,
        Definitions.bridge.encodeFunction('SetAllowKeyGen', [allowKeyGen]));
  }

  AccountBlockTemplate setBridgeMetadata(String metadata) {
    return AccountBlockTemplate.callContract(bridgeAddress, znnZts, BigInt.zero,
        Definitions.bridge.encodeFunction('SetBridgeMetadata', [metadata]));
  }

  AccountBlockTemplate revokeUnwrapRequest(Hash transactionHash, int logIndex) {
    return AccountBlockTemplate.callContract(
        bridgeAddress,
        znnZts,
        BigInt.zero,
        Definitions.bridge.encodeFunction(
            'RevokeUnwrapRequest', [transactionHash.toString(), logIndex]));
  }

  AccountBlockTemplate nominateGuardians(List<Address> guardians) {
    return AccountBlockTemplate.callContract(bridgeAddress, znnZts, BigInt.zero,
        Definitions.bridge.encodeFunction('NominateGuardians', [guardians]));
  }

  AccountBlockTemplate setOrchestratorInfo(
    int windowSize,
    int keyGenThreshold,
    int confirmationsToFinality,
    int estimatedMomentumTime,
  ) {
    return AccountBlockTemplate.callContract(
        bridgeAddress,
        znnZts,
        BigInt.zero,
        Definitions.bridge.encodeFunction('SetOrchestratorInfo', [
          windowSize,
          keyGenThreshold,
          confirmationsToFinality,
          estimatedMomentumTime,
        ]));
  }
}
