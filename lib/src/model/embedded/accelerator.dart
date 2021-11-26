import 'package:znn_sdk_dart/src/model/embedded/common.dart';
import 'package:znn_sdk_dart/src/model/primitives.dart';
import 'package:znn_sdk_dart/src/utils/utils.dart';

class Phase extends BaseProject {
  Phase({
    required Hash id,
    required String name,
    required String description,
    required String url,
    required int fundsNeeded,
    required int creationTimestamp,
    required int status,
    required VoteBreakdown voteBreakdown,
  }) : super(
          id: id,
          name: name,
          description: description,
          url: url,
          fundsNeeded: fundsNeeded,
          creationTimestamp: creationTimestamp,
          statusInt: status,
          voteBreakdown: voteBreakdown,
        );

  factory Phase.fromJson(Map<String, dynamic> json) => Phase(
        id: Hash.parse(json['id']),
        name: json['name'],
        description: json['description'],
        url: json['url'],
        fundsNeeded: json['fundsNeeded'],
        creationTimestamp: json['creationTimestamp'],
        status: json['status'],
        voteBreakdown: VoteBreakdown.fromJson(json['votes']),
      );

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id.toString();
    data['name'] = name;
    data['description'] = description;
    data['url'] = url;
    data['fundsNeeded'] = fundsNeeded;
    data['creationTimestamp'] = creationTimestamp;
    data['status'] = statusInt;
    data['votes'] = voteBreakdown.toString();
    return data;
  }
}

class Project extends BaseProject {
  Address owner;
  List<Hash> phaseIds;
  List<Phase> phases;
  late double _fundsReceived;
  late double _fundsToCollect;

  Project({
    required Hash id,
    required String name,
    required this.owner,
    required String description,
    required String url,
    required int fundsNeeded,
    required int creationTimestamp,
    required int status,
    required this.phaseIds,
    required VoteBreakdown voteBreakdown,
    required this.phases,
  }) : super(
          id: id,
          name: name,
          description: description,
          url: url,
          fundsNeeded: fundsNeeded,
          creationTimestamp: creationTimestamp,
          statusInt: status,
          voteBreakdown: voteBreakdown,
        ) {
    _fundsReceived = phases
        .where((element) => element.status == BaseProjectStatus.paid)
        .fold<double>(
            0.0,
            (previousValue, phase) =>
                previousValue + phase.fundsNeededWithDecimals);
    _fundsToCollect = fundsNeededWithDecimals - _fundsReceived;
  }

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: Hash.parse(json['id']),
        owner: Address.parse(json['owner']),
        name: json['name'],
        description: json['description'],
        url: json['url'],
        fundsNeeded: json['fundsNeeded'],
        creationTimestamp: json['creationTimestamp'],
        status: json['status'],
        voteBreakdown: VoteBreakdown.fromJson(json['votes']),
        phases: (json['phases'] as List).fold<List<Phase>>([],
            (previousValue, element) {
          previousValue.add(Phase.fromJson(element));
          return previousValue;
        }),
        phaseIds: (json['PhaseIds'] as List).fold<List<Hash>>([],
            (previousValue, element) {
          previousValue.add(Hash.parse(element));
          return previousValue;
        }),
      );

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id.toString();
    data['owner'] = owner.toString();
    data['name'] = name;
    data['description'] = description;
    data['url'] = url;
    data['fundsNeeded'] = fundsNeeded;
    data['creationTimestamp'] = creationTimestamp;
    data['status'] = statusInt;
    data['phaseIds'] = phaseIds.toString();
    return data;
  }

  double get fundsReceived => _fundsReceived;

  double get fundsToCollect => _fundsToCollect;

  int? getUnrequestedFunds() {
    var amount = 0;
    phases.forEach((phase) {
      amount += phase.fundsNeeded;
    });
    return fundsNeeded - amount;
  }

  int getPaidFunds() {
    var amount = 0;
    phases.forEach((phase) {
      if (phase.status.index == BaseProjectStatus.paid.index) {
        amount += phase.fundsNeeded;
      }
    });
    return amount;
  }

  int getWaitingFunds() {
    if (phases.isEmpty) return 0;
    var lastPhase = phases[phases.length - 1];
    if (lastPhase.status.index == BaseProjectStatus.active.index) {
      return lastPhase.fundsNeeded;
    }
    return 0;
  }

  Phase? findPhaseById(Hash id) {
    for (var i = 0; i < phaseIds.length; i++) {
      if (id.toString() == phaseIds[i].toString()) {
        return phases[i];
      }
    }
    return null;
  }

  Phase? getLastPhase() {
    if (phases.isEmpty) return null;
    return phases[phases.length - 1];
  }
}

class ProjectList {
  int count;
  List<Project> list;

  ProjectList.fromJson(Map<String, dynamic> json)
      : count = json['count'],
        list = (json['list'] as List).map((j) => Project.fromJson(j)).toList();

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'count': count,
      'list': list.map((v) => v.toJson()).toList()
    };
  }

  Project? findId(Hash id) {
    for (var i = 0; i < list.length; i++) {
      if (list[i].id.toString() == id.toString()) {
        return list[i];
      }
    }
    return null;
  }

  Project? findProjectByPhaseId(Hash id) {
    for (var i = 0; i < list.length; i++) {
      for (var j = 0; j < list[i].phaseIds.length; i++) {
        if (id.toString() == list[i].phaseIds[j].toString()) return list[i];
      }
    }
    return null;
  }
}

abstract class BaseProject {
  Hash id;
  String name;
  String description;
  String url;
  int fundsNeeded;
  int creationTimestamp;
  int statusInt;
  VoteBreakdown voteBreakdown;

  BaseProject({
    required this.id,
    required this.name,
    required this.description,
    required this.url,
    required this.fundsNeeded,
    required this.creationTimestamp,
    required this.statusInt,
    required this.voteBreakdown,
  });

  BaseProjectStatus get status {
    if (statusInt >= BaseProjectStatus.voting.index &&
        statusInt <= BaseProjectStatus.closed.index) {
      return BaseProjectStatus.values[statusInt];
    }
    return BaseProjectStatus.wrongStatus;
  }

  num get fundsNeededWithDecimals =>
      AmountUtils.addDecimals(fundsNeeded, znnDecimals);
}

enum BaseProjectStatus { voting, active, paid, closed, wrongStatus }

enum BaseProjectVote {
  yes,
  no,
  abstain,
}
