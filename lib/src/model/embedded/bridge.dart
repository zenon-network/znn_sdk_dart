import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class BridgeInfo {
  Address administrator;
  String compressedTssECDSAPubKey;
  String decompressedTssECDSAPubKey;
  bool allowKeyGen;
  bool halted;
  int unhaltedAt;
  int unhaltDurationInMomentums;
  int tssNonce;
  String metadata;

  BridgeInfo({
    required this.administrator,
    required this.compressedTssECDSAPubKey,
    required this.decompressedTssECDSAPubKey,
    required this.allowKeyGen,
    required this.halted,
    required this.unhaltedAt,
    required this.unhaltDurationInMomentums,
    required this.tssNonce,
    required this.metadata,
  });

  BridgeInfo.fromJson(Map<String, dynamic> json)
      : administrator = Address.parse(json['administrator']),
        compressedTssECDSAPubKey = json['compressedTssECDSAPubKey'],
        decompressedTssECDSAPubKey = json['decompressedTssECDSAPubKey'],
        allowKeyGen = json['allowKeyGen'],
        halted = json['halted'],
        unhaltedAt = json['unhaltedAt'],
        unhaltDurationInMomentums = json['unhaltDurationInMomentums'],
        tssNonce = json['tssNonce'],
        metadata = json['metadata'];

  Map<String, dynamic> toJson() => {
        'administrator': administrator.toString(),
        'compressedTssECDSAPubKey': compressedTssECDSAPubKey,
        'decompressedTssECDSAPubKey': decompressedTssECDSAPubKey,
        'allowKeyGen': allowKeyGen,
        'halted': halted,
        'unhaltedAt': unhaltedAt,
        'unhaltDurationInMomentums': unhaltDurationInMomentums,
        'tssNonce': tssNonce,
        'metadata': metadata,
      };
}

class OrchestratorInfo {
  int windowSize;
  int keyGenThreshold;
  int confirmationsToFinality;
  int estimatedMomentumTime;
  int allowKeyGenHeight;

  OrchestratorInfo({
    required this.windowSize,
    required this.keyGenThreshold,
    required this.confirmationsToFinality,
    required this.estimatedMomentumTime,
    required this.allowKeyGenHeight,
  });

  OrchestratorInfo.fromJson(Map<String, dynamic> json)
      : windowSize = json['windowSize'],
        keyGenThreshold = json['keyGenThreshold'],
        confirmationsToFinality = json['confirmationsToFinality'],
        estimatedMomentumTime = json['estimatedMomentumTime'],
        allowKeyGenHeight = json['allowKeyGenHeight'];

  Map<String, dynamic> toJson() => {
        'windowSize': windowSize,
        'keyGenThreshold': keyGenThreshold,
        'confirmationsToFinality': confirmationsToFinality,
        'estimatedMomentumTime': estimatedMomentumTime,
        'allowKeyGenHeight': allowKeyGenHeight,
      };
}

class TokenPair {
  TokenStandard tokenStandard;
  String tokenAddress;
  bool bridgeable;
  bool redeemable;
  bool owned;
  BigInt minAmount;
  int feePercentage;
  int redeemDelay;
  String metadata;

  TokenPair({
    required this.tokenStandard,
    required this.tokenAddress,
    required this.bridgeable,
    required this.redeemable,
    required this.owned,
    required this.minAmount,
    required this.feePercentage,
    required this.redeemDelay,
    required this.metadata,
  });

  TokenPair.fromJson(Map<String, dynamic> json)
      : tokenStandard = TokenStandard.parse(json['tokenStandard']),
        tokenAddress = json['tokenAddress'],
        bridgeable = json['bridgeable'],
        redeemable = json['redeemable'],
        owned = json['owned'],
        minAmount = BigInt.parse(json['minAmount']),
        feePercentage = json['feePercentage'],
        redeemDelay = json['redeemDelay'],
        metadata = json['metadata'];

