import 'dart:convert';
import 'package:test/test.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

void main() async {
  var accountBlockTemplateString = '''
{
  "version": 1,
  "chainIdentifier": 100,
  "blockType": 2,
  "hash": "3835082b4afb76971d58d6ad510e7e91f3bb0d41912fac4ec4cfef7bd7bbea73",
  "previousHash": "598fa623dd308bec7163bb375aa7546ec4aced3b71a1c9278709903e69280dbd",
  "height": 2,
  "momentumAcknowledged": {
    "hash": "c37c70550e95d0c72f0924d480321976040108f29fa7530487f8dde81e713689",
    "height": 1
  },
  "address": "z1qzal6c5s9rjnnxd2z7dvdhjxpmmj4fmw56a0mz",
  "toAddress": "z1qr4pexnnfaexqqz8nscjjcsajy5hdqfkgadvwx",
  "amount": "10000000000",
  "tokenStandard": "zts1tfjkummwyppk76twsnv50e",
  "fromBlockHash": "0000000000000000000000000000000000000000000000000000000000000000",
  "data": "",
  "fusedPlasma": 21000,
  "difficulty": 0,
  "nonce": "0000000000000000",
  "publicKey": "GYyn77OXTL31zPbDBCe/eKir+VCF3hv+LxiOUF3XcJY=",
  "signature": "hrQwfpdEYTjoLV9yzEppeky2Y/9T1x760vQPL6NLgD+cn0XD1+F/dOcSwyhg8RxjHWMN6MvD2NnTAX7N+5aCBQ=="
}''';
  var accountBlockTemplate =
      AccountBlockTemplate.fromJson(jsonDecode(accountBlockTemplateString));

  test('same json', () {
    expect(
        accountBlockTemplate.toJson(), jsonDecode(accountBlockTemplateString));
  });
  test('same hash', () {
    expect(BlockUtils.getTransactionHash(accountBlockTemplate).toString(),
        '3835082b4afb76971d58d6ad510e7e91f3bb0d41912fac4ec4cfef7bd7bbea73');
  });
}
