import 'dart:async';
import 'dart:io';

import 'package:json_rpc_2/json_rpc_2.dart' as jsonrpc2;
import 'package:json_rpc_2/src/utils.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:znn_sdk_dart/src/client/client.dart';
import 'package:znn_sdk_dart/src/global.dart';

enum WebsocketStatus { uninitialized, connecting, running, stopped }

typedef ConnectionEstablishedCallback = void Function(
    Stream<Map<String, dynamic>?> allResponseBroadcaster);

class WsClient implements Client {
  jsonrpc2.Client? _wsRpc2Client;

  final List<ConnectionEstablishedCallback> _onConnectionCallbacks;

  Stream<Map<String, dynamic>?>? _wsResponseBroadcaster;

  WebsocketStatus _websocketIntendedState;

  String url = 'ws://peers.zenon.network:35998';
  int _maxRestarts = 3;
  int _maxTimeouts = 3;
  int _restarts = 0;
  int _timeouts = 0;
  Duration _timeoutDuration = Duration(seconds: 5);
  Duration _pingIntervalDuration = Duration(seconds: 5);
  Duration _restartDelayDuration = Duration(seconds: 5);

  StreamController<bool> restartedStreamController =
      StreamController.broadcast();

  bool? _lastRestartedEvent;

  Stream<bool> get restartedStream =>
      restartedStreamController.stream.asBroadcastStream();

  WsClient()
      : _websocketIntendedState = WebsocketStatus.uninitialized,
        _onConnectionCallbacks = List.empty(growable: true);

  bool isClosed() {
    if (_wsRpc2Client != null) {
      return _wsRpc2Client!.isClosed;
    }
    return true;
  }

  void setConfig({
    required String url,
    int maxRestarts = 3,
    int maxTimeouts = 3,
    Duration timeoutDuration = const Duration(seconds: 5),
    Duration pingIntervalDuration = const Duration(seconds: 5),
    Duration restartDelayDuration = const Duration(seconds: 5),
  }) {
    if (maxRestarts <= 0) {
      throw ZnnSdkException('Invalid `maxRestarts` parameter value');
    }

    this.url = url;
    this._maxRestarts = maxRestarts;
    this._maxTimeouts = maxTimeouts;
    this._timeoutDuration = timeoutDuration;
    this._pingIntervalDuration = pingIntervalDuration;
    this._restartDelayDuration = restartDelayDuration;
  }

  void addOnConnectionEstablishedCallback(
      ConnectionEstablishedCallback callback) {
    if (_websocketIntendedState == WebsocketStatus.running) {
      callback(_wsResponseBroadcaster!);
    }
    _onConnectionCallbacks.add(callback);
  }

  Future<bool> initialize({bool retry = true}) async {
    logger.info('Initializing websocket connection ...');
    _websocketIntendedState = WebsocketStatus.connecting;

    do {
      var ws = WebSocket.connect(url).timeout(_timeoutDuration);

      try {
        var wsConnection = await ws;
        logger.info('Websocket connection successfully established');

        wsConnection.pingInterval = _pingIntervalDuration;
        var wsStream = jsonDocument
            .bind(IOWebSocketChannel(wsConnection).cast<String>())
            .transformStream(ignoreFormatExceptions);

        var stream = wsStream.stream.asBroadcastStream();
        _wsResponseBroadcaster = stream.cast<Map<String, dynamic>?>();
        _wsRpc2Client =
            jsonrpc2.Client.withoutJson(StreamChannel.withGuarantees(
          stream,
          wsStream.sink,
        ));

        _websocketIntendedState = WebsocketStatus.running;

        _wsRpc2Client!.listen().then((_) {
          restart();
        });
        _onConnectionCallbacks
            .forEach((callback) => callback(_wsResponseBroadcaster!));
        if (_lastRestartedEvent != null && !_lastRestartedEvent!) {
          restartedStreamController.sink.add(true);
        }
        return true;
      } on TimeoutException {
        _timeouts++;

        if (_timeouts >= _maxTimeouts) {
          _timeouts = 0;
          return false;
        }

        continue;
      } on SocketException {
        _lastRestartedEvent = false;

        if (retry == true) {
          _restarts++;

          if (_restarts >= _maxRestarts) {
            _restarts = 0;
            return false;
          }

          await Future.delayed(_restartDelayDuration);
        }
      }
    } while (retry);

    return false;
  }

  WebsocketStatus status() {
    return _websocketIntendedState;
  }

  void restart() async {
    if (_websocketIntendedState != WebsocketStatus.running) {
      return;
    }
    if (_wsRpc2Client != null && _wsRpc2Client!.isClosed == true) {
      logger.info('Restarting websocket connection ...');
      await initialize(retry: true);
      logger.info('Websocket connection successfully restarted');
    }
  }

  void stop() {
    if (_websocketIntendedState != WebsocketStatus.running) {
      return;
    }
    _websocketIntendedState = WebsocketStatus.stopped;

    logger.info('Websocket client closed');
    if (_wsRpc2Client != null && _wsRpc2Client!.isClosed == false) {
      _wsRpc2Client!.close().whenComplete(() {
        logger.info('Websocket client is now closed');
      });
    }
  }

  @override
  Future sendRequest(String method, [parameters]) {
    if (isClosed()) {
      throw noConnectionException;
    }
    return _wsRpc2Client!.sendRequest(method, parameters);
  }
}
