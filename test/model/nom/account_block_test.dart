import 'dart:convert';
import 'package:test/test.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

void main() async {
  var sendAccountBlockString = '''
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
  "descendantBlocks": [],
  "data": "",
  "fusedPlasma": 21000,
  "difficulty": 0,
  "nonce": "0000000000000000",
  "basePlasma": 21000,
  "usedPlasma": 21000,
  "changesHash": "a31a31bb26f7a7ee5b5c8e83e6b47aeeab6e2330476199d93ee8ca37ac71465a",
  "publicKey": "GYyn77OXTL31zPbDBCe/eKir+VCF3hv+LxiOUF3XcJY=",
  "signature": "hrQwfpdEYTjoLV9yzEppeky2Y/9T1x760vQPL6NLgD+cn0XD1+F/dOcSwyhg8RxjHWMN6MvD2NnTAX7N+5aCBQ==",
  "token": {
    "name": "Zenon Coin",
    "symbol": "ZNN",
    "domain": "zenon.network",
    "totalSupply": "19500000000000",
    "decimals": 8,
    "owner": "z1qxemdeddedxpyllarxxxxxxxxxxxxxxxsy3fmg",
    "tokenStandard": "zts1tfjkummwyppk76twsnv50e",
    "maxSupply": "4611686018427387903",
    "isBurnable": true,
    "isMintable": true,
    "isUtility": true
  },
  "confirmationDetail": {
    "numConfirmations": 2,
    "momentumHeight": 2,
    "momentumHash": "0f92b0be5eef439be78f9d48add78288391d6723e40c7059fae0f1241a9e639f",
    "momentumTimestamp": 1000000010
  },
  "pairedAccountBlock": {
    "version": 1,
    "chainIdentifier": 100,
    "blockType": 3,
    "hash": "158a0a5a7b4d57f4d92e3c068db19125fcc31ff0f059de0df98c920b54a83cd2",
    "previousHash": "57b6b7c6edb82b38ec4c992d99c84bf8016f03bf0727ff9daa811d2e862fa77a",
    "height": 2,
    "momentumAcknowledged": {
      "hash": "0f92b0be5eef439be78f9d48add78288391d6723e40c7059fae0f1241a9e639f",
      "height": 2
    },
    "address": "z1qr4pexnnfaexqqz8nscjjcsajy5hdqfkgadvwx",
    "toAddress": "z1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqsggv2f",
    "amount": "0",
    "tokenStandard": "zts1qqqqqqqqqqqqqqqqtq587y",
    "fromBlockHash": "3835082b4afb76971d58d6ad510e7e91f3bb0d41912fac4ec4cfef7bd7bbea73",
    "descendantBlocks": [],
    "data": "",
    "fusedPlasma": 21000,
    "difficulty": 0,
    "nonce": "0000000000000000",
    "basePlasma": 21000,
    "usedPlasma": 21000,
    "changesHash": "b897ac3a508c060b98f808a343f7f5c33d6b8bf7a50c5c34ceb5f08dd33b581e",
    "publicKey": "tUJu3P7Drp25XP662lIjyFlFpvj8bWUpyC+0y5YTzXM=",
    "signature": "0od6a05O680FGc7bJzVdrAuOCNQLLPwXrLvCy9YfozlYSYGMx7dBbDoQzSUCQYhANghCrkQvNEObNdV8fRMtDQ==",
    "token": null,
    "confirmationDetail": {
      "numConfirmations": 1,
      "momentumHeight": 3,
      "momentumHash": "7dc927d9144e705754a99abe120903fb86eef489a3968f7b724b2df4c0fbb7ef",
      "momentumTimestamp": 1000000020
    },
    "pairedAccountBlock": null
  }
}''';
  var receiveAccountBlockString = '''
{
  "version": 1,
  "chainIdentifier": 100,
  "blockType": 3,
  "hash": "158a0a5a7b4d57f4d92e3c068db19125fcc31ff0f059de0df98c920b54a83cd2",
  "previousHash": "57b6b7c6edb82b38ec4c992d99c84bf8016f03bf0727ff9daa811d2e862fa77a",
  "height": 2,
  "momentumAcknowledged": {
    "hash": "0f92b0be5eef439be78f9d48add78288391d6723e40c7059fae0f1241a9e639f",
    "height": 2
  },
  "address": "z1qr4pexnnfaexqqz8nscjjcsajy5hdqfkgadvwx",
  "toAddress": "z1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqsggv2f",
  "amount": "0",
  "tokenStandard": "zts1qqqqqqqqqqqqqqqqtq587y",
  "fromBlockHash": "3835082b4afb76971d58d6ad510e7e91f3bb0d41912fac4ec4cfef7bd7bbea73",
  "descendantBlocks": [],
  "data": "",
  "fusedPlasma": 21000,
  "difficulty": 0,
  "nonce": "0000000000000000",
  "basePlasma": 21000,
  "usedPlasma": 21000,
  "changesHash": "b897ac3a508c060b98f808a343f7f5c33d6b8bf7a50c5c34ceb5f08dd33b581e",
  "publicKey": "tUJu3P7Drp25XP662lIjyFlFpvj8bWUpyC+0y5YTzXM=",
  "signature": "0od6a05O680FGc7bJzVdrAuOCNQLLPwXrLvCy9YfozlYSYGMx7dBbDoQzSUCQYhANghCrkQvNEObNdV8fRMtDQ==",
  "token": null,
  "confirmationDetail": {
    "numConfirmations": 1,
    "momentumHeight": 3,
    "momentumHash": "7dc927d9144e705754a99abe120903fb86eef489a3968f7b724b2df4c0fbb7ef",
    "momentumTimestamp": 1000000020
  },
  "pairedAccountBlock": {
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
    "descendantBlocks": [],
    "data": "",
    "fusedPlasma": 21000,
    "difficulty": 0,
    "nonce": "0000000000000000",
    "basePlasma": 21000,
    "usedPlasma": 21000,
    "changesHash": "a31a31bb26f7a7ee5b5c8e83e6b47aeeab6e2330476199d93ee8ca37ac71465a",
    "publicKey": "GYyn77OXTL31zPbDBCe/eKir+VCF3hv+LxiOUF3XcJY=",
    "signature": "hrQwfpdEYTjoLV9yzEppeky2Y/9T1x760vQPL6NLgD+cn0XD1+F/dOcSwyhg8RxjHWMN6MvD2NnTAX7N+5aCBQ==",
    "token": {
      "name": "Zenon Coin",
      "symbol": "ZNN",
      "domain": "zenon.network",
      "totalSupply": "19500000000000",
      "decimals": 8,
      "owner": "z1qxemdeddedxpyllarxxxxxxxxxxxxxxxsy3fmg",
      "tokenStandard": "zts1tfjkummwyppk76twsnv50e",
      "maxSupply": "4611686018427387903",
      "isBurnable": true,
      "isMintable": true,
      "isUtility": true
    },
    "confirmationDetail": {
      "numConfirmations": 2,
      "momentumHeight": 2,
      "momentumHash": "0f92b0be5eef439be78f9d48add78288391d6723e40c7059fae0f1241a9e639f",
      "momentumTimestamp": 1000000010
    },
    "pairedAccountBlock": null
  }
}''';

  var sendAccountBlock = AccountBlock.fromJson(jsonDecode(sendAccountBlockString));
  test('same send json', () {
    expect(sendAccountBlock.toJson(), jsonDecode(sendAccountBlockString));
  });
  test('same send hash', () {
    expect(BlockUtils.getTransactionHash(sendAccountBlock).toString(),
        '3835082b4afb76971d58d6ad510e7e91f3bb0d41912fac4ec4cfef7bd7bbea73');
  });

  var receiveAccountBlock = AccountBlock.fromJson(jsonDecode(receiveAccountBlockString));
  test('same receive json', () {
    expect(receiveAccountBlock.toJson(), jsonDecode(receiveAccountBlockString));
  });
  test('same receive hash', () {
    expect(BlockUtils.getTransactionHash(receiveAccountBlock).toString(),
        '158a0a5a7b4d57f4d92e3c068db19125fcc31ff0f059de0df98c920b54a83cd2');
  });
}
