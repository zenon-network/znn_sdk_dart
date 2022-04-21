import 'package:znn_sdk_dart/src/utils/nom_constants.dart';

const genesisTimestamp = 1637755200;

// Plasma
final int fuseMinQsrAmount = 10 * oneQsr;
final int minPlasmaAmount = 21000;

// Pillar
final int pillarRegisterZnnAmount = 15000 * oneZnn;
final int pillarRegisterQsrAmount = 150000 * oneQsr;
final int pillarNameMaxLength = 40;
final RegExp pillarNameRegExp = RegExp(r'^([a-zA-Z0-9]+[-._]?)*[a-zA-Z0-9]$');

// Sentinel
final int sentinelRegisterZnnAmount = 5000 * oneZnn;
final int sentinelRegisterQsrAmount = 50000 * oneQsr;

// Staking
final int stakeMinZnnAmount = oneZnn;
final int stakeTimeUnitSec = 30 * 24 * 60 * 60;
final int stakeTimeMaxSec = 12 * stakeTimeUnitSec;
final String stakeUnitDurationName = 'month';

// Token
final int tokenZtsIssueFeeInZnn = oneZnn;
final int tokenNameMaxLength = 40;
final int tokenSymbolMaxLength = 10;
final List<String> tokenSymbolExceptions = ['ZNN', 'QSR'];
final RegExp tokenNameRegExp = RegExp(r'^([a-zA-Z0-9]+[-._]?)*[a-zA-Z0-9]$');
final RegExp tokenSymbolRegExp = RegExp(r'^[A-Z0-9]+$');
final RegExp tokenDomainRegExp =
    RegExp(r'^([A-Za-z0-9][A-Za-z0-9-]{0,61}[A-Za-z0-9]\.)+[A-Za-z]{2,}$');

// Accelerator
final int projectDescriptionMaxLength = 240;
final int projectNameMaxLength = 30;
const int projectCreationFeeInZnn = 1;
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
