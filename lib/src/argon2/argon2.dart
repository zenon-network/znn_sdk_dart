import 'dart:ffi';
import 'dart:io';

import 'package:argon2_ffi_base/argon2_ffi_base.dart';
import 'package:path/path.dart' as path;
import 'package:znn_sdk_dart/src/global.dart';

var invalidArgon2LibPathException =
    ZnnSdkException('Library libargon2 could not be found');

Argon2FfiFlutter initArgon2() {
  if (Platform.isMacOS) {
    Argon2.resolveLibraryForceDynamic = true;
  }

  return Argon2FfiFlutter(resolveLibrary: (libraryName) {
    String libraryPath = '';
    if (Platform.isAndroid) {
      libraryPath = 'libargon2_ffi.so';
      DynamicLibrary.open(libraryPath);
    } else if (Platform.isIOS) {
      DynamicLibrary.process();
    } else {
      String insideSdk = path.join('lib', 'src', 'argon2', 'blobs');
      List<String> currentPathListParts = path.split(Directory.current.path);
      currentPathListParts.removeLast();
      List<String> executablePathListParts =
          path.split(Platform.resolvedExecutable);
      executablePathListParts.removeLast();
      List<String> possiblePaths = List<String>.empty(growable: true);
      possiblePaths.add(Directory.current.path);
      possiblePaths.add(path.joinAll(executablePathListParts));
      executablePathListParts.removeLast();
      possiblePaths
          .add(path.join(path.joinAll(executablePathListParts), 'Resources'));
      possiblePaths
          .add(path.join(path.joinAll(currentPathListParts), insideSdk));
      possiblePaths.add(
          path.join(path.joinAll(currentPathListParts), 'packages', insideSdk));

      bool found = false;

      for (String currentPath in possiblePaths) {
        libraryPath = path.join(currentPath, libraryName);

        File libFile = File(libraryPath);

        if (libFile.existsSync()) {
          found = true;
          break;
        }
      }

      if (!found) {
        throw invalidArgon2LibPathException;
      }
      logger.info('Loading ' + libraryName + ' from path ' + libraryPath);
    }
    return libraryPath;
  });
}
