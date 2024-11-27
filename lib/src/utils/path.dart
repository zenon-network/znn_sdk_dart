import 'dart:io';

import 'package:path/path.dart' as path;

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
