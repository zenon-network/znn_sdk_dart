import 'package:znn_sdk_dart/src/utils/nom_constants.dart';

const genesisTimestamp = 1637755200;

// Plasma
final BigInt fuseMinQsrAmount = BigInt.from(10 * oneQsr);
final BigInt minPlasmaAmount = BigInt.from(21000);

// Pillar
final BigInt kMinDelegationAmount = BigInt.from(1 * oneZnn);
final BigInt pillarRegisterZnnAmount = BigInt.from(15000 * oneZnn);
final BigInt pillarRegisterQsrAmount = BigInt.from(150000 * oneQsr);
final int pillarNameMaxLength = 40;
final RegExp pillarNameRegExp = RegExp(r'^([a-zA-Z0-9]+[-._]?)*[a-zA-Z0-9]$');

// Sentinel
final BigInt sentinelRegisterZnnAmount = BigInt.from(5000 * oneZnn);
final BigInt sentinelRegisterQsrAmount = BigInt.from(50000 * oneQsr);

// Staking
final BigInt stakeMinZnnAmount = BigInt.from(1 * oneZnn);
final int stakeTimeUnitSec = 30 * 24 * 60 * 60;
final int stakeTimeMaxSec = 12 * stakeTimeUnitSec;
final String stakeUnitDurationName = 'month';

// Token
final BigInt tokenZtsIssueFeeInZnn = BigInt.from(1 * oneZnn);
final BigInt kMinTokenTotalMaxSupply = BigInt.one;
final BigInt kBigP255 = BigInt.from(2).pow(255);
final BigInt kBigP255m1 = kBigP255 - BigInt.one;
final int tokenNameMaxLength = 40;
final int tokenSymbolMaxLength = 10;
final List<String> tokenSymbolExceptions = ['ZNN', 'QSR'];
final RegExp tokenNameRegExp = RegExp(r'^([a-zA-Z0-9]+[-._]?)*[a-zA-Z0-9]$');
final RegExp tokenSymbolRegExp = RegExp(r'^[A-Z0-9]+$');
final RegExp tokenDomainRegExp =
    RegExp(r'^([A-Za-z0-9][A-Za-z0-9-]{0,61}[A-Za-z0-9]\.)+[A-Za-z]{2,}$');

// Accelerator
final BigInt projectCreationFeeInZnn = BigInt.from(1 * oneZnn);
final BigInt kZnnProjectMaximumFunds = BigInt.from(5000 * oneZnn);
final BigInt kQsrProjectMaximumFunds = BigInt.from(50000 * oneQsr);
final BigInt kZnnProjectMinimumFunds = BigInt.from(10 * oneZnn);
final BigInt kQsrProjectMinimumFunds = BigInt.from(100 * oneQsr);
final int projectDescriptionMaxLength = 240;
final int projectNameMaxLength = 30;
const int projectVotingStatus = 0;
const int projectActiveStatus = 1;
const int projectPaidStatus = 2;
const int projectClosedStatus = 3;
final RegExp projectUrlRegExp = RegExp(
    r'^[a-zA-Z0-9]{2,60}\.[a-zA-Z]{1,6}([a-zA-Z0-9()@:%_\\+.~#?&/=-]{0,100})$');

// Swap
const int swapAssetDecayTimestampStart = 1645531200;
const int swapAssetDecayEpochsOffset = 30 * 3;
const int swapAssetDecayTickEpochs = 30;
const int swapAssetDecayTickValuePercentage = 10;
