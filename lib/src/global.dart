import 'dart:io';

import 'package:logging/logging.dart';
import 'package:znn_sdk_dart/src/utils/path.dart';
import 'package:znn_sdk_dart/src/utils/path_stub.dart'
    if (dart.library.ui) 'package:znn_sdk_dart/src/utils/path_flutter.dart'
    if (dart.library.io) 'package:znn_sdk_dart/src/utils/path_dart.dart';

const znnSdkVersion = '0.2.0';
const znnRootDirectory = 'znn';

Future<Directory> znnDefaultMainDirectory =
    getDefaultPaths().then((value) => value.main);
Future<Directory> znnDefaultWalletDirectory =
    getDefaultPaths().then((value) => value.wallet);
Future<Directory> znnDefaultCacheDirectory =
    getDefaultPaths().then((value) => value.cache);

void ensureDirectoriesExist() async {
  Directory znnDefaultWalletDirectory = await getZnnDefaultWalletDirectory();
  if (!znnDefaultWalletDirectory.existsSync()) {
    znnDefaultWalletDirectory.createSync(recursive: true);
  }
  Directory znnDefaultCacheDirectory = await getZnnDefaultCacheDirectory();
  if (!znnDefaultCacheDirectory.existsSync()) {
    znnDefaultCacheDirectory.createSync(recursive: true);
  }
  return;
}

Future<Directory> getZnnDefaultMainDirectory() async {
  ZnnPaths znnPaths = await getDefaultPaths();
  return znnPaths.main;
}

Future<Directory> getZnnDefaultWalletDirectory() async {
  ZnnPaths znnPaths = await getDefaultPaths();
  return znnPaths.wallet;
}

Future<Directory> getZnnDefaultCacheDirectory() async {
  ZnnPaths znnPaths = await getDefaultPaths();
  return znnPaths.cache;
}

int chainId = 1; // Alphanet

void setChainIdentifier({int chainIdentifier = 1}) {
  chainId = chainIdentifier;
}

int getChainIdentifier() {
  return chainId;
}

final logger = Logger('ZNN-SDK');

class ZnnSdkException implements Exception {
  final String? message;

  ZnnSdkException([this.message]);

  @override
  String toString() {
    Object? message = this.message;
    if (message == null) return 'Zenon SDK Exception';
    return 'Zenon SDK Exception: $message';
  }
}
