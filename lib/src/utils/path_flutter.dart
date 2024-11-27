import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:znn_sdk_dart/src/global.dart';
import 'package:znn_sdk_dart/src/utils/path.dart';

Future<ZnnPaths> getDefaultPaths() async {
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
  } else if (Platform.isAndroid || Platform.isIOS) {
    main = await getApplicationSupportDirectory();
  } else {
    throw UnsupportedError('Unsupported platform');
  }
  return ZnnPaths(
      main: main,
      wallet: Directory(path.join(main.path, 'wallet')),
      cache: Directory(path.join(main.path, 'syrius')));
}
