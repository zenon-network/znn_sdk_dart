import 'package:znn_sdk_dart/src/global.dart';

class WalletException implements Exception {
  String message;

  WalletException(this.message);

  @override
  String toString() {
    return message;
  }
}

class IncorrectPasswordException extends ZnnSdkException {
  IncorrectPasswordException() : super('Incorrect password');
}
