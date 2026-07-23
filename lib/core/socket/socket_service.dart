import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io_client;
import 'package:panel_surya/main.dart';
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
  final _modeController = StreamController<String>.broadcast();
  final _coolingController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _deviceStatusController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _cleaningStatusController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _eventController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get telemetryStream =>
      _telemetryController.stream;

  Stream<bool> get connectionStream => _connectionController.stream;

  Stream<String> get modeStream => _modeController.stream;

  Stream<Map<String, dynamic>> get coolingStream =>
      _coolingController.stream;

  Stream<Map<String, dynamic>> get deviceStatusStream =>
      _deviceStatusController.stream;

  Stream<Map<String, dynamic>> get cleaningStatusStream =>
      _cleaningStatusController.stream;

  Stream<Map<String, dynamic>> get eventStream =>
      _eventController.stream;

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

    final opts = io_client.OptionBuilder()
        .setTransports(['websocket'])    // WAJIB: hindari polling
        .disableAutoConnect()            // kita panggil connect() manual
        .enableReconnection()
        .setReconnectionAttempts(999)
        .setReconnectionDelay(1000)
        .setReconnectionDelayMax(5000)
        .build();
    opts['timeout'] = 10000;             // connect timeout (10s)

    _socket = io_client.io(url, opts);

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
      _log('Socket Disconnected');
      _log('Disconnect Reason: ${data ?? "Unknown"}');
      _showNetworkSnackbar('Terputus dari server. Menghubungkan kembali...');
    });

    _socket!.onConnectError((err) {
      _isConnected = false;
      _connectionController.add(false);
      _log('Socket Connect Error: ${err ?? "Unknown connection issue"}');
      _showNetworkSnackbar('Gagal menghubungi server Node.js. Silakan periksa koneksi Anda.');
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

    _socket!.on('telemetry:update', (data) {
      _log('Telemetry Updated');
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

    _socket!.on('mode:update', (data) {
      _log('Mode update received via Socket.IO');
      try {
        String mode;
        if (data is Map) {
          mode = data['mode'] as String;
        } else if (data is String) {
          mode = data;
        } else {
          _log('Mode: unexpected data type: ${data.runtimeType}');
          return;
        }
        _modeController.add(mode);
      } catch (e) {
        _log('Mode parse error: $e');
      }
    });

    _socket!.on('cooling:update', (data) {
      _log('Cooling status received via Socket.IO');
      try {
        Map<String, dynamic> payload;
        if (data is Map<String, dynamic>) {
          payload = data;
        } else if (data is Map) {
          payload = Map<String, dynamic>.from(data);
        } else {
          _log('Cooling: unexpected data type: ${data.runtimeType}');
          return;
        }
        _coolingController.add(payload);
      } catch (e) {
        _log('Cooling parse error: $e');
      }
    });

    _socket!.on('status:update', (data) {
      _log('Device Status received');
      try {
        Map<String, dynamic> payload;
        if (data is Map<String, dynamic>) {
          payload = data;
        } else if (data is Map) {
          payload = Map<String, dynamic>.from(data);
        } else {
          _log('Device status format error');
          return;
        }
        _deviceStatusController.add(payload);
      } catch (e) {
        _log('Device status error: $e');
      }
    });

    _socket!.on('cleaning:update', (data) {
      _log('Cleaning status received');
      try {
        Map<String, dynamic> payload;
        if (data is Map<String, dynamic>) {
          payload = data;
        } else if (data is Map) {
          payload = Map<String, dynamic>.from(data);
        } else {
          _log('Cleaning format error');
          return;
        }
        _cleaningStatusController.add(payload);
      } catch (e) {
        _log('Cleaning parse error: $e');
      }
    });

    _socket!.on('event:new', (data) {
      _log('New event received');
      try {
        Map<String, dynamic> payload;
        if (data is Map<String, dynamic>) {
          payload = data;
        } else if (data is Map) {
          payload = Map<String, dynamic>.from(data);
        } else {
          _log('Event format error');
          return;
        }
        _eventController.add(payload);
      } catch (e) {
        _log('Event parse error: $e');
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
    if (!_modeController.isClosed) _modeController.close();
    if (!_coolingController.isClosed) _coolingController.close();
    if (!_deviceStatusController.isClosed) _deviceStatusController.close();
    if (!_cleaningStatusController.isClosed) _cleaningStatusController.close();
    if (!_eventController.isClosed) _eventController.close();
  }

  void _showNetworkSnackbar(String message) {
    try {
      PanelCareApp.scaffoldMessengerKey.currentState?.clearSnackBars();
      PanelCareApp.scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFD32F2F), // Red danger
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('Error showing network snackbar: $e');
    }
  }
}
