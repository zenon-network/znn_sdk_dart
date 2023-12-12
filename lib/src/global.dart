import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

export 'package:logging/logging.dart' show Level;

const znnSdkVersion = '0.0.6';
const znnRootDirectory = 'znn';

class ZnnPaths {
  Directory main;
  Directory wallet;
  Directory cache;

  ZnnPaths(
      {required Directory main,
      required Directory wallet,
      required Directory cache})
      : main = main,
        wallet = wallet,
        cache = cache;
}

ZnnPaths _getDefaultPaths() {
  late Directory main;
  if (Platform.isLinux) {
    main = Directory(
        path.join(Platform.environment['HOME']!, '.$znnRootDirectory'));
  } else if (Platform.isMacOS) {
    main = Directory(
        path.join(Platform.environment['HOME']!, 'Library', znnRootDirectory));
  } else if (Platform.isWindows) {
    main = Directory(
        path.join(Platform.environment['AppData']!, znnRootDirectory));
  } else {
    main =
        Directory(path.join(Platform.environment['HOME']!, znnRootDirectory));
  }
  return ZnnPaths(
      main: main,
      wallet: Directory(path.join(main.path, 'wallet')),
      cache: Directory(path.join(main.path, 'syrius')));
}

ZnnPaths znnDefaultPaths = _getDefaultPaths();
Directory znnDefaultDirectory = znnDefaultPaths.main;
Directory znnDefaultWalletDirectory = znnDefaultPaths.wallet;
Directory znnDefaultCacheDirectory = znnDefaultPaths.cache;

void ensureDirectoriesExist() {
  if (!znnDefaultWalletDirectory.existsSync()) {
    znnDefaultWalletDirectory.createSync(recursive: true);
  }
  if (!znnDefaultCacheDirectory.existsSync()) {
    znnDefaultCacheDirectory.createSync(recursive: true);
  }
  return;
}

String getPubCachePath() {
  Map env = Platform.environment;

  if (env.containsKey('PUB_CACHE')) {
    return Directory(env['PUB_CACHE']).path;
  } else if (Platform.isWindows) {
    var pubCacheDirectory =
        Directory(path.join(env['APPDATA'], 'Pub', 'Cache'));
    if (pubCacheDirectory.existsSync()) {
      return pubCacheDirectory.path;
    }
    return Directory(path.join(env['LOCALAPPDATA'], 'Pub', 'Cache')).path;
  }
  return Directory('${env['HOME']}/.pub-cache').path;
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
