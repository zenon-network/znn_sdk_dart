import 'dart:async';

import 'package:znn_sdk_dart/src/client/client.dart';
import 'package:znn_sdk_dart/src/embedded/embedded.dart';
import 'package:znn_sdk_dart/src/model/model.dart';
import 'package:znn_sdk_dart/src/model/primitives/address.dart';
import 'package:znn_sdk_dart/src/model/primitives/token_standard.dart';

class TokenApi {
  late Client client;

  void setClient(Client client) {
    this.client = client;
  }

  // RPC
  Future<TokenList> getAll(
      {int pageIndex = 0, int pageSize = rpcMaxPageSize}) async {
    var response = await client
        .sendRequest('embedded.token.getAll', [pageIndex, pageSize]);
    return TokenList.fromJson(response!);
  }

  Future<TokenList> getByOwner(Address address,
      {int pageIndex = 0, int pageSize = rpcMaxPageSize}) async {
    var response = await client.sendRequest(
        'embedded.token.getByOwner', [address.toString(), pageIndex, pageSize]);
    return TokenList.fromJson(response!);
  }

  Future<Token?> getByZts(TokenStandard tokenStandard) async {
    var response = await client
        .sendRequest('embedded.token.getByZts', [tokenStandard.toString()]);
    return response == null ? null : Token.fromJson(response);
  }

  // Contract methods
  AccountBlockTemplate issueToken(
      String tokenName,
      String tokenSymbol,
      String tokenDomain,
      BigInt totalSupply,
      BigInt maxSupply,
      int decimals,
      bool mintable,
      bool burnable,
      bool utility) {
    return AccountBlockTemplate.callContract(
        client.protocolVersion,
        client.chainIdentifier,
        tokenAddress,
        znnZts,
        tokenZtsIssueFeeInZnn,
        Definitions.token.encodeFunction('IssueToken', [
          tokenName,
          tokenSymbol,
          tokenDomain,
          totalSupply,
          maxSupply,
          decimals,
          mintable,
          burnable,
          utility
        ]));
  }

  AccountBlockTemplate mintToken(
      TokenStandard tokenStandard, BigInt amount, Address receiveAddress) {
    return AccountBlockTemplate.callContract(
        client.protocolVersion,
        client.chainIdentifier,
        tokenAddress,
        znnZts,
        BigInt.zero,
        Definitions.token
            .encodeFunction('Mint', [tokenStandard, amount, receiveAddress]));
  }

  AccountBlockTemplate burnToken(TokenStandard tokenStandard, BigInt amount) {
    return AccountBlockTemplate.callContract(
        client.protocolVersion,
        client.chainIdentifier,
        tokenAddress, tokenStandard,
        amount, Definitions.token.encodeFunction('Burn', []));
  }

  AccountBlockTemplate updateToken(TokenStandard tokenStandard, Address owner,
      bool isMintable, bool isBurnable) {
    return AccountBlockTemplate.callContract(
        client.protocolVersion,
        client.chainIdentifier,
        tokenAddress,
        znnZts,
        BigInt.zero,
        Definitions.token.encodeFunction(
            'UpdateToken', [tokenStandard, owner, isMintable, isBurnable]));
  }
}
