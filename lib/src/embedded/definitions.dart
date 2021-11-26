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
      {"name":"url","type":"string"},{"name":"fundsNeeded","type":"uint256"}]},
		{"type":"function","name":"AddPhase", "inputs":[
			{"name":"id","type":"hash"},{"name":"name","type":"string"},{"name":"description","type":"string"},
			{"name":"url","type":"string"},{"name":"fundsNeeded","type":"uint256"}]},
		{"type":"function","name":"UpdatePhase", "inputs":[
			{"name":"id","type":"hash"},{"name":"name","type":"string"},{"name":"description","type":"string"},
			{"name":"url","type":"string"},{"name":"fundsNeeded","type":"uint256"}]},
		{"type":"function","name":"Donate", "inputs":[]},
		{"type":"function","name":"UpdateProjects", "inputs":[]},
		{"type":"function","name":"VoteByName","inputs":[
			{"name":"id","type":"hash"},{"name":"name","type":"string"},{"name":"vote","type":"uint8"}]},
		{"type":"function","name":"VoteByProdAddress","inputs":[{"name":"id","type":"hash"},{"name":"vote","type":"uint8"}]}
  ]''';

  // Common definitions of embedded methods
  static final String _commonDefinition = '''[
    {"type":"function","name":"DepositQsr","inputs":[]},
    {"type":"function","name":"WithdrawQsr","inputs":[]},
    {"type":"function","name":"CollectReward","inputs":[]}
  ]''';

  // ABI definitions of embedded contracts
  static final Abi plasma = Abi.fromJson(_plasmaDefinition);
  static final Abi pillar = Abi.fromJson(_pillarDefinition);
  static final Abi token = Abi.fromJson(_tokenDefinition);
  static final Abi sentinel = Abi.fromJson(_sentinelDefinition);
  static final Abi swap = Abi.fromJson(_swapDefinition);
  static final Abi stake = Abi.fromJson(_stakeDefinition);
  static final Abi accelerator = Abi.fromJson(_acceleratorDefinition);
  static final Abi common = Abi.fromJson(_commonDefinition);
}
