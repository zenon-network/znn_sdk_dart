import 'package:znn_sdk_dart/src/utils/nom_constants.dart';

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
final int stakeTimeUnitSec = 30 * 24 * 60 * 60;
final int stakeTimeMaxSec = 12 * stakeTimeUnitSec;
final int stakeMinZnnAmount = oneZnn;
final String stakeUnitDurationName = 'month';

// Token
final int tokenZtsIssueFeeInZnn = oneZnn;
final int tokenNameMaxLength = 40;
final RegExp tokenNameRegExp = RegExp(r'^([a-zA-Z0-9]+[-._]?)*[a-zA-Z0-9]$');
final RegExp tokenSymbolRegExp = RegExp(r'^[A-Z0-9]+$');
final int tokenSymbolMaxLength = 10;
final List<String> tokenSymbolExceptions = ['ZNN', 'QSR'];
final RegExp tokenDomainRegExp = RegExp(r'^([A-Za-z0-9][A-Za-z0-9-]{0,61}[A-Za-z0-9]\.)+[A-Za-z]{2,}$');

// Accelerator
final RegExp proposalUrlRegExp = RegExp(r'^[a-zA-Z0-9]{2,60}\.[a-zA-Z]{1,6}([a-zA-Z0-9()@:%_\\+.~#?&/=-]{0,100})$');
final int proposalDescriptionMaxLength = 240;
final int proposalNameMaxLength = 30;
const int proposalCreationCostInZnn = 10;
const int proposalMaximumFundsInZnn = 5000;
const int proposalMinimumFundsInZnn = 10;
const int proposalVotingStatus = 0;
const int proposalActiveStatus = 1;
const int proposalPaidStatus = 2;
const int proposalClosedStatus = 3;
