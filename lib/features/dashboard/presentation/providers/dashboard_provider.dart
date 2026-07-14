import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/dashboard_model.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../../../core/socket/socket_service.dart';
import '../../../../core/services/network_error_handler.dart';

/// State management for the Dashboard feature.
///
/// Flow:
///   initialize() → REST API load → connect socket → listen telemetry:new → update UI
///
/// Never call REST API or Socket directly from widgets — use this provider.
class DashboardProvider extends ChangeNotifier {
  final DashboardRepository _repository;
  final SocketService _socket;

  DashboardProvider({
    DashboardRepository? repository,
    SocketService? socket,
  })  : _repository = repository ?? DashboardRepository(),
        _socket = socket ?? SocketService.instance;

  // ─── State ────────────────────────────────────────────────────────────────

  DashboardModel? _data;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _isSocketConnected = false;

  DashboardModel? get data => _data;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  bool get isSocketConnected => _isSocketConnected;

  // ─── Subscriptions ────────────────────────────────────────────────────────

  StreamSubscription<Map<String, dynamic>>? _telemetrySub;
  StreamSubscription<bool>? _connectionSub;

  // ─── Initialization ───────────────────────────────────────────────────────

  /// Call once — loads REST data, then connects socket for realtime updates.
  Future<void> initialize() async {
    _setLoading(true);
    _hasError = false;
    _errorMessage = null;

    try {
      // 1. Fetch initial data via REST API
      final result = await _repository.getDashboard();

      if (result != null) {
        _data = result;
        _hasError = false;
        _errorMessage = null;
        debugPrint('[FLUTTER] REST Loaded — dashboard data received');
      } else {
        _hasError = true;
        _errorMessage = 'Gagal memproses data dashboard dari server.';
        debugPrint('[FLUTTER] REST Error — dashboard data was null');
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = NetworkErrorHandler.getFriendlyMessage(e);
      debugPrint('[FLUTTER] REST Error — exception: $e');
    }

    _setLoading(false);

    // 2. Connect Socket.IO for realtime updates (regardless of REST success)
    _connectSocket();
  }

  // ─── Socket ───────────────────────────────────────────────────────────────

  void _connectSocket() {
    _socket.connect();

    // Listen to connection state changes
    _connectionSub ??= _socket.connectionStream.listen((connected) {
      _isSocketConnected = connected;
      notifyListeners();
    });

    // Initialize with current connection state
    _isSocketConnected = _socket.isConnected;

    // Listen to telemetry events
    _telemetrySub ??= _socket.telemetryStream.listen((payload) {
      _updateFromSocket(payload);
    });
  }

  void _updateFromSocket(Map<String, dynamic> payload) {
    debugPrint('[FLUTTER] Telemetry Updated — applying realtime data');

    if (_data != null) {
      // Merge socket payload into existing model
      _data = DashboardModel.fromJson({
        'deviceStatus': payload['deviceStatus'] ?? _data!.deviceStatus,
        'temperature': payload['temperature'] ?? _data!.temperature,
        'humidity': payload['humidity'] ?? _data!.humidity,
        'dust': payload['dust'] ?? _data!.dust,
        'voltage': payload['voltage'] ?? _data!.voltage,
        'current': payload['current'] ?? _data!.current,
        'power': payload['power'] ?? _data!.power,
        'pumpStatus': payload['pumpStatus'] ?? _data!.pumpStatus,
        'wiperStatus': payload['wiperStatus'] ?? _data!.wiperStatus,
        'mode': payload['mode'] ?? _data!.mode,
        'lastUpdate': payload['receivedAt'] ?? _data!.lastUpdate,
      });
    } else {
      // No previous data — build from socket payload
      _data = DashboardModel.fromJson({
        'deviceStatus': payload['deviceStatus'] ?? 'ONLINE',
        'temperature': payload['temperature'] ?? 0,
        'humidity': payload['humidity'] ?? 0,
        'dust': payload['dust'] ?? 0,
        'voltage': payload['voltage'] ?? 0,
        'current': payload['current'] ?? 0,
        'power': payload['power'] ?? 0,
        'pumpStatus': payload['pumpStatus'] ?? false,
        'wiperStatus': payload['wiperStatus'] ?? false,
        'mode': payload['mode'] ?? 'AUTO',
        'lastUpdate': payload['receivedAt'] ?? '',
      });
      _hasError = false;
    }

    notifyListeners();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ─── Dispose ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _telemetrySub?.cancel();
    _connectionSub?.cancel();
    _socket.disconnect();
    super.dispose();
  }
}
