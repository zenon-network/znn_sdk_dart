import 'package:znn_sdk_dart/src/abi/abi.dart';

class Definitions {
  static final String _plasmaDefinition = '''[
    {"type":"function","name":"Fuse","inputs":[{"name":"address","type":"address"}]},
    {"type":"function","name":"CancelFuse","inputs":[{"name":"id","type":"hash"}]}
  ]''';

  static final String _pillarDefinition = '''[
    {"type":"function","name":"Register","inputs":[{"name":"name","type":"string"},{"name":"producerAddress","type":"address"},{"name":"rewardAddress","type":"address"},{"name":"giveBlockRewardPercentage","type":"uint8"},{"name":"giveDelegateRewardPercentage","type":"uint8"}]},
    {"type":"function","name":"RegisterLegacy","inputs":[{"name":"name","type":"string"},{"name":"producerAddress","type":"address"},{"name":"rewardAddress","type":"address"},{"name":"giveBlockRewardPercentage","type":"uint8"},{"name":"giveDelegateRewardPercentage","type":"uint8"},{"name":"publicKey","type":"string"},{"name":"signature","type":"string"}]},
    {"type":"function","name":"Revoke","inputs":[{"name":"name","type":"string"}]},
    {"type":"function","name":"UpdatePillar","inputs":[{"name":"name","type":"string"},{"name":"producerAddress","type":"address"},{"name":"rewardAddress","type":"address"},{"name":"giveBlockRewardPercentage","type":"uint8"},{"name":"giveDelegateRewardPercentage","type":"uint8"}]},
    {"type":"function","name":"Delegate","inputs":[{"name":"name","type":"string"}]},
    {"type":"function","name":"Undelegate","inputs":[]}
  ]''';

  static final String _tokenDefinition = '''[
    {"type":"function","name":"IssueToken","inputs":[{"name":"tokenName","type":"string"},{"name":"tokenSymbol","type":"string"},{"name":"tokenDomain","type":"string"},{"name":"totalSupply","type":"uint256"},{"name":"maxSupply","type":"uint256"},{"name":"decimals","type":"uint8"},{"name":"isMintable","type":"bool"},{"name":"isBurnable","type":"bool"},{"name":"isUtility","type":"bool"}]},
    {"type":"function","name":"Mint","inputs":[{"name":"tokenStandard","type":"tokenStandard"},{"name":"amount","type":"uint256"},{"name":"receiveAddress","type":"address"}]},
    {"type":"function","name":"Burn","inputs":[]},
    {"type":"function","name":"UpdateToken","inputs":[{"name":"tokenStandard","type":"tokenStandard"},{"name":"owner","type":"address"},{"name":"isMintable","type":"bool"},{"name":"isBurnable","type":"bool"}]}
  ]''';

  static final String _sentinelDefinition = '''[
    {"type":"function","name":"Register","inputs":[]},
    {"type":"function","name":"Revoke","inputs":[]}
  ]''';

  static final String _swapDefinition = '''[
    {"type":"function","name":"RetrieveAssets","inputs":[{"name":"publicKey","type":"string"},{"name":"signature","type":"string"}]}
  ]''';

  static final String _stakeDefinition = '''[
    {"type":"function","name":"Stake","inputs":[{"name":"durationInSec", "type":"int64"}]},
    {"type":"function","name":"Cancel","inputs":[{"name":"id","type":"hash"}]}
  ]''';

  static final String _acceleratorDefinition = '''[
    {"type":"function","name":"CreateProject", "inputs":[{"name":"name","type":"string"},{"name":"description","type":"string"},
      {"name":"url","type":"string"},{"name":"znnFundsNeeded","type":"uint256"},{"name":"qsrFundsNeeded","type":"uint256"}]},
    {"type":"function","name":"AddPhase", "inputs":[
      {"name":"id","type":"hash"},{"name":"name","type":"string"},{"name":"description","type":"string"},
      {"name":"url","type":"string"},{"name":"znnFundsNeeded","type":"uint256"},{"name":"qsrFundsNeeded","type":"uint256"}]},
    {"type":"function","name":"UpdatePhase", "inputs":[
      {"name":"id","type":"hash"},{"name":"name","type":"string"},{"name":"description","type":"string"},
      {"name":"url","type":"string"},{"name":"znnFundsNeeded","type":"uint256"},{"name":"qsrFundsNeeded","type":"uint256"}]},
    {"type":"function","name":"Donate", "inputs":[]},
    {"type":"function","name":"VoteByName","inputs":[
      {"name":"id","type":"hash"},{"name":"name","type":"string"},{"name":"vote","type":"uint8"}]},
    {"type":"function","name":"VoteByProdAddress","inputs":[{"name":"id","type":"hash"},{"name":"vote","type":"uint8"}]}
  ]''';