  Map<String, dynamic> toJson() => {
        'tokenStandard': tokenStandard.toString(),
        'tokenAddress': tokenAddress,
        'bridgeable': bridgeable,
        'redeemable': redeemable,
        'owned': owned,
        'minAmount': minAmount.toString(),
        'feePercentage': feePercentage,
        'redeemDelay': redeemDelay,
        'metadata': metadata,
      };
}

class BridgeNetworkInfo {
  int networkClass;
  int chainId;
  String name;
  String contractAddress;
  String metadata;
  List<TokenPair> tokenPairs;

  BridgeNetworkInfo({
    required this.networkClass,
    required this.chainId,
    required this.name,
    required this.contractAddress,
    required this.metadata,
    required this.tokenPairs,
  });

  BridgeNetworkInfo.fromJson(Map<String, dynamic> json)
      : networkClass = json['networkClass'],
        chainId = json['chainId'],
        name = json['name'],
        contractAddress = json['contractAddress'],
        metadata = json['metadata'],
        tokenPairs = json['tokenPairs'] != null
            ? (json['tokenPairs'] as List)
                .map((entry) => TokenPair.fromJson(entry))
                .toList()
            : [];

  Map<String, dynamic> toJson() => {
        'networkClass': networkClass,
        'chainId': chainId,
        'name': name,
        'contractAddress': contractAddress,
        'metadata': metadata,
        'tokenPairs': tokenPairs.map((v) => v.toJson()).toList(),
      };
}

class BridgeNetworkInfoList {
  int count;
  List<BridgeNetworkInfo> list;

  BridgeNetworkInfoList({
    required this.count,
    required this.list,
  });

  BridgeNetworkInfoList.fromJson(Map<String, dynamic> json)
      : count = json['count'],
        list = (json['list'] as List)
            .map((entry) => BridgeNetworkInfo.fromJson(entry))
            .toList();

  Map<String, dynamic> toJson() => {
        'count': count,
        'list': list.map((v) => v.toJson()).toList(),
      };
}

class WrapTokenRequest {
  int networkClass;
  int chainId;
  Hash id;
  String toAddress;
  TokenStandard tokenStandard;
  String tokenAddress;
  BigInt amount;
  BigInt fee;
  String signature;
  int creationMomentumHeight;

  WrapTokenRequest({
    required this.networkClass,
    required this.chainId,
    required this.id,
    required this.toAddress,
    required this.tokenStandard,
    required this.tokenAddress,
    required this.amount,
    required this.fee,
    required this.signature,
    required this.creationMomentumHeight,
  });

  WrapTokenRequest.fromJson(Map<String, dynamic> json)
      : networkClass = json['networkClass'],
        chainId = json['chainId'],
        id = Hash.parse(json['id']),
        toAddress = json['toAddress'],
        tokenStandard = TokenStandard.parse(json['tokenStandard']),
        tokenAddress = json['tokenAddress'],
        amount = BigInt.parse(json['amount']),
        fee = BigInt.parse(json['fee']),
        signature = json['signature'],
        creationMomentumHeight = json['creationMomentumHeight'];

  Map<String, dynamic> toJson() => {
        'networkClass': networkClass,
        'chainId': chainId,
        'id': id.toString(),
        'toAddress': toAddress,
        'tokenStandard': tokenStandard.toString(),
        'tokenAddress': tokenAddress,
        'amount': amount.toString(),
        'fee': fee.toString(),
        'signature': signature,
        'creationMomentumHeight': creationMomentumHeight,
      };
}

class WrapTokenRequestList {
  int count;
  List<WrapTokenRequest> list;

  WrapTokenRequestList({
    required this.count,
    required this.list,
  });

  WrapTokenRequestList.fromJson(Map<String, dynamic> json)
      : count = json['count'],
        list = json['list'] != null
            ? (json['list'] as List)
                .map((entry) => WrapTokenRequest.fromJson(entry))
                .toList()
            : [];

  Map<String, dynamic> toJson() => {
        'count': count,
        'list': list.map((v) => v.toJson()).toList(),
      };
}

class UnwrapTokenRequest {
  int registrationMomentumHeight;
  int networkClass;
  int chainId;
  Hash transactionHash;
  int logIndex;
  Address toAddress;
  String tokenAddress;
  TokenStandard tokenStandard;
  BigInt amount;
  String signature;
  int redeemed;
  int revoked;

