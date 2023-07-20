import 'dart:async';

import 'package:znn_sdk_dart/src/client/client.dart';
import 'package:znn_sdk_dart/src/embedded/embedded.dart';
import 'package:znn_sdk_dart/src/model/model.dart';
import 'package:znn_sdk_dart/src/model/primitives/address.dart';
import 'package:znn_sdk_dart/src/model/primitives/hash.dart';
import 'package:znn_sdk_dart/src/model/primitives/token_standard.dart';

class AcceleratorApi {
  late Client client;

  void setClient(Client client) {
    this.client = client;
  }

  // RPC
  Future<ProjectList> getAll(
      {int pageIndex = 0, int pageSize = rpcMaxPageSize}) async {
    var response = await client
        .sendRequest('embedded.accelerator.getAll', [pageIndex, pageSize]);
    return ProjectList.fromJson(response!);
  }

  Future<Project> getProjectById(String id) async {
    var response =
        await client.sendRequest('embedded.accelerator.getProjectById', [id]);
    return Project.fromJson(response!);
  }

  Future<Phase> getPhaseById(Hash id) async {
    var response =
        await client.sendRequest('embedded.accelerator.getPhaseById', [id]);
    return Phase.fromJson(response!);
  }

  Future<List<PillarVote?>> getPillarVotes(
      String name, List<String> hashes) async {
    var response = await client.sendRequest(
        'embedded.accelerator.getPillarVotes', [name, hashes]) as List;
    return response
        .map((entry) => entry == null ? null : PillarVote.fromJson(entry))
        .toList();
  }

  Future<VoteBreakdown> getVoteBreakdown(Hash id) async {
    var response = await client
        .sendRequest('embedded.accelerator.getVoteBreakdown', [id.toString()]);
    return VoteBreakdown.fromJson(response!);
  }

  // Contract methods
  AccountBlockTemplate createProject(String name, String description,
      String url, BigInt znnFundsNeeded, BigInt qsrFundsNeeded) {
    return AccountBlockTemplate.callContract(
        acceleratorAddress,
        znnZts,
        projectCreationFeeInZnn,
        Definitions.accelerator.encodeFunction('CreateProject',
            [name, description, url, znnFundsNeeded, qsrFundsNeeded]));
  }

  AccountBlockTemplate addPhase(Hash id, String name, String description,
      String url, BigInt znnFundsNeeded, BigInt qsrFundsNeeded) {
    return AccountBlockTemplate.callContract(
        acceleratorAddress,
        znnZts,
        BigInt.zero,
        Definitions.accelerator.encodeFunction('AddPhase', [
          id.getBytes(),
          name,
          description,
          url,
          znnFundsNeeded,
          qsrFundsNeeded
        ]));
  }

  AccountBlockTemplate updatePhase(Hash id, String name, String description,
      String url, BigInt znnFundsNeeded, BigInt qsrFundsNeeded) {
    return AccountBlockTemplate.callContract(
        acceleratorAddress,
        znnZts,
        BigInt.zero,
        Definitions.accelerator.encodeFunction('UpdatePhase', [
          id.getBytes(),
          name,
          description,
          url,
          znnFundsNeeded,
          qsrFundsNeeded
        ]));
  }

  AccountBlockTemplate donate(BigInt amount, TokenStandard zts) {
    return AccountBlockTemplate.callContract(acceleratorAddress, zts, amount,
        Definitions.accelerator.encodeFunction('Donate', []));
  }

  AccountBlockTemplate voteByName(Hash id, String pillarName, int vote) {
    return AccountBlockTemplate.callContract(
        acceleratorAddress,
        znnZts,
        BigInt.zero,
        Definitions.accelerator
            .encodeFunction('VoteByName', [id.getBytes(), pillarName, vote]));
  }

  AccountBlockTemplate voteByProdAddress(Hash id, int vote) {
    return AccountBlockTemplate.callContract(
        acceleratorAddress,
        znnZts,
        BigInt.zero,
        Definitions.accelerator
            .encodeFunction('VoteByProdAddress', [id.getBytes(), vote]));
  }
}
