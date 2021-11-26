import 'dart:async';

import 'package:znn_sdk_dart/src/embedded/embedded.dart';
import 'package:znn_sdk_dart/src/client/client.dart';
import 'package:znn_sdk_dart/src/model/model.dart';
import 'package:znn_sdk_dart/src/utils/utils.dart';

class AcceleratorApi {
  late Client client;

  void setClient(Client client) {
    this.client = client;
  }

  // RPC
  Future<ProjectList> getAll({int pageIndex = 0, int pageSize = rpcMaxPageSize}) async {
    var response = await client.sendRequest('embedded.accelerator.getAll', [pageIndex, pageSize]);
    return ProjectList.fromJson(response!);
  }

  Future<List<Project>> getByOwner(Address address) async {
    var response = await client.sendRequest('embedded.accelerator.getByOwner', [address.toString()]) as List;
    return response.map((entry) => Project.fromJson(entry)).toList();
  }

  Future<List<PillarVote?>> getPillarVotes(String name, List<String> hashes) async {
    var response = await client.sendRequest('embedded.accelerator.getPillarVotes', [name, hashes]) as List;
    return response.map((entry) => entry == null ? null : PillarVote.fromJson(entry)).toList();
  }

  Future<PillarVoteList> getVoteBreakdown(Hash? id, {int pageIndex = 0, int pageSize = rpcMaxPageSize}) async {
    var response = await client.sendRequest('embedded.accelerator.getVoteBreakdown', [id.toString(), pageIndex, pageSize]);
    return PillarVoteList.fromJson(response!);
  }

  // Contract methods
  AccountBlockTemplate createProposal(String name, String description, String url, int fundsNeeded) {
    return AccountBlockTemplate.callContract(
        acceleratorAddress,
        znnZts,
        AmountUtils.extractDecimals(proposalCreationCostInZnn.toDouble(), znnDecimals),
        Definitions.accelerator.encodeFunction('CreateProject', [name, description, url, fundsNeeded]));
  }

  AccountBlockTemplate addPhase(Hash id, String name, String description, String url, int fundsNeeded) {
    return AccountBlockTemplate.callContract(acceleratorAddress, znnZts, 0,
        Definitions.accelerator.encodeFunction('AddPhase', [id.getBytes(), name, description, url, fundsNeeded]));
  }

  AccountBlockTemplate updatePhase(Hash id, String name, String description, String url, int fundsNeeded) {
    return AccountBlockTemplate.callContract(acceleratorAddress, znnZts, 0,
        Definitions.accelerator.encodeFunction('UpdatePhase', [id.getBytes(), name, description, url, fundsNeeded]));
  }

  AccountBlockTemplate donate(int amount) {
    return AccountBlockTemplate.callContract(
        acceleratorAddress, znnZts, amount, Definitions.accelerator.encodeFunction('Donate', []));
  }

  AccountBlockTemplate updateProjects() {
    return AccountBlockTemplate.callContract(
        acceleratorAddress, znnZts, 0, Definitions.accelerator.encodeFunction('UpdateProjects', []));
  }

  AccountBlockTemplate voteByName(Hash id, String pillarName, int vote) {
    return AccountBlockTemplate.callContract(acceleratorAddress, znnZts, 0,
        Definitions.accelerator.encodeFunction('VoteByName', [id.getBytes(), pillarName, vote]));
  }

  AccountBlockTemplate voteByProdAddress(Hash id, int vote) {
    return AccountBlockTemplate.callContract(acceleratorAddress, znnZts, 0,
        Definitions.accelerator.encodeFunction('VoteByProdAddress', [id.getBytes(), vote]));
  }
}
