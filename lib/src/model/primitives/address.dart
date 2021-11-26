import 'package:collection/collection.dart';
import 'package:sha3/sha3.dart';
import 'package:znn_sdk_dart/src/model/primitives/bech32.dart';

final Address emptyAddress =
    Address.parse('z1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqsggv2f');
final Address plasmaAddress =
    Address.parse('z1qxemdeddedxplasmaxxxxxxxxxxxxxxxxsctrp');
final Address pillarAddress =
    Address.parse('z1qxemdeddedxpyllarxxxxxxxxxxxxxxxsy3fmg');
final Address tokenAddress =
    Address.parse('z1qxemdeddedxt0kenxxxxxxxxxxxxxxxxh9amk0');
final Address sentinelAddress =
    Address.parse('z1qxemdeddedxsentynelxxxxxxxxxxxxxwy0r2r');
final Address swapAddress =
    Address.parse('z1qxemdeddedxswapxxxxxxxxxxxxxxxxxxl4yww');
final Address stakeAddress =
    Address.parse('z1qxemdeddedxstakexxxxxxxxxxxxxxxxjv8v62');
final Address sporkAddress =
    Address.parse('z1qxemdeddedxsp0rkxxxxxxxxxxxxxxxx956u48');
final Address acceleratorAddress =
    Address.parse('z1qxemdeddedxaccelerat0rxxxxxxxxxxp4tk22');

final List<Address> embeddedContractAddresses = [
  plasmaAddress,
  pillarAddress,
  tokenAddress,
  sentinelAddress,
  swapAddress,
  stakeAddress,
  acceleratorAddress,
];

class Address {
  static const String prefix = 'z';
  static const int addressLength = 40;
  static const int userByte = 0;
  static const int contractByte = 1;
  static const int coreSize = 20;

  String? hrp;
  List<int>? core;

  Address(String hrp, List<int> core) {
    this.hrp = hrp;
    this.core = core;
  }

  Address.parse(String address) {
    var bech32 = bech32Codec.decode(address, addressLength);
    hrp = bech32.hrp;
    core = convertBech32Bits(bech32.data, 5, 8, false);
  }

  @override
  String toString() {
    var bech32 = Bech32(hrp!, convertBech32Bits(core!, 8, 5, true));
    var addressStr = bech32Codec.encode(bech32, addressLength);
    return addressStr;
  }

  String toShortString() {
    var longString = toString();
    return longString.substring(0, 7) +
        '...' +
        longString.substring(longString.length - 6);
  }

  bool equals(Address address) {
    return (hrp == address.hrp) &&
        DeepCollectionEquality().equals(core, address.core);
  }

  bool operator ==(Object other) =>
      other is Address &&
      other.runtimeType == runtimeType &&
      other.hrp == hrp &&
      DeepCollectionEquality().equals(other.core, core);

  @override
  int get hashCode => toString().hashCode;

  bool isEmbedded() => embeddedContractAddresses.contains(this);

  static bool isValid(String address) {
    try {
      var a = Address.parse(address);
      return a.toString() == address;
    } catch (_) {
      return false;
    }
  }

  static Address fromPublicKey(List<int> publicKey) {
    var sha3 = SHA3(NORMAL_BITS[1], SHA3_PADDING, SHA3_PADDING[1]);
    sha3.update(publicKey);
    var digest = sha3.digest().sublist(0, 19);

    return Address('z', [userByte, ...digest]);
  }

  List<int>? getBytes() {
    return core;
  }

  int compareTo(Address otherAddress) =>
      toString().compareTo(otherAddress.toString());
}
