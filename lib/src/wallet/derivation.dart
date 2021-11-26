/// BIP44 https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki
///
/// m / purpose' / coin_type' / account' / change / address_index
class Derivation {
  static const String coinType = '73404';
  static const String derivationPath = "m/44'/$coinType'";

  static String getDerivationAccount([int account = 0]) {
    return derivationPath + "/$account'";
  }
}
