import 'package:hex/hex.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

Future<void> main() async {
  final mnemonic =
      'route become dream access impulse price inform obtain engage ski believe awful absent pig thing vibrant possible exotic flee pepper marble rural fire fancy';

  var keyStore = KeyStore.fromMnemonic(mnemonic);
  var keyPair = keyStore.getKeyPair(0);
  var privateKey = keyPair.getPrivateKey();
  var publicKey = await keyPair.getPublicKey();
  var address = await keyPair.address;

  print('entropy: ${keyStore.entropy}');
  print('private key: ${HEX.encode(privateKey!)}');
  print('public key: ${HEX.encode(publicKey)}');
  print('address: $address');
  print('core bytes: ${HEX.encode(address!.core!)}');
}
