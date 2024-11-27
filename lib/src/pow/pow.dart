import 'dart:async';
import 'dart:convert' as convert;
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import 'package:znn_sdk_dart/src/global.dart';
import 'package:znn_sdk_dart/src/model/primitives/hash.dart';
import 'package:znn_sdk_dart/src/utils/path.dart';

enum PowStatus {
  generating,
  done,
}

var invalidPowLinksLibPathException =
    ZnnSdkException('Library libpow_links could not be found');

typedef _GeneratePowFunc = Pointer<Utf8> Function(
    Pointer<Utf8> data, Pointer<Utf8> difficulty);
typedef _GeneratePoW = Pointer<Utf8> Function(
    Pointer<Utf8> data, Pointer<Utf8> difficulty);
typedef _BenchmarkPowFunc = Pointer<Utf8> Function(Pointer<Utf8> difficulty);
typedef _BenchmarkPoW = Pointer<Utf8> Function(Pointer<Utf8> difficulty);

_GeneratePowFunc? _generatePoWFunction;
var _benchmarkFunction;

// Loads the dynamic pow_links library and maps the required functions. Throws if fails.
// Called automatically from `GeneratePow` and `BenchmarkPoW` if not called in advance.
void initializePoWLinks() {
  String insideSdk = path.join('lib', 'src', 'pow', 'blobs');
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
  possiblePaths.add(path.join(path.joinAll(currentPathListParts), insideSdk));

  Directory pubCacheDir = Directory(getPubCachePath());
  if (pubCacheDir.existsSync()) {
    pubCacheDir.listSync(recursive: true, followLinks: false).forEach((f) {
      if (f.toString().contains('libpow_links') &&
          f.statSync().type == FileSystemEntityType.file &&
          (path.extension(f.absolute.path).contains('.so') ||
              path.extension(f.absolute.path).contains('.dylib') ||
              path.extension(f.absolute.path).contains('.dll'))) {
        var libPath = path.split(f.absolute.path);
        libPath.removeLast();
        possiblePaths.add(path.joinAll(libPath));
      }
    });
  }

  String libraryPath = '';
  bool found = false;

  for (String currentPath in possiblePaths) {
    if (Platform.isLinux) {
      libraryPath = path.join(currentPath, 'libpow_links.so');
    }

    if (Platform.isMacOS) {
      libraryPath = path.join(currentPath, 'libpow_links.dylib');
    }
    if (Platform.isWindows) {
      libraryPath = path.join(currentPath, 'libpow_links.dll');
    }

    if (Platform.isAndroid) {
      libraryPath = 'libpow_links.so';
      found = true;
      break;
    }

    File libFile = File(libraryPath);
    if (libFile.existsSync()) {
      found = true;
      break;
    }
  }

  logger.info('Loading libpow_links from path ' + libraryPath);

  if (!found && !Platform.isIOS) {
    throw invalidPowLinksLibPathException;
  }

  // Open the dynamic library
  final dylib = Platform.isIOS
      ? DynamicLibrary.process()
      : DynamicLibrary.open(libraryPath);

  // Look up the CPP function 'generatePoW'
  final generatePoWPointer =
      dylib.lookup<NativeFunction<_GeneratePowFunc>>('generatePoW');
  _generatePoWFunction = generatePoWPointer.asFunction<_GeneratePoW>();

  // Look up the C function 'benchmark'
  final functionPointer =
      dylib.lookup<NativeFunction<_BenchmarkPowFunc>>('benchmark');
  _benchmarkFunction = functionPointer.asFunction<_BenchmarkPoW>();
}

class _GeneratePowFunctionArguments {
  final Hash hash;
  final int? difficulty;
  final SendPort sendPort;

  _GeneratePowFunctionArguments(this.hash, this.difficulty, this.sendPort);
}

void _generatePowFunction(_GeneratePowFunctionArguments args) {
  initializePoWLinks();
  final Pointer<Utf8> ret = _generatePoWFunction!(
      args.hash.toString().toNativeUtf8(),
      args.difficulty.toString().toNativeUtf8());

  var utf8 = ret.toDartString();
  args.sendPort.send(utf8);
}

// Returns a hex representation of nonce.
// Runs single threaded, with native c code.
Future<String> generatePoW(Hash hash, int? difficulty) async {
  if (_generatePoWFunction == null) {
    initializePoWLinks();
  }

  final port = ReceivePort();
  final args = _GeneratePowFunctionArguments(hash, difficulty, port.sendPort);
  Isolate? isolate = await Isolate.spawn<_GeneratePowFunctionArguments>(
      _generatePowFunction, args,
      onError: port.sendPort, onExit: port.sendPort);
  StreamSubscription? sub;
  // Listening for messages on port
  var completer = Completer<String>();

  sub = port.listen((data) async {
    // Cancel a subscription after message received called
    if (data != null) {
      var ansHex = data.toString();
      completer.complete(ansHex);
      await sub?.cancel();
      logger.info(
          'Generated nonce $ansHex for hash ${hash.toString()} with difficulty $difficulty');
      if (isolate != null) {
        isolate!.kill(priority: Isolate.immediate);
        isolate = null;
      }
    }
  });
  return completer.future;
}

// Generates a nonce for the empty hash. Does not use a random nonce.
//
// Expects
// - difficulty 10'000'000
// - runtime ~800 ms
// - return ufVIAAAAAAA=
String benchmarkPoW(int difficulty) {
  if (_benchmarkFunction == null) {
    initializePoWLinks();
  }

  final ret = _benchmarkFunction(convert.utf8.encode(difficulty.toString()));
  final ans = convert.utf8.decode(ret);
  return ans;
}
