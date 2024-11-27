import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:hex/hex.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/digests/sha512.dart';
import 'package:pointycastle/macs/hmac.dart';

typedef HashFunc = Future<Uint8List> Function(Uint8List? m);

class KeyData {
  List<int>? key;
  List<int>? chainCode;

  KeyData({this.key, this.chainCode});
}

const String ed25519Curve = 'ed25519 seed';
const int hardenedOffset = 0x80000000;

class Ed25519 {
  static final int b = 256;
  static final BigInt q = BigInt.parse(
      '57896044618658097711785492504343953926634992332820282019728792003956564819949');
  static final BigInt qm2 = BigInt.parse(
      '57896044618658097711785492504343953926634992332820282019728792003956564819947');
  static final BigInt qp3 = BigInt.parse(
      '57896044618658097711785492504343953926634992332820282019728792003956564819952');
  static final BigInt l = BigInt.parse(
      '7237005577332262213973186563042994240857116359379907606001950938285454250989');
  static final BigInt d = BigInt.parse(
      '-4513249062541557337682894930092624173785641285191125241628941591882900924598840740');
  static final BigInt I = BigInt.parse(
      '19681161376707505956807079304988542015446066515923890162744021073123829784752');
  static final BigInt by = BigInt.parse(
      '46316835694926478169428394003475163141307993866256225615783033603165251855960');
  static final BigInt bx = BigInt.parse(
      '15112221349535400772501151409588531511454012693041857206046113283949847762202');
  static final List<BigInt> B = [bx % q, by % q];
  static final BigInt un = BigInt.parse(
      '57896044618658097711785492504343953926634992332820282019728792003956564819967');

  static final BigInt zero = BigInt.from(0);
  static final BigInt one = BigInt.from(1);
  static final BigInt two = BigInt.from(2);
  static final BigInt eight = BigInt.from(8);

  static Future<Uint8List> hash(HashFunc f, Uint8List? m) {
    return f(m);
  }

  static BigInt expmod(BigInt b, BigInt e, BigInt m) {
    if (e == zero) {
      return one;
    }
    var t = expmod(b, e ~/ two, m).pow(2) % m;
    if (e % two != zero) {
      t = t * b % m;
    }
    return t;
  }

  static BigInt inv(BigInt x) {
    return expmod(x, qm2, q);
  }

  static BigInt xrecover(BigInt y) {
    var y2 = y * y;
    var xx = (y2 - one) * (inv(d * y2 + one));
    var x = expmod(xx, qp3 ~/ eight, q);
    if (!((x * x - xx) % q == zero)) x = x * I % q;
    if (!(x % two == zero)) x = q - x;
    return x;
  }

  static List<BigInt> edwards(List<BigInt> P, List<BigInt> Q) {
    var x1 = P[0];
    var y1 = P[1];
    var x2 = Q[0];
    var y2 = Q[1];
    var dtemp = d * x1 * x2 * y1 * y2;
    var x3 = ((x1 * y2 + x2 * y1)) * inv(one + dtemp);
    var y3 = ((y1 * y2 + x1 * x2)) * inv(one - dtemp);

    return [x3 % q, y3 % q];
  }

  static List<BigInt> scalarmult(List<BigInt> P, BigInt e) {
    if (e == zero) {
      return [zero, one];
    }
    var Q = scalarmult(P, e ~/ two);
    Q = edwards(Q, Q);
    if (e % two != zero) Q = edwards(Q, P);
    return Q;
  }

  static Uint8List encodeint(BigInt y) {
    return _toBytes(y);
  }

  static Uint8List encodepoint(List<BigInt> P) {
    var x = P[0];
    var y = P[1];
    var out = encodeint(y);
    out[out.length - 1] |= (x % two != zero) ? 0x80 : 0;
    return out;
  }

  static int bit(Uint8List h, int i) {
    return h[i ~/ 8] >> (i % 8) & 1;
  }

  static Future<Uint8List> publickey(HashFunc f, Uint8List sk) async {
    var h = await hash(f, sk);
    var a = two.pow(b - 2);
    for (var i = 3; i < (b - 2); i++) {
      var apart = two.pow(i) * BigInt.from(bit(h, i));
      a = a + apart;
    }
    var A = scalarmult(B, a);
    return encodepoint(A);
  }

  static Future<BigInt> hint(HashFunc f, Uint8List m) async {
    var h = await hash(f, m);
    var hsum = zero;
    for (var i = 0; i < 2 * b; i++) {
      hsum = hsum + (two.pow(i) * BigInt.from(bit(h, i)));
    }
    return hsum;
  }

  static Future<Uint8List> signature(
      HashFunc f, Uint8List m, Uint8List? sk, Uint8List pk) async {
    var h = await hash(f, sk);
    var a = two.pow(b - 2);
    for (var i = 3; i < (b - 2); i++) {
      a = a + (two.pow(i) * BigInt.from(bit(h, i)));
    }

    var rsub = Uint8List(b ~/ 8 + m.length);
    var j = 0;
    for (var i = b ~/ 8; i < b ~/ 8 + (b ~/ 4 - b ~/ 8); i++) {
      rsub[j] = h[i];
      j++;
    }
    for (var i = 0; i < m.length; i++) {
      rsub[j] = m[i];
      j++;
    }
    var r = await hint(f, rsub);
    var R = scalarmult(B, r);
    var stemp = Uint8List(32 + pk.length + m.length);

    var point = encodepoint(R);
    j = 0;
    for (var i = 0; i < point.length; i++) {
      stemp[j] = point[i];
      j++;
    }
    for (var i = 0; i < pk.length; i++) {
      stemp[j] = pk[i];
      j++;
    }
    for (var i = 0; i < m.length; i++) {
      stemp[j] = m[i];
      j++;
    }
    var x = await hint(f, stemp);
    var S = (r + (x * a)) % l;
    var ur = encodepoint(R);
    var us = encodeint(S);
    var out = Uint8List(ur.length + us.length);
    j = 0;
    for (var i = 0; i < ur.length; i++) {
      out[j] = ur[i];
      j++;
    }
    for (var i = 0; i < us.length; i++) {
      out[j] = us[i];
      j++;
    }
    return out;
  }