  UnwrapTokenRequest({
    required this.registrationMomentumHeight,
    required this.networkClass,
    required this.chainId,
    required this.transactionHash,
    required this.logIndex,
    required this.toAddress,
    required this.tokenAddress,
    required this.tokenStandard,
    required this.amount,
    required this.signature,
    required this.redeemed,
    required this.revoked,
  });

  UnwrapTokenRequest.fromJson(Map<String, dynamic> json)
      : registrationMomentumHeight = json['registrationMomentumHeight'],
        networkClass = json['networkClass'],
        chainId = json['chainId'],
        transactionHash = Hash.parse(json['transactionHash']),
        logIndex = json['logIndex'],
        toAddress = Address.parse(json['toAddress']),
        tokenAddress = json['tokenAddress'],
        tokenStandard = TokenStandard.parse(json['tokenStandard']),
        amount = BigInt.parse(json['amount']),
        signature = json['signature'],
        redeemed = json['redeemed'],
        revoked = json['revoked'];

  Map<String, dynamic> toJson() => {
        'registrationMomentumHeight': registrationMomentumHeight,
        'networkClass': networkClass,
        'chainId': chainId,
        'transactionHash': transactionHash.toString(),
        'logIndex': logIndex,
        'toAddress': toAddress.toString(),
        'tokenAddress': tokenAddress,
        'tokenStandard': tokenStandard.toString(),
        'amount': amount.toString(),
        'signature': signature,
        'redeemed': redeemed,
        'revoked': revoked,
      };
}

class UnwrapTokenRequestList {
  int count;
  List<UnwrapTokenRequest> list;

  UnwrapTokenRequestList({
    required this.count,
    required this.list,
  });

  UnwrapTokenRequestList.fromJson(Map<String, dynamic> json)
      : count = json['count'],
        list = json['list'] != null
            ? (json['list'] as List)
                .map((entry) => UnwrapTokenRequest.fromJson(entry))
                .toList()
            : [];

  Map<String, dynamic> toJson() => {
        'count': count,
        'list': list.map((v) => v.toJson()).toList(),
      };
}

class ZtsFeesInfo {
  TokenStandard tokenStandard;
  BigInt accumulatedFee;

  ZtsFeesInfo({
    required this.tokenStandard,
    required this.accumulatedFee,
  });

  ZtsFeesInfo.fromJson(Map<String, dynamic> json)
      : tokenStandard = TokenStandard.parse(json['tokenStandard']),
        accumulatedFee = BigInt.parse(json['accumulatedFee']);

  Map<String, dynamic> toJson() => {
        'tokenStandard': tokenStandard.toString(),
        'accumulatedFee': accumulatedFee.toString(),
      };
}

class TimeChallengesList {
  int count;
  List<TimeChallengeInfo> list;

  TimeChallengesList({
    required this.count,
    required this.list,
  });

  TimeChallengesList.fromJson(Map<String, dynamic> json)
      : count = json['count'],
        list = (json['list'] as List)
            .map((entry) => TimeChallengeInfo.fromJson(entry))
            .toList();

  Map<String, dynamic> toJson() => {
        'count': count,
        'list': list.map((v) => v.toJson()).toList(),
      };
}

/*
/// === Bridge constants ===

	InitialBridgeAdministrator   = types.ParseAddressPanic("z1qr9vtwsfr2n0nsxl2nfh6l5esqjh2wfj85cfq9")
	MaximumFee                   = uint32(10000)
	MinUnhaltDurationInMomentums = uint64(6 * MomentumsPerHour)  //main net
	MinAdministratorDelay        = uint64(2 * MomentumsPerEpoch) // main net
	MinSoftDelay                 = uint64(MomentumsPerEpoch)     // main net
	MinGuardians                 = 5                             // main net

	DecompressedECDSAPubKeyLength = 65
	CompressedECDSAPubKeyLength   = 33
	ECDSASignatureLength          = 65
 */
