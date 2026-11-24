import 'package:znn_sdk_dart/src/global.dart';

final noConnectionException =
    ZnnSdkException('No connection to the Zenon full node');

/// Normalized JSON-RPC error carrying the failed request's context.
class RpcError implements Exception {
  final String method;
  final dynamic params;
  final int? code;
  final String message;
  final dynamic data;

  RpcError(
      {required this.method,
      this.params,
      this.code,
      required this.message,
      this.data});

  @override
  String toString() {
    return 'RPC error${code != null ? ' $code' : ''} for $method: $message';
  }
}
