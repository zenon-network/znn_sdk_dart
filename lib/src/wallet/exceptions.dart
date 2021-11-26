import 'package:znn_sdk_dart/src/global.dart';

class InvalidKeyStorePath implements Exception {
  String message;

  InvalidKeyStorePath(this.message);

  @override
  String toString() {
    return message;
  }
}

class IncorrectPasswordException extends ZnnSdkException {
  IncorrectPasswordException() : super('Incorrect password');
}