  static final String _sporkDefinition = '''[
    {"type":"function","name":"CreateSpork","inputs":[{"name":"name","type":"string"},{"name":"description","type":"string"}]},
    {"type":"function","name":"ActivateSpork","inputs":[{"name":"id","type":"hash"}]}
  ]''';

  static final String _htlcDefinition = '''[
    {"type":"function","name":"Create", "inputs":[{"name":"hashLocked","type":"address"},{"name":"expirationTime","type":"int64"},{"name":"hashType","type":"uint8"},{"name":"keyMaxSize","type":"uint8"},{"name":"hashLock","type":"bytes"}]},
    {"type":"function","name":"Reclaim","inputs":[{"name":"id","type":"hash"}]},
    {"type":"function","name":"Unlock","inputs":[{"name":"id","type":"hash"},{"name":"preimage","type":"bytes"}]},
    {"type":"function","name":"DenyProxyUnlock","inputs":[]},
    {"type":"function","name":"AllowProxyUnlock","inputs":[]}
  ]''';

  static final String _bridgeDefinition = '''[
    {"type":"function","name":"WrapToken","inputs":[{"name":"networkClass","type":"uint32"},{"name":"chainId","type":"uint32"},{"name":"toAddress","type":"string"}]},
    {"type":"function","name":"UpdateWrapRequest","inputs":[{"name":"id","type":"hash"},{"name":"signature","type":"string"}]},
    {"type":"function","name":"SetNetwork","inputs":[{"name":"networkClass","type":"uint32"},{"name":"chainId","type":"uint32"},{"name":"name","type":"string"},{"name":"contractAddress","type":"string"},{"name":"metadata","type":"string"}]},
    {"type":"function","name":"RemoveNetwork","inputs":[{"name":"networkClass","type":"uint32"},{"name":"chainId","type":"uint32"}]},
    {"type":"function","name":"SetTokenPair","inputs":[{"name":"networkClass","type":"uint32"},{"name":"chainId","type":"uint32"},{"name":"tokenStandard","type":"tokenStandard"},{"name":"tokenAddress","type":"string"},{"name":"bridgeable","type":"bool"},{"name":"redeemable","type":"bool"},{"name":"owned","type":"bool"},{"name":"minAmount","type":"uint256"},{"name":"feePercentage","type":"uint32"},{"name":"redeemDelay","type":"uint32"},{"name":"metadata","type":"string"}]},
    {"type":"function","name":"SetNetworkMetadata","inputs":[{"name":"networkClass","type":"uint32"},{"name":"chainId","type":"uint32"},{"name":"metadata","type":"string"}]},
    {"type":"function","name":"RemoveTokenPair","inputs":[{"name":"networkClass","type":"uint32"},{"name":"chainId","type":"uint32"},{"name":"tokenStandard","type":"tokenStandard"},{"name":"tokenAddress","type":"string"}]},
    {"type":"function","name":"Halt","inputs":[{"name":"signature","type":"string"}]},
    {"type":"function","name":"Unhalt","inputs":[]},
    {"type":"function","name":"Emergency","inputs":[]},
    {"type":"function","name":"ChangeTssECDSAPubKey","inputs":[{"name":"pubKey","type":"string"},{"name":"oldPubKeySignature","type":"string"},{"name":"newPubKeySignature","type":"string"}]},
    {"type":"function","name":"ChangeAdministrator","inputs":[{"name":"administrator","type":"address"}]},
    {"type":"function","name":"ProposeAdministrator","inputs":[{"name":"address","type":"address"}]},
    {"type":"function","name":"SetAllowKeyGen","inputs":[{"name":"allowKeyGen","type":"bool"}]},
    {"type":"function","name":"SetRedeemDelay","inputs":[{"name":"redeemDelay","type":"uint64"}]},
    {"type":"function","name":"SetBridgeMetadata","inputs":[{"name":"metadata","type":"string"}]},
    {"type":"function","name":"UnwrapToken","inputs":[{"name":"networkClass","type":"uint32"},{"name":"chainId","type":"uint32"},{"name":"transactionHash","type":"hash"},{"name":"logIndex","type":"uint32"},{"name":"toAddress","type":"address"},{"name":"tokenAddress","type":"string"},{"name":"amount","type":"uint256"},{"name":"signature","type":"string"}]},
    {"type":"function","name":"RevokeUnwrapRequest","inputs":[{"name":"transactionHash","type":"hash"},{"name":"logIndex","type":"uint32"}]},
    {"type":"function","name":"Redeem","inputs":[{"name":"transactionHash","type":"hash"},{"name":"logIndex","type":"uint32"}]},
    {"type":"function","name":"NominateGuardians","inputs":[{"name":"guardians","type":"address[]"}]},
    {"type":"function","name":"SetOrchestratorInfo","inputs":[{"name":"windowSize","type":"uint64"},{"name":"keyGenThreshold","type":"uint32"},{"name":"confirmationsToFinality","type":"uint32"},{"name":"estimatedMomentumTime","type":"uint32"}]}
  ]''';

