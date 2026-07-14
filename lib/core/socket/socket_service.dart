import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io_client;
import '../constants/app_config.dart';

/// Singleton Socket.IO service — compatible with socket_io_client v3.x
/// and Socket.IO server v4.x (Engine.IO v4 protocol).
///
/// Usage:
///   SocketService.instance.connect();
///   SocketService.instance.telemetryStream.listen((data) { ... });
class SocketService {
  SocketService._();

  static final SocketService instance = SocketService._();

  io_client.Socket? _socket;

  // ─── Socket Logs Capture ──────────────────────────────────────────────────
  static final List<String> connectionLogs = [];
  static void Function()? _logListener;

  static void setLogListener(void Function()? listener) {
    _logListener = listener;
  }

  static void clearLogs() {
    connectionLogs.clear();
    _logListener?.call();
  }

  static void _log(String message) {
    final timestamp = DateTime.now().toLocal().toString().split(' ').last.substring(0, 8);
    final logLine = '[$timestamp] $message';
    connectionLogs.add(logLine);
    if (connectionLogs.length > 200) {
      connectionLogs.removeAt(0);
    }
    debugPrint(logLine);
    _logListener?.call();
  }

  // ──────────────────────────────────────────────────────────────────────────

  final _telemetryController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  Stream<Map<String, dynamic>> get telemetryStream =>
      _telemetryController.stream;

  Stream<bool> get connectionStream => _connectionController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // ─── Connect ──────────────────────────────────────────────────────────────

  void connect() {
    final url = AppConfig.socketUrl;

    // Jika socket sudah ada dan sudah terkoneksi, skip
    if (_socket != null && _socket!.connected) {
      _log('Already connected — id: ${_socket!.id}');
      return;
    }

    // Jika socket sudah ada tapi belum connect, destroy dulu
    if (_socket != null) {
      _log('Destroying existing socket instance...');
      _socket!.destroy();
      _socket = null;
    }

    _log('Connecting to $url ...');

    _socket = io_client.io(
      url,
      io_client.OptionBuilder()
          .setTransports(['websocket'])    // WAJIB: hindari polling
          .disableAutoConnect()            // kita panggil connect() manual
          .enableReconnection()
          .setReconnectionAttempts(999)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .build(),
    );

    // ── Event Listeners ─────────────────────────────────────────────────────

    _socket!.onConnect((_) {
      _isConnected = true;
      _connectionController.add(true);
      _log('Socket Connected');
      _log('Socket.id: ${_socket!.id}');
    });

    _socket!.onDisconnect((data) {
      _isConnected = false;
      _connectionController.add(false);
      _log('Socket Disconnected. Reason: ${data ?? "Unknown"}');
    });

    _socket!.onConnectError((err) {
      _isConnected = false;
      _connectionController.add(false);
      _log('Socket Connect Error: ${err ?? "Unknown connection issue"}');
    });

    _socket!.on('connect_timeout', (_) {
      _log('Socket Connection Timeout');
    });

    _socket!.onReconnect((_) {
      _isConnected = true;
      _connectionController.add(true);
      _log('Socket Reconnected successfully');
    });

    _socket!.on('reconnect_attempt', (attempt) {
      _log('Socket Reconnect Attempt #$attempt');
    });

    _socket!.on('ping', (_) {
      _log('Ping sent to server...');
    });

    _socket!.on('pong', (latency) {
      _log('Pong received from server. Latency: ${latency != null ? "$latency ms" : "OK"}');
    });

    _socket!.onError((err) {
      _log('Socket Error: ${err ?? "Unknown error"}');
    });

    // ── Telemetry Event ─────────────────────────────────────────────────────

    _socket!.on('telemetry:new', (data) {
      _log('Telemetry data packet received via Socket.IO');
      try {
        Map<String, dynamic> payload;
        if (data is Map<String, dynamic>) {
          payload = data;
        } else if (data is Map) {
          payload = Map<String, dynamic>.from(data);
        } else {
          _log('Telemetry: unexpected data type: ${data.runtimeType}');
          return;
        }
        _telemetryController.add(payload);
      } catch (e) {
        _log('Telemetry parse error: $e');
      }
    });

    // ── Panggil connect() secara eksplisit ──────────────────────────────────
    _log('Calling socket.connect()...');
    _socket!.connect();
  }

  // ─── Disconnect ──────────────────────────────────────────────────────────

  void disconnect() {
    debugPrint('[SOCKET] Socket Disconnected (manual)');
    _socket?.disconnect();
    _socket?.destroy();
    _socket = null;
    _isConnected = false;
  }

  // ─── Dispose ─────────────────────────────────────────────────────────────

  void dispose() {
    disconnect();
    if (!_telemetryController.isClosed) _telemetryController.close();
    if (!_connectionController.isClosed) _connectionController.close();
  }
}
