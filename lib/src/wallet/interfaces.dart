import 'package:znn_sdk_dart/src/model/primitives.dart';
import 'package:znn_sdk_dart/src/model/nom/account_block_template.dart';

abstract class Wallet {
  Future<Signer> getSigner([int index = 0]);
}

abstract class Signer {
  Future<Address?> get address;

  Future<List<int>> getPublicKey();

  Future<List<int>> sign(List<int> message);

  Future<List<int>> signTx(AccountBlockTemplate tx);
}