  static bool isoncurve(List<BigInt> P) {
    var x = P[0];
    var y = P[1];

    var xx = x * x;
    var yy = y * y;
    var dxxyy = d * yy * xx;
    return (-xx + yy - one - dxxyy) % q == zero;
  }

  static BigInt decodeint(Uint8List s) {
    return _fromBytes(s) & un;
  }

  static List<BigInt> decodepoint(Uint8List s) {
    var ybyte = Uint8List(s.length);
    for (var i = 0; i < s.length; i++) {
      ybyte[i] = s[s.length - 1 - i];
    }
    var fb = _fromBytes(s);
    var y = fb & un;
    var x = xrecover(y);
    if ((x % two != zero) ? 1 as bool : 0 != bit(s, b - 1)) {
      x = q - x;
    }
    var P = <BigInt>[x, y];
    assert(isoncurve(P));
    return P;
  }

  static Future<bool> checkvalid(
      HashFunc f, Uint8List s, Uint8List m, Uint8List pk) async {
    assert(s.length == b ~/ 4);
    assert(pk.length == b ~/ 8);

    var rbyte = _copyRange(s, 0, b ~/ 8);
    var R = decodepoint(rbyte);
    var A = decodepoint(pk);

    var sbyte = _copyRange(s, b ~/ 8, b ~/ 4);
    var S = decodeint(sbyte);

    var stemp = Uint8List(32 + pk.length + m.length);
    var point = encodepoint(R);
    var j = 0;
    for (var i = 0; i < point.length; i++) {
      stemp[j] = point[i];
      j++;
    }
    for (var i = 0; i < pk.length; i++) {
      stemp[j] = pk[i];
      j++;
    }
    for (var i = 0; i < m.length; i++) {
      stemp[j] = m[i];
      j++;
    }
    var x = await hint(f, stemp);
    var h = x;
    var ra = scalarmult(B, S);
    var rb = edwards(R, scalarmult(A, h));
    if (!(ra[0] == rb[0]) || !(ra[1] == rb[1])) {
      return false;
    }
    return true;
  }

  static BigInt _fromBytes(Uint8List bytes) {
    BigInt read(int start, int end) {
      if (end - start <= 4) {
        var result = 0;
        for (var i = end - 1; i >= start; i--) {
          result = result * 256 + bytes[i];
        }
        return BigInt.from(result);
      }
      var mid = start + ((end - start) >> 1);
      var result = read(start, mid) +
          read(mid, end) * (BigInt.one << ((mid - start) * 8));
      return result;
    }

    return read(0, bytes.length);
  }

  static Uint8List _toBytes(BigInt number) {
    var bytes = 32;
    var b256 = BigInt.from(256);
    var result = Uint8List(bytes);
    for (var i = 0; i < bytes; i++) {
      result[i] = number.remainder(b256).toInt();
      number = number >> 8;
    }
    return result;
  }

  static Uint8List _copyRange(Uint8List src, int from, int to) {
    var dst = Uint8List(to - from);
    var j = 0;
    for (var i = from; i < to; i++) {
      dst[j] = src[i];
      j++;
    }
    return dst;
  }

  static final _curveBytes = utf8.encode(ed25519Curve);
  static final _pathRegex = RegExp(r"^(m\/)?(\d+'?\/)*\d+'?$");

  const Ed25519();

  static KeyData _getKeys(Uint8List data, Uint8List keyParameter) {
    final digest = SHA512Digest();
    final hmac = HMac(digest, 128)..init(KeyParameter(keyParameter));
    final i = hmac.process(data);
    final il = i.sublist(0, 32);
    final ir = i.sublist(32);
    return KeyData(key: il, chainCode: ir);
  }

  static KeyData _getCKDPriv(KeyData data, int index) {
    var dataBytes = Uint8List(37);
    dataBytes[0] = 0x00;
    dataBytes.setRange(1, 33, data.key!);
    dataBytes.buffer.asByteData().setUint32(33, index);
    return _getKeys(dataBytes, data.chainCode as Uint8List);
  }

  static KeyData getMasterKeyFromSeed(String seed) {
    final seedBytes = HEX.decode(seed);
    return _getKeys(seedBytes as Uint8List, Ed25519._curveBytes);
  }

  static KeyData derivePath(String path, String seed) {
    if (!Ed25519._pathRegex.hasMatch(path)) {
      throw ArgumentError(
          'Invalid derivation path. Expected BIP32 path format');
    }
    var master = getMasterKeyFromSeed(seed);
    var segments = path.split('/');
    segments = segments.sublist(1);

    return segments.fold<KeyData>(master, (prevKeyData, indexStr) {
      var index = int.parse(indexStr.substring(0, indexStr.length - 1));
      return _getCKDPriv(prevKeyData, index + hardenedOffset);
    });
  }
}
