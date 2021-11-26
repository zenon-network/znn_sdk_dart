import 'dart:convert';

import 'package:znn_sdk_dart/src/abi/abi_types.dart';
import 'package:znn_sdk_dart/src/crypto/crypto.dart';
import 'package:znn_sdk_dart/src/global.dart';
import 'package:znn_sdk_dart/src/utils/utils.dart';

enum TypeEnum { function }

class Param {
  bool indexed = false;
  String? name;
  late AbiType type;

  static List decodeList(List<Param> params, List encoded) {
    var result = List.empty(growable: true);

    var offset = 0;
    for (var param in params) {
      Object decoded = param.type.isDynamicType()
          ? param.type.decode(
              encoded as List<int>, IntType.decodeInt(encoded, offset).toInt())
          : param.type.decode(encoded as List<int>, offset);
      result.add(decoded);

      offset += param.type.getFixedSize()!;
    }

    return result;
  }
}

class Entry {
  String? name;
  List<Param>? inputs;
  TypeEnum? type;

  Entry(String name, List<Param> inputs, TypeEnum type) {
    this.name = name;
    this.inputs = inputs;
    this.type = type;
  }

  String formatSignature() {
    var paramsTypes = '';
    for (var param in inputs!) {
      paramsTypes = paramsTypes + param.type.getCanonicalName()! + ',';
    }

    var x = paramsTypes;
    if (x.endsWith(',')) x = x.substring(0, x.length - 1);
    return name! + '(' + x + ')';
  }

  List<int> fingerprintSignature() {
    return Crypto.digest(utf8.encode(formatSignature()));
  }

  List<int> encodeSignature() {
    return fingerprintSignature();
  }

  List<int> encodeArguments(var args) {
    if (args.length > inputs!.length) throw Error();
    var staticSize = 0;
    var dynamicCnt = 0;
    for (var i = 0; i < args.length; i++) {
      var type = inputs![i].type;
      if (type.isDynamicType()) {
        dynamicCnt++;
      }
      staticSize += type.getFixedSize()!;
    }

    var bb =
        List<List<int>?>.filled(args.length + dynamicCnt, [], growable: true);
    for (var i = 0; i < args.length + dynamicCnt; i++) {
      bb[i] = <int>[];
    }

    for (var curDynamicPtr = staticSize, curDynamicCnt = 0, i = 0;
        i < args.length;
        i++) {
      var type = inputs![i].type;
      if (type.isDynamicType()) {
        var dynBB = type.encode(args[i]);
        bb[i] = IntType.encodeInt(curDynamicPtr);
        bb[args.length + curDynamicCnt] = dynBB;
        curDynamicCnt++;
        curDynamicPtr += dynBB.length;
      } else {
        bb[i] = type.encode(args[i]);
      }
    }
    var x = BytesUtils.merge(bb);
    return x;
  }
}

class AbiFunction extends Entry {
  static int encodedSignLength = 4;

  AbiFunction(String name, List<Param> inputs)
      : super(
          name,
          inputs,
          TypeEnum.function,
        );

  List decode(List<int> encoded) {
    return Param.decodeList(
        inputs!, encoded.sublist(encodedSignLength, encoded.length));
  }

  List<int> encode(dynamic args) {
    var l1 = encodeArguments(args);
    return BytesUtils.merge([encodeSignature(), l1]);
  }

  @override
  List<int> encodeSignature() {
    return extractSignature(super.encodeSignature());
  }

  static List<int> extractSignature(List<int> data) {
    return data.sublist(0, encodedSignLength);
  }
}

class Abi {
  late List<Entry> entries = <Entry>[];

  static List<Entry> _parseEntries(var j) {
    var entries = <Entry>[];

    j = jsonDecode(j);
    for (var json in j) {
      String? name;
      var inputs = <Param>[];

      name = json['name'];
      if (json['type'] != 'function') {
        throw ZnnSdkException('Only ABI functions supported');
      }
      if (json['inputs'] != null) {
        for (var x in json['inputs']) {
          var p = Param();
          p.name = x['name'];
          p.type = AbiType.getType(x['type']);
          inputs.add(p);
        }
      }

      entries.add(AbiFunction(name!, inputs));
    }
    return entries;
  }

  Abi(var entries) {
    this.entries = entries;
  }

  Abi.fromJson(var j) : entries = Abi._parseEntries(j);

  List<int> encodeFunction(String name, var args) {
    AbiFunction? f;
    entries.forEach((element) {
      if (element.name == name) {
        f = AbiFunction(element.name!, element.inputs!);
      }
    });
    return f!.encode(args);
  }

  dynamic decodeFunction(List<int> encoded) {
    AbiFunction? f;
    entries.forEach((element) {
      if (AbiFunction.extractSignature(element.encodeSignature()).toString() ==
          AbiFunction.extractSignature(encoded).toString()) {
        f = AbiFunction(element.name!, element.inputs!);
      }
    });

    return f!.decode(encoded);
  }
}
