import 'package:znn_sdk_dart/src/model/embedded/common.dart';
import 'package:znn_sdk_dart/src/model/primitives.dart';
import 'package:znn_sdk_dart/src/utils/utils.dart';

class Phase extends AcceleratorProject {
  Hash projectId;
  int acceptedTimestamp;

  Phase({
    required Hash id,
    required Hash projectId,
    required String name,
    required String description,
    required String url,
    required BigInt znnFundsNeeded,
    required BigInt qsrFundsNeeded,
    required int creationTimestamp,
    required int acceptedTimestamp,
    required int status,
    required VoteBreakdown voteBreakdown,
  })  : this.projectId = projectId,
        this.acceptedTimestamp = acceptedTimestamp,
        super(
          id: id,
          name: name,
          description: description,
          url: url,
          znnFundsNeeded: znnFundsNeeded,
          qsrFundsNeeded: qsrFundsNeeded,
          creationTimestamp: creationTimestamp,
          statusInt: status,
          voteBreakdown: voteBreakdown,
        );

  factory Phase.fromJson(Map<String, dynamic> json) => Phase(
        id: Hash.parse(json['phase']['id']),
        projectId: Hash.parse(json['phase']['projectID']),
        name: json['phase']['name'],
        description: json['phase']['description'],
        url: json['phase']['url'],
        znnFundsNeeded: BigInt.parse(json['phase']['znnFundsNeeded']),
        qsrFundsNeeded: BigInt.parse(json['phase']['qsrFundsNeeded']),
        creationTimestamp: json['phase']['creationTimestamp'],
        acceptedTimestamp: json['phase']['acceptedTimestamp'],
        status: json['phase']['status'],
        voteBreakdown: VoteBreakdown.fromJson(json['votes']),
      );

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id.toString();
    data['projectId'] = projectId.toString();
    data['name'] = name;
    data['description'] = description;
    data['url'] = url;
    data['znnFundsNeeded'] = znnFundsNeeded.toString();
    data['qsrFundsNeeded'] = qsrFundsNeeded.toString();
    data['creationTimestamp'] = creationTimestamp;
    data['acceptedTimestamp'] = acceptedTimestamp;
    data['status'] = statusInt;
    data['votes'] = voteBreakdown.toString();
    return data;
  }
}

class Project extends AcceleratorProject {
  Address owner;
  List<Hash> phaseIds;
  List<Phase> phases;
  int lastUpdateTimestamp;

  Project({
    required Hash id,
    required String name,
    required this.owner,
    required String description,
    required String url,
    required BigInt znnFundsNeeded,
    required BigInt qsrFundsNeeded,
    required int creationTimestamp,
    required int lastUpdateTimestamp,
    required int status,
    required this.phaseIds,
    required VoteBreakdown voteBreakdown,
    required this.phases,
  })  : this.lastUpdateTimestamp = lastUpdateTimestamp,
        super(
          id: id,
          name: name,
          description: description,
          url: url,
          znnFundsNeeded: znnFundsNeeded,
          qsrFundsNeeded: qsrFundsNeeded,
          creationTimestamp: creationTimestamp,
          statusInt: status,
          voteBreakdown: voteBreakdown,
        ) {}

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: Hash.parse(json['id']),
        owner: Address.parse(json['owner']),
        name: json['name'],
        description: json['description'],
        url: json['url'],
        znnFundsNeeded: BigInt.parse(json['znnFundsNeeded']),
        qsrFundsNeeded: BigInt.parse(json['qsrFundsNeeded']),
        creationTimestamp: json['creationTimestamp'],
        lastUpdateTimestamp: json['lastUpdateTimestamp'],
        status: json['status'],
        voteBreakdown: VoteBreakdown.fromJson(json['votes']),
        phases: (json['phases'] as List).fold<List<Phase>>([],
            (previousValue, element) {
          previousValue.add(Phase.fromJson(element));
          return previousValue;
        }),
        phaseIds: (json['phaseIds'] as List).fold<List<Hash>>([],
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
    data['znnFundsNeeded'] = znnFundsNeeded.toString();
    data['qsrFundsNeeded'] = qsrFundsNeeded.toString();
    data['creationTimestamp'] = creationTimestamp;
    data['lastUpdateTimestamp'] = lastUpdateTimestamp;
    data['status'] = statusInt;
    data['phaseIds'] = phaseIds.toString();
    return data;
  }

  BigInt getPaidZnnFunds() {
    BigInt amount = BigInt.zero;
    phases.forEach((phase) {
      if (phase.status == AcceleratorProjectStatus.paid) {
        amount += phase.znnFundsNeeded;
      }
    });
    return amount;
  }

  BigInt getPendingZnnFunds() {
    if (phases.isEmpty) return BigInt.zero;
    var lastPhase = getLastPhase();
    if (lastPhase != null &&
        lastPhase.status == AcceleratorProjectStatus.active) {
      return lastPhase.znnFundsNeeded;
    }
    return BigInt.zero;
  }

  BigInt getRemainingZnnFunds() {
    if (phases.isEmpty) return znnFundsNeeded;
    return znnFundsNeeded - getPaidZnnFunds();
  }

  BigInt getTotalZnnFunds() {
    return znnFundsNeeded;
  }

  BigInt getPaidQsrFunds() {
    BigInt amount = BigInt.zero;
    phases.forEach((phase) {
      if (phase.status == AcceleratorProjectStatus.paid) {
        amount += phase.qsrFundsNeeded;
      }
    });
    return amount;
  }

  BigInt getPendingQsrFunds() {
    if (phases.isEmpty) return BigInt.zero;
    var lastPhase = getLastPhase();
    if (lastPhase != null &&
        lastPhase.status == AcceleratorProjectStatus.active) {
      return lastPhase.qsrFundsNeeded;
    }
    return BigInt.zero;
  }

  BigInt getRemainingQsrFunds() {
    if (phases.isEmpty) return qsrFundsNeeded;
    return qsrFundsNeeded - getPaidQsrFunds();
  }

  BigInt getTotalQsrFunds() {
    return qsrFundsNeeded;
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

abstract class AcceleratorProject {
  Hash id;
  String name;
  String description;
  String url;
  BigInt znnFundsNeeded;
  BigInt qsrFundsNeeded;
  int creationTimestamp;
  int statusInt;
  VoteBreakdown voteBreakdown;

  AcceleratorProject({
    required this.id,
    required this.name,
    required this.description,
    required this.url,
    required this.znnFundsNeeded,
    required this.qsrFundsNeeded,
    required this.creationTimestamp,
    required this.statusInt,
    required this.voteBreakdown,
  });

  AcceleratorProjectStatus get status =>
      AcceleratorProjectStatus.values[statusInt];

  num get znnFundsNeededWithDecimals =>
      AmountUtils.addDecimals(znnFundsNeeded, znnDecimals);

  num get qsrFundsNeededWithDecimals =>
      AmountUtils.addDecimals(qsrFundsNeeded, qsrDecimals);
}

enum AcceleratorProjectStatus {
  voting,
  active,
  paid,
  closed,
  completed,
}

enum AcceleratorProjectVote {
  yes,
  no,
  abstain,
}
