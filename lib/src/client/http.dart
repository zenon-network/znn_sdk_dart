import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:znn_sdk_dart/src/client/exceptions.dart';
import 'package:znn_sdk_dart/src/client/interfaces.dart';

/// JSON-RPC 2.0 client over HTTP/HTTPS.
///
/// Unlike [WsClient] this transport is stateless per request and does not
/// support subscriptions; use it for request/response RPC against a node's
/// HTTP endpoint.
class HttpRpcClient implements Client {
  final Uri url;
  final Duration timeout;
  final io.HttpClient _httpClient = io.HttpClient();
  int _requestId = 0;
  bool _closed = false;

  HttpRpcClient(String url, {this.timeout = const Duration(seconds: 30)})
      : url = Uri.parse(url);

  void stop() {
    _closed = true;
    _httpClient.close(force: true);
  }

  @override
  Future sendRequest(String method, [parameters]) async {
    if (_closed) {
      throw noConnectionException;
    }
    var payload = <String, dynamic>{
      'jsonrpc': '2.0',
      'id': ++_requestId,
      'method': method,
      'params': parameters ?? [],
    };

    Map<String, dynamic> body;
    try {
      body = await _post(method, parameters, payload).timeout(timeout);
    } on io.SocketException {
      throw noConnectionException;
    } on TimeoutException {
      throw RpcError(
          method: method,
          params: parameters,
          message: 'Request timed out after ${timeout.inMilliseconds} ms');
    }

    if (body.containsKey('error') && body['error'] != null) {
      var error = body['error'] as Map<String, dynamic>;
      throw RpcError(
          method: method,
          params: parameters,
          code: error['code'],
          message: error['message'] ?? 'unknown RPC error',
          data: error['data']);
    }
    return body['result'];
  }

  Future<Map<String, dynamic>> _post(
      String method, dynamic parameters, Map<String, dynamic> payload) async {
    var request = await _httpClient.postUrl(url);
    request.headers.contentType = io.ContentType.json;
    request.write(jsonEncode(payload));
    var response = await request.close();
    var text = await response.transform(utf8.decoder).join();
    if (response.statusCode != io.HttpStatus.ok) {
      throw RpcError(
          method: method,
          params: parameters,
          message: 'HTTP ${response.statusCode}',
          data: text);
    }
    try {
      var decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('response is not a JSON object');
      }
      return decoded;
    } on FormatException catch (e) {
      throw RpcError(
          method: method,
          params: parameters,
          message: 'Malformed JSON-RPC response: ${e.message}',
          data: text);
    }
  }
}
