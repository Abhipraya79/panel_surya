/// Represents a single telemetry history record from the backend.
///
/// REST response item shape (inside "data" array):
/// ```json
/// {
///   "temperature": 35.2,
///   "humidity": 81,
///   "voltage": 18.6,
///   "current": 2.3,
///   "power": 42.8,
///   "dust": 17.5,
///   "timestamp": "2026-07-12T19:30:00Z"
/// }
/// ```
class TelemetryHistoryModel {
  final double temperature;
  final double humidity;
  final double voltage;
  final double current;
  final double power;
  final double dust;
  final DateTime timestamp;

  const TelemetryHistoryModel({
    required this.temperature,
    required this.humidity,
    required this.voltage,
    required this.current,
    required this.power,
    required this.dust,
    required this.timestamp,
  });

  factory TelemetryHistoryModel.fromJson(Map<String, dynamic> json) {
    return TelemetryHistoryModel(
      temperature: _toDouble(json['temperature']),
      humidity: _toDouble(json['humidity']),
      voltage: _toDouble(json['voltage']),
      current: _toDouble(json['current']),
      power: _toDouble(json['power']),
      dust: _toDouble(json['dust']),
      timestamp: _parseTimestamp(json['timestamp']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
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
