import 'dart:async';
import 'dart:convert' as convert;
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:hex/hex.dart';
import 'package:path/path.dart' as path;
import 'package:znn_sdk_dart/src/crypto/crypto.dart';
import 'package:znn_sdk_dart/src/global.dart';
import 'package:znn_sdk_dart/src/model/primitives/hash.dart';

enum PowStatus {
  generating,
  done,
}

/// Custom PoW generation backend; returns the hex nonce for [dataHash] at
/// [difficulty]. See [setPowProvider].
typedef PowProvider = Future<String> Function(Hash dataHash, int difficulty);

PowProvider? _powProvider;

/// Routes subsequent [generatePoW] calls through [provider] instead of the
/// bundled native libpow_links library.
void setPowProvider(PowProvider provider) {
  _powProvider = provider;
}

/// Restores the default native PoW backend.
void clearPowProvider() {
  _powProvider = null;
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
  var insideSdk = path.join('znn_sdk_dart', 'lib', 'src', 'pow', 'blobs');
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

  var libraryPath = '';
  var found = false;

  for (var currentPath in possiblePaths) {
    libraryPath = path.join(currentPath, 'libpow_links.so');

    if (Platform.isMacOS) {
      libraryPath = path.join(currentPath, 'libpow_links.dylib');
    }
    if (Platform.isWindows) {
      libraryPath = path.join(currentPath, 'libpow_links.dll');
    }
    if (Platform.isAndroid) {
      libraryPath = path.join(currentPath, 'libpow_links-arm64-v8a.so');
    }

    var libFile = File(libraryPath);

    if (libFile.existsSync()) {
      found = true;
      break;
    }
  }

  logger.info('Loading libpow_links from path ' + libraryPath);

  if (!found) {
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
  if (difficulty == null) {
    throw ArgumentError('difficulty must not be null');
  }
  if (_powProvider != null) {
    return _powProvider!(hash, difficulty);
  }
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

/// Verifies that [nonce] (hex, 8 bytes) satisfies [difficulty] for
/// [dataHash], mirroring the node's `pow.CheckPoWNonce`.
///
/// The check computes `sha3-256(nonce || dataHash)` and compares its first 8
/// bytes, in little-endian order, against the threshold
/// `2^64 - 2^64 / difficulty`.
bool verifyPoW(Hash dataHash, int difficulty, String nonce) {
  var nonceBytes = HEX.decode(nonce);
  if (nonceBytes.length != 8) {
    throw ArgumentError('invalid nonce length');
  }
  if (difficulty < 0) {
    throw ArgumentError('difficulty must be non-negative');
  }
  var calc =
      Crypto.digest([...nonceBytes, ...dataHash.getBytes()!]).sublist(0, 8);
  var target = _targetByDifficulty(difficulty);
  // Both are little-endian ordered; compare from the most significant byte.
  for (var i = 7; i >= 0; i--) {
    if (calc[i] > target[i]) return true;
    if (calc[i] < target[i]) return false;
  }
  return true;
}

List<int> _targetByDifficulty(int difficulty) {
  if (difficulty == 0) {
    return List.filled(8, 0);
  }
  var x = BigInt.one << 64;
  x = x - (BigInt.one << 64) ~/ BigInt.from(difficulty);
  var mask = BigInt.from(0xff);
  return List.generate(8, (i) => ((x >> (8 * i)) & mask).toInt());
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