  static final String _liquidityDefinition = '''[
    {"type":"function","name":"Update","inputs":[]},
    {"type":"function","name":"Donate","inputs":[]},
    {"type":"function","name":"Fund","inputs":[{"name":"znnReward","type":"uint256"},{"name":"qsrReward","type":"uint256"}]},
    {"type":"function","name":"BurnZnn","inputs":[{"name":"burnAmount","type":"uint256"}]},
    {"type":"function","name":"SetTokenTuple","inputs":[{"name":"tokenStandards","type":"string[]"},{"name":"znnPercentages","type":"uint32[]"},{"name":"qsrPercentages","type":"uint32[]"},{"name":"minAmounts","type":"uint256[]"}]},
    {"type":"function","name":"NominateGuardians","inputs":[{"name":"guardians","type":"address[]"}]},
    {"type":"function","name":"ProposeAdministrator","inputs":[{"name":"address","type":"address"}]},
    {"type":"function","name":"Emergency","inputs":[]},
    {"type":"function","name":"SetIsHalted","inputs":[{"name":"isHalted","type":"bool"}]},
    {"type":"function","name":"LiquidityStake","inputs":[{"name":"durationInSec", "type":"int64"}]},
    {"type":"function","name":"CancelLiquidityStake","inputs":[{"name":"id","type":"hash"}]},
    {"type":"function","name":"UnlockLiquidityStakeEntries","inputs":[]},
    {"type":"function","name":"SetAdditionalReward","inputs":[{"name":"znnReward", "type":"uint256"},{"name":"qsrReward", "type":"uint256"}]},
    {"type":"function","name":"CollectReward","inputs":[]},
    {"type":"function","name":"ChangeAdministrator","inputs":[{"name":"administrator","type":"address"}]}
  ]''';

  // Common definitions of embedded methods
  static final String _commonDefinition = '''[
    {"type":"function","name":"DepositQsr","inputs":[]},
    {"type":"function","name":"WithdrawQsr","inputs":[]},
    {"type":"function","name":"CollectReward","inputs":[]},
    {"type":"function","name":"Update","inputs":[]},
    {"type":"function","name":"Donate","inputs":[]},
    {"type":"function","name":"VoteByName","inputs":[{"name":"id","type":"hash"},{"name":"name","type":"string"},{"name":"vote","type":"uint8"}]},
    {"type":"function","name":"VoteByProdAddress","inputs":[{"name":"id","type":"hash"},{"name":"vote","type":"uint8"}]},
    {"type":"variable","name":"timeChallengeInfo","inputs":[{"name":"methodName","type":"string"},{"name":"paramsHash","type":"hash"},{"name":"challengeStartHeight","type":"uint64"}]},
    {"type":"variable","name":"securityInfo","inputs":[{"name":"guardians","type":"address[]"},{"name":"guardiansVotes","type":"address[]"},{"name":"administratorDelay","type":"uint64"},{"name":"softDelay","type":"uint64"}]}
  ]''';

  // ABI definitions of embedded contracts
  static final Abi plasma = Abi.fromJson(_plasmaDefinition);
  static final Abi pillar = Abi.fromJson(_pillarDefinition);
  static final Abi token = Abi.fromJson(_tokenDefinition);
  static final Abi sentinel = Abi.fromJson(_sentinelDefinition);
  static final Abi swap = Abi.fromJson(_swapDefinition);
  static final Abi stake = Abi.fromJson(_stakeDefinition);
  static final Abi accelerator = Abi.fromJson(_acceleratorDefinition);
  static final Abi bridge = Abi.fromJson(_bridgeDefinition);
  static final Abi liquidity = Abi.fromJson(_liquidityDefinition);
  static final Abi spork = Abi.fromJson(_sporkDefinition);
  static final Abi htlc = Abi.fromJson(_htlcDefinition);
  static final Abi common = Abi.fromJson(_commonDefinition);
}
