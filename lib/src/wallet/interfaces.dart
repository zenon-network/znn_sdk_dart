import 'package:znn_sdk_dart/src/model/primitives.dart';

abstract class Wallet {
  Future<Address?> get address;

  Future<List<int>> getPublicKey([bool verify]);

  Future<List<int>> sign(List<int> message);

  Future<bool> verify(List<int> signature, List<int> message);
}
