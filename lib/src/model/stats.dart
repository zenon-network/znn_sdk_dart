class Peer {
  String publicKey;
  String ip;

  Peer.fromJson(Map<String, dynamic> json)
      : publicKey = json['publicKey'],
        ip = json['ip'];
}

class NetworkInfo {
  int numPeers;
  Peer self;
  List<Peer> peers;

  NetworkInfo.fromJson(Map<String, dynamic> json)
      : numPeers = json['numPeers'],
        self = Peer.fromJson(json['self']),
        peers = (List<Map<String, dynamic>>.from(json['peers'])).map((f) => Peer.fromJson(f)).toList();
}

class ProcessInfo {
  final String commit;
  final String version;

  ProcessInfo.fromJson(Map<String, dynamic> json)
      : commit = json['commit'],
        version = json['version'];
}

class OsInfo {
  String os;
  String platform;
  String platformVersion;
  String kernelVersion;
  int memoryTotal;
  int memoryFree;
  int numCPU;
  int numGoroutine;

  OsInfo.fromJson(Map<String, dynamic> json)
      : os = json['os'],
        platform = json['platform'],
        platformVersion = json['platform'],
        kernelVersion = json['kernelVersion'],
        memoryTotal = json['memoryTotal'],
        memoryFree = json['memoryFree'],
        numCPU = json['numCPU'],
        numGoroutine = json['numGoroutine'];
}

enum SyncState { unknown, syncing, syncDone, notEnoughPeers }

class SyncInfo {
  SyncState state;
  int currentHeight;
  int targetHeight;

  SyncInfo.fromJson(Map<String, dynamic> json)
      : state = SyncState.values[json['state'] ?? 0],
        currentHeight = json['currentHeight'],
        targetHeight = json['targetHeight'];
}
