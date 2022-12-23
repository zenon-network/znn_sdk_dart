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
    var insideSdk = path.join('znn_sdk_dart', 'lib', 'src', 'argon2', 'blobs');
    var currentPathListParts = path.split(Directory.current.path);
    currentPathListParts.removeLast();
    var executablePathListParts = path.split(Platform.resolvedExecutable);
    executablePathListParts.removeLast();
    var possiblePaths = List<String>.empty(growable: true);
    possiblePaths.add(Directory.current.path);
    possiblePaths.add(path.joinAll(executablePathListParts));
    executablePathListParts.removeLast();
    possiblePaths
        .add(path.join(path.joinAll(executablePathListParts), 'Resources'));
    possiblePaths.add(path.join(path.joinAll(currentPathListParts), insideSdk));

    Directory(getPubCachePath())
        .listSync(recursive: true, followLinks: false)
        .forEach((f) {
      if (f.toString().contains('argon2_ffi') &&
          f.statSync().type == FileSystemEntityType.file &&
          (path.extension(f.absolute.path).contains('.so') ||
              path.extension(f.absolute.path).contains('.dylib') ||
              path.extension(f.absolute.path).contains('.dll'))) {
        var libPath = path.split(f.absolute.path);
        libPath.removeLast();
        possiblePaths.add(path.joinAll(libPath));
      }
    });

    var libraryPath = '';
    var found = false;

    for (var currentPath in possiblePaths) {
      libraryPath = path.join(currentPath, libraryName);

      var libFile = File(libraryPath);

      if (libFile.existsSync()) {
        found = true;
        break;
      }
    }

    if (!found) {
      throw invalidArgon2LibPathException;
    }
    logger.info('Loading ' + libraryName + ' from path ' + libraryPath);

    return libraryPath;
  });
}
