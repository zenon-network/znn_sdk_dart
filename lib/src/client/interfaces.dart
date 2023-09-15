abstract class Client {
  int get protocolVersion;

  int get chainIdentifier;

  Future sendRequest(String method, [parameters]);
}
