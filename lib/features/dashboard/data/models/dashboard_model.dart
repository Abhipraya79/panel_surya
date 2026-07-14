/// Represents the dashboard data returned by the backend.
///
/// REST response shape:
/// ```json
/// {
///   "success": true,
///   "data": {
///     "deviceStatus": "ONLINE",
///     "temperature": 35.3,
///     "humidity": 84,
///     "dust": 38,
///     "voltage": 18.2,
///     "current": 2.7,
///     "power": 49.6,
///     "pumpStatus": true,
///     "wiperStatus": false,
///     "mode": "AUTO",
///     "lastUpdate": "2026-07-12T10:00:00.000Z"
///   }
/// }
/// ```
class DashboardModel {
  final String deviceStatus; // "ONLINE" | "OFFLINE"
  final double temperature;
  final double humidity;
  final double dust;
  final double voltage;
  final double current;
  final double power;
  final bool pumpStatus;
  final bool wiperStatus;
  final String mode;
  final String lastUpdate;

  const DashboardModel({
    required this.deviceStatus,
    required this.temperature,
    required this.humidity,
    required this.dust,
    required this.voltage,
    required this.current,
    required this.power,
    required this.pumpStatus,
    required this.wiperStatus,
    required this.mode,
    required this.lastUpdate,
  });

  /// Parse from the "data" object inside the backend response.
  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      deviceStatus: (json['deviceStatus'] as String?) ?? 'OFFLINE',
      temperature: _toDouble(json['temperature']),
      humidity: _toDouble(json['humidity']),
      dust: _toDouble(json['dust']),
      voltage: _toDouble(json['voltage']),
      current: _toDouble(json['current']),
      power: _toDouble(json['power']),
      pumpStatus: (json['pumpStatus'] as bool?) ?? false,
      wiperStatus: (json['wiperStatus'] as bool?) ?? false,
      mode: (json['mode'] as String?) ?? 'UNKNOWN',
      lastUpdate: (json['lastUpdate'] as String?) ?? '',
    );
  }

  /// Helper — safely convert num/int/double from JSON to double.
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Partial update — used when a socket event arrives with updated data.
  DashboardModel copyWith({
    String? deviceStatus,
    double? temperature,
    double? humidity,
    double? dust,
    double? voltage,
    double? current,
    double? power,
    bool? pumpStatus,
    bool? wiperStatus,
    String? mode,
    String? lastUpdate,
  }) {
    return DashboardModel(
      deviceStatus: deviceStatus ?? this.deviceStatus,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      dust: dust ?? this.dust,
      voltage: voltage ?? this.voltage,
      current: current ?? this.current,
      power: power ?? this.power,
      pumpStatus: pumpStatus ?? this.pumpStatus,
      wiperStatus: wiperStatus ?? this.wiperStatus,
      mode: mode ?? this.mode,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  bool get isOnline => deviceStatus == 'ONLINE';
}
