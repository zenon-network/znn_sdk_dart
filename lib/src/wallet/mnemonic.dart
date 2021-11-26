import 'package:bip39/bip39.dart' as bip39;
import 'package:znn_sdk_dart/src/wallet/wordlist.dart';

class Mnemonic {
  static String generateMnemonic(int strength) {
    return bip39.generateMnemonic(strength: strength);
  }

  static bool validateMnemonic(List<String> words) {
    return bip39.validateMnemonic(words.join(' '));
  }

  static bool isValidWord(String word) {
    return enWordlist.contains(word);
  }
}
