/// Represents a single telemetry history record from the backend.
///
/// REST response item shape (inside "data" array):
/// ```json
/// {
///   "temperature": 35.2,
///   "airTemp": 65,
///   "voltage": 18.6,
///   "current": 2.3,
///   "power": 42.8,
///   "dust": 17.5,
///   "timestamp": "2026-07-12T19:30:00Z"
/// }
/// ```
class TelemetryHistoryModel {
  final num temperature;
  final num airTemp;
  final num voltage;
  final num current;
  final num power;
  final num dust;
  final DateTime timestamp;
  final bool pumpStatus;
  final bool wiperStatus;
  final String systemMode; // 'MANUAL' or 'AUTO'
  final String deviceStatus; // 'ONLINE' or 'OFFLINE'

  const TelemetryHistoryModel({
    required this.temperature,
    required this.airTemp,
    required this.voltage,
    required this.current,
    required this.power,
    required this.dust,
    required this.timestamp,
    this.pumpStatus = false,
    this.wiperStatus = false,
    this.systemMode = 'MANUAL',
    this.deviceStatus = 'ONLINE',
  });

  factory TelemetryHistoryModel.fromJson(Map<String, dynamic> json) {
    return TelemetryHistoryModel(
      temperature: _toNum(json['temperature']),
      airTemp: _toNum(json['airTemp']),
      voltage: _toNum(json['voltage']),
      current: _toNum(json['current']),
      power: _toNum(json['power']),
      dust: _toNum(json['dust']),
      timestamp: _parseTimestamp(json['timestamp']),
      pumpStatus: _parseBool(json['pumpStatus'], json['pump']),
      wiperStatus: _parseBool(json['wiperStatus'], json['wiper']),
      systemMode: _parseString(json['systemMode'], json['mode'], 'MANUAL'),
      deviceStatus: _parseString(json['deviceStatus'], json['status'], 'ONLINE'),
    );
  }

  static bool _parseBool(dynamic val1, dynamic val2) {
    if (val1 != null) {
      if (val1 is bool) return val1;
      if (val1 is int) return val1 == 1;
      if (val1 is String) return val1.toLowerCase() == 'true' || val1 == '1' || val1.toLowerCase() == 'on';
    }
    if (val2 != null) {
      if (val2 is bool) return val2;
      if (val2 is int) return val2 == 1;
      if (val2 is String) return val2.toLowerCase() == 'true' || val2 == '1' || val2.toLowerCase() == 'on';
    }
    return false;
  }

  static String _parseString(dynamic val1, dynamic val2, String defaultVal) {
    if (val1 != null && val1.toString().isNotEmpty) {
      return val1.toString().toUpperCase();
    }
    if (val2 != null && val2.toString().isNotEmpty) {
      return val2.toString().toUpperCase();
    }
    return defaultVal;
  }

  static num _toNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
    }
    return DateTime.now();
  }

  /// Format time for X-axis label: "HH:mm"
  String get timeLabel {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
