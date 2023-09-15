import 'package:znn_sdk_dart/src/model/primitives.dart';
import 'package:znn_sdk_dart/src/utils/utils.dart';

enum BlockTypeEnum {
  unknown,
  genesisReceive,
  userSend,
  userReceive,
  contractSend,
  contractReceive
}

extension BlockTypeEnumExtension on BlockTypeEnum {
  int compareTo(BlockTypeEnum blockTypeEnum) =>
      toString().compareTo(blockTypeEnum.toString());
}

class AccountBlockTemplate {
  int protocolVersion;
  int chainIdentifier;
  int blockType;

  Hash hash;
  Hash previousHash;
  int height;
  HashHeight momentumAcknowledged;

  Address address;

  // Send information
  Address toAddress;

  BigInt amount;
  TokenStandard tokenStandard;

  // Receive information
  late Hash fromBlockHash;

  List<int> data;

  // PoW
  int fusedPlasma;
  int difficulty;

  // Hex representation of 8 byte nonce
  String nonce;

  // Verification
  List<int> publicKey;
  List<int> signature;

  AccountBlockTemplate(
      {required this.protocolVersion, 
      required this.chainIdentifier,
      required this.blockType,
      toAddress,
      amount,
      tokenStandard,
      fromBlockHash,
      data})
      : hash = emptyHash,
        previousHash = emptyHash,
        height = 0,
        momentumAcknowledged = emptyHashHeight,
        address = emptyAddress,
        toAddress = toAddress ?? emptyAddress,
        amount = amount ?? BigInt.zero,
        tokenStandard =
            tokenStandard ?? TokenStandard.parse(emptyTokenStandard),
        fromBlockHash = fromBlockHash ?? emptyHash,
        data = data ?? [],
        fusedPlasma = 0,
        difficulty = 0,
        nonce = '',
        publicKey = [],
        signature = [];

  factory AccountBlockTemplate.receive(
    int protocolVersion, 
    int chainIdentifier, 
    Hash fromBlockHash) =>
      AccountBlockTemplate(
          protocolVersion: protocolVersion,
          chainIdentifier: chainIdentifier,
          blockType: BlockTypeEnum.userReceive.index,
          fromBlockHash: fromBlockHash);

  factory AccountBlockTemplate.send(
    int protocolVersion, 
    int chainIdentifier, 
    Address toAddress,
    TokenStandard tokenStandard,
    BigInt amount, [
    List<int>? data,
  ]) =>
      AccountBlockTemplate(
        protocolVersion: protocolVersion,
        chainIdentifier: chainIdentifier,
        blockType: BlockTypeEnum.userSend.index,
        toAddress: toAddress,
        tokenStandard: tokenStandard,
        amount: amount,
        data: data,
      );

  factory AccountBlockTemplate.callContract(
    int protocolVersion, 
    int chainIdentifier, 
    Address toAddress,
    TokenStandard tokenStandard, 
    BigInt amount, 
    List<int> data) =>
      AccountBlockTemplate(
        protocolVersion: protocolVersion,
        chainIdentifier: chainIdentifier,
        blockType: BlockTypeEnum.userSend.index,
        toAddress: toAddress,
        tokenStandard: tokenStandard,
        amount: amount,
        data: data);

  AccountBlockTemplate.fromJson(Map<String, dynamic> json)
      : protocolVersion = json['version'],
        blockType = json['blockType'],
        fromBlockHash = Hash.parse(json['fromBlockHash']),
        chainIdentifier = json['chainIdentifier'],
        hash = Hash.parse(json['hash']),
        previousHash = Hash.parse(json['previousHash']),
        height = json['height'],
        momentumAcknowledged =
            HashHeight.fromJson(json['momentumAcknowledged']),
        address = Address.parse(json['address']),
        toAddress = Address.parse(json['toAddress']),
        amount = BigInt.parse(json['amount']),
        tokenStandard = TokenStandard.parse(json['tokenStandard']),
        fusedPlasma = json["fusedPlasma"],
        data = (json['data'] == null
            ? []
            : json['data'] == ''
                ? []
                : BytesUtils.base64ToBytes(json['data'])!),
        difficulty = json['difficulty'],
        nonce = json['nonce'],
        publicKey = (json['publicKey'] != null && json['publicKey'].isNotEmpty
            ? BytesUtils.base64ToBytes(json['publicKey'])
            : [])!,
        signature = (json['signature'] != null && json['signature'].isNotEmpty
            ? BytesUtils.base64ToBytes(json['signature'])
            : [])!;

  Map<String, dynamic> toJson() {
    final j = <String, dynamic>{};

    j['version'] = protocolVersion;
    j['chainIdentifier'] = chainIdentifier;
    j['blockType'] = blockType;
    j['hash'] = hash.toString();
    j['previousHash'] = previousHash.toString();
    j['height'] = height;
    j['momentumAcknowledged'] = momentumAcknowledged.toJson();
    j['address'] = address.toString();
    j['toAddress'] = toAddress.toString();
    j['amount'] = amount.toString();
    j['tokenStandard'] = tokenStandard.toString();
    j['fromBlockHash'] = fromBlockHash.toString();
    j['data'] = BytesUtils.bytesToBase64(data);
    j['fusedPlasma'] = fusedPlasma;
    j['difficulty'] = difficulty;
    j['nonce'] = nonce;
    j['publicKey'] = BytesUtils.bytesToBase64(publicKey);
    j['signature'] = BytesUtils.bytesToBase64(signature);
    return j;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
