import 'package:bip39_mnemonic/bip39_mnemonic.dart' as bip39;
import 'package:znn_sdk_dart/src/wallet/wordlist.dart';

/// Utility helpers for BIP-39 mnemonics (English only).
class Mnemonic {
  /// Generates a new English BIP-39 mnemonic.
  ///
  /// [strength] must be a valid entropy size in bits:
  /// 128, 160, 192, 224, or 256.
  static String generateMnemonic(int strength) {
    final length = bip39.MnemonicLength.fromEntropy(strength);

    final m = bip39.Mnemonic.generate(bip39.Language.english, length: length);

    return m.sentence;
  }

  /// Validates a mnemonic sentence (English wordlist only).
  ///
  /// Returns `true` if the mnemonic is valid, otherwise `false`.
  static bool validateMnemonic(List<String> words) {
    try {
      bip39.Mnemonic.fromSentence(words.join(' '), bip39.Language.english);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Checks whether a word exists in the English BIP-39 wordlist.
  static bool isValidWord(String word) {
    return enWordlist.contains(word);
  }
}
