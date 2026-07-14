import 'package:flutter/foundation.dart';
import '../../data/models/telemetry_history_model.dart';
import '../../data/repositories/history_repository.dart';
import '../../../../core/services/network_error_handler.dart';

class HistoryProvider extends ChangeNotifier {
  final HistoryRepository _repository;

  HistoryProvider({HistoryRepository? repository})
      : _repository = repository ?? HistoryRepository();

  List<TelemetryHistoryModel> _records = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  int _selectedLimit = 20;

  List<TelemetryHistoryModel> get records => _records;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  int get selectedLimit => _selectedLimit;

  // --- Statistics Getters ---
  double get avgTemperature {
    if (_records.isEmpty) return 0.0;
    return _records.map((e) => e.temperature).reduce((a, b) => a + b) /
        _records.length;
  }

  double get maxTemperature {
    if (_records.isEmpty) return 0.0;
    return _records.map((e) => e.temperature).reduce((a, b) => a > b ? a : b);
  }

  double get minTemperature {
    if (_records.isEmpty) return 0.0;
    return _records.map((e) => e.temperature).reduce((a, b) => a < b ? a : b);
  }

  double get avgHumidity {
    if (_records.isEmpty) return 0.0;
    return _records.map((e) => e.humidity).reduce((a, b) => a + b) /
        _records.length;
  }

  double get avgVoltage {
    if (_records.isEmpty) return 0.0;
    return _records.map((e) => e.voltage).reduce((a, b) => a + b) /
        _records.length;
  }

  double get avgCurrent {
    if (_records.isEmpty) return 0.0;
    return _records.map((e) => e.current).reduce((a, b) => a + b) /
        _records.length;
  }

  double get avgPower {
    if (_records.isEmpty) return 0.0;
    return _records.map((e) => e.power).reduce((a, b) => a + b) /
        _records.length;
  }

  Future<void> loadHistory() async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getHistory(limit: _selectedLimit);
      if (result != null) {
        _records = List.from(result)
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
        _hasError = false;
        _errorMessage = null;
      } else {
        _hasError = true;
        _errorMessage = 'Gagal memproses data history dari server.';
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = NetworkErrorHandler.getFriendlyMessage(e);
      debugPrint('[HISTORY] loadHistory error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void setLimit(int newLimit) {
    if (_selectedLimit != newLimit) {
      _selectedLimit = newLimit;
      loadHistory();
    }
  }
}
