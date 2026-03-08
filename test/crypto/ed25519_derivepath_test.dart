import 'package:test/test.dart';
import 'package:znn_sdk_dart/src/crypto/ed25519.dart';

void main() async {
  var seed =
      '19f1d107d49f42ebc14d46b51001c731569f142590fdd20167ddeedbb201516731ad5ac9b58d3a1c9c09debfe62538379461e4ea9f038124c428784fecc645b7';

  test('parse paths', () {
    var paths = [
      "m/44'/73404'/0'",
      "44'/73404'/5'",
      "m/44'/0'/0'",
      "m/44'/1/0/1",
      "m/48'/0'/0'/0/1",
      "48'/0'/0'/0/1"
    ];
    for (var path in paths) {
      Ed25519.derivePath(path, seed);
    }
  });
}
