import 'package:znn_sdk_dart/src/model/primitives.dart';

class Spork {
  Hash id;
  String name;
  String description;
  bool activated;
  int enforcementHeight;

  Spork.fromJson(Map<String, dynamic> json)
      : id = Hash.parse(json['id']),
        name = json['name'],
        description = json['description'],
        activated = json['activated'],
        enforcementHeight = json['enforcementHeight'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'activated': activated,
        'enforcementHeight': enforcementHeight
      };
}

class SporkList {
  int count;
  List<Spork> list;

  SporkList({required this.count, required this.list});

  SporkList.fromJson(Map<String, dynamic> json)
      : count = json['count'],
        list = (json['list'] as List)
            .map((entry) => Spork.fromJson(entry))
            .toList();

  Map<String, dynamic> toJson() =>
      {'count': count, 'list': list.map((v) => v.toJson()).toList()};
}