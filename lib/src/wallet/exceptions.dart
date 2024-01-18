import 'package:znn_sdk_dart/src/global.dart';

class InvalidWalletPath implements Exception {
  String message;

  InvalidWalletPath(this.message);

  @override
  String toString() {
    return message;
  }
}

class IncorrectPasswordException extends ZnnSdkException {
  IncorrectPasswordException() : super('Incorrect password');
}
