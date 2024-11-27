import 'dart:async';

import 'package:hex/hex.dart';
import 'package:znn_sdk_dart/src/global.dart';
import 'package:znn_sdk_dart/src/model/model.dart';
import 'package:znn_sdk_dart/src/model/primitives/hash.dart';
import 'package:znn_sdk_dart/src/model/primitives/hash_height.dart';
import 'package:znn_sdk_dart/src/pow/pow.dart';
import 'package:znn_sdk_dart/src/utils/utils.dart';
import 'package:znn_sdk_dart/src/wallet/interfaces.dart';
import 'package:znn_sdk_dart/src/zenon.dart';

class BlockUtils {
  static bool isSendBlock(int? blockType) {
    return [BlockTypeEnum.userSend.index, BlockTypeEnum.contractSend.index]
        .contains(blockType);
  }

  static bool isReceiveBlock(int blockType) {
    return [
      BlockTypeEnum.userReceive.index,
      BlockTypeEnum.genesisReceive.index,
      BlockTypeEnum.contractReceive,
    ].contains(blockType);
  }

  static Hash getTransactionHash(AccountBlockTemplate transaction) {
    return Hash.digest(getTransactionBytes(transaction));
  }

  static List<int> getTransactionBytes(AccountBlockTemplate transaction) {
    var versionBytes = BytesUtils.longToBytes(transaction.version);
    var chainIdentifierBytes =
        BytesUtils.longToBytes(transaction.chainIdentifier);
    var blockTypeBytes = BytesUtils.longToBytes(transaction.blockType);
    var previousHashBytes = transaction.previousHash.getBytes()!;
    var heightBytes = BytesUtils.longToBytes(transaction.height);
    var momentumAcknowledgedBytes = transaction.momentumAcknowledged.getBytes();
    var addressBytes = transaction.address.getBytes();
    var toAddressBytes = transaction.toAddress.getBytes();
    var amountBytes = BytesUtils.bigIntToBytes(transaction.amount, 32);
    var tokenStandardBytes = transaction.tokenStandard.getBytes();
    var fromBlockHashBytes = transaction.fromBlockHash.hash;
    var descendentBlocksBytes = Hash.digest([]).getBytes();
    var dataBytes = Hash.digest(transaction.data).getBytes();
    var fusedPlasmaBytes = BytesUtils.longToBytes(transaction.fusedPlasma);
    var difficultyBytes = BytesUtils.longToBytes(transaction.difficulty);
    var nonceBytes = BytesUtils.leftPadBytes(HEX.decode(transaction.nonce), 8);

    var source = BytesUtils.merge([
      versionBytes,
      chainIdentifierBytes,
      blockTypeBytes,
      previousHashBytes,
      heightBytes,
      momentumAcknowledgedBytes,
      addressBytes,
      toAddressBytes,
      amountBytes,
      tokenStandardBytes,
      fromBlockHashBytes,
      descendentBlocksBytes,
      dataBytes,
      fusedPlasmaBytes,
      difficultyBytes,
      nonceBytes
    ]);

    return source;
  }

  static Hash _getPoWData(AccountBlockTemplate transaction) {
    return Hash.digest(BytesUtils.merge(
        [transaction.address.getBytes(), transaction.previousHash.getBytes()]));
  }

  static Future<void> _autofillTransactionParameters(
      AccountBlockTemplate accountBlockTemplate) async {
    var z = Zenon();
    var frontierAccountBlock =
        await z.ledger.getFrontierAccountBlock(accountBlockTemplate.address);

    var height = 1;
    Hash? previousHash = emptyHash;
    if (frontierAccountBlock != null) {
      height = frontierAccountBlock.height + 1;
      previousHash = frontierAccountBlock.hash;
    }

    accountBlockTemplate.height = height;
    accountBlockTemplate.previousHash = previousHash;

    var frontierMomentum = await z.ledger.getFrontierMomentum();
    var momentumAcknowledged =
        HashHeight(frontierMomentum.hash, frontierMomentum.height);
    accountBlockTemplate.momentumAcknowledged = momentumAcknowledged;
  }

  static Future<bool> _checkAndSetFields(
      AccountBlockTemplate transaction, WalletAccount currentKeyPair) async {
    var z = Zenon();

    transaction.address = await currentKeyPair.getAddress();
    transaction.publicKey = await currentKeyPair.getPublicKey();

    await _autofillTransactionParameters(transaction);

    if (BlockUtils.isSendBlock(transaction.blockType)) {
    } else {
      if (transaction.fromBlockHash == emptyHash) {
        throw Error();
      }

      var sendBlock =
          await z.ledger.getAccountBlockByHash(transaction.fromBlockHash);
      if (sendBlock == null) {
        throw Error();
      }
      if (!(sendBlock.toAddress.toString() == transaction.address.toString())) {
        throw Error();
      }

      if (transaction.data.isNotEmpty) {
        throw Error();
      }
    }

    if (transaction.difficulty > 0 && transaction.nonce == '') {
      throw Error();
    }
    return true;
  }

  static Future<bool> _setDifficulty(AccountBlockTemplate transaction,
      {void Function(PowStatus)? generatingPowCallback,
      waitForRequiredPlasma = false}) async {
    var z = Zenon();
    var powParam = GetRequiredParam(
        address: transaction.address,
        blockType: transaction.blockType,
        toAddress: transaction.toAddress,
        data: transaction.data);

    var response =
        await z.embedded.plasma.getRequiredPoWForAccountBlock(powParam);

    if (response.requiredDifficulty != 0) {
      transaction.fusedPlasma = response.availablePlasma;
      transaction.difficulty = response.requiredDifficulty.toInt();
      logger.info(
          'Generating Plasma for block: hash=${_getPoWData(transaction)}');
      generatingPowCallback?.call(PowStatus.generating);
      transaction.nonce =
          await generatePoW(_getPoWData(transaction), transaction.difficulty);
      generatingPowCallback?.call(PowStatus.done);
    } else {
      transaction.fusedPlasma = response.basePlasma;
      transaction.difficulty = 0;
      transaction.nonce = '0000000000000000';
    }
    return true;
  }

  static Future<bool> _setHashAndSignature(
      AccountBlockTemplate transaction, WalletAccount currentKeyPair) async {
    transaction.hash = getTransactionHash(transaction);
    transaction.signature = await currentKeyPair.signTx(transaction);
    return true;
  }

  static Future<AccountBlockTemplate> send(
      AccountBlockTemplate transaction, WalletAccount currentKeyPair,
      {void Function(PowStatus)? generatingPowCallback,
      waitForRequiredPlasma = false}) async {
    var z = Zenon();

    await _checkAndSetFields(transaction, currentKeyPair);
    await _setDifficulty(transaction,
        generatingPowCallback: generatingPowCallback,
        waitForRequiredPlasma: waitForRequiredPlasma);
    await _setHashAndSignature(transaction, currentKeyPair);
    await z.ledger.publishRawTransaction(transaction);

    logger.info('Published account-block');
    return transaction;
  }

  static Future<bool> requiresPoW(AccountBlockTemplate transaction,
      {WalletAccount? blockSigningKey}) async {
    var z = Zenon();

    transaction.address = await blockSigningKey!.getAddress();
    var powParam = GetRequiredParam(
        address: transaction.address,
        blockType: transaction.blockType,
        toAddress: transaction.toAddress,
        data: transaction.data);

    var response =
        await z.embedded.plasma.getRequiredPoWForAccountBlock(powParam);
    if (response.requiredDifficulty == 0) {
      return false;
    }
    return true;
  }
}
