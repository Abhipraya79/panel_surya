/// Represents the dashboard data returned by the backend.
///
/// REST response shape:
/// ```json
/// {
///   "success": true,
///   "data": {
///     "deviceStatus": "ONLINE",
///     "temperature": 35.3,
///     "airTemp": 65,
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
  final num temperature;
  final num airTemp;
  final num dust;
  final num voltage;
  final num current;
  final num power;
  final bool pumpStatus;
  final bool wiperStatus;
  final String mode;
  final String lastUpdate;

  const DashboardModel({
    required this.deviceStatus,
    required this.temperature,
    required this.airTemp,
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
      temperature: _toNum(json['temperature']),
      airTemp: _toNum(json['airTemp']),
      dust: _toNum(json['dust']),
      voltage: _toNum(json['voltage']),
      current: _toNum(json['current']),
      power: _toNum(json['power']),
      pumpStatus: (json['pumpStatus'] as bool?) ?? false,
      wiperStatus: (json['wiperStatus'] as bool?) ?? false,
      mode: (json['mode'] as String?) ?? 'UNKNOWN',
      lastUpdate: (json['lastUpdate'] as String?) ?? '',
    );
  }

  /// Helper — safely convert num/int/double/String from JSON to num without forced double conversion.
  static num _toNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }

  /// Partial update — used when a socket event arrives with updated data.
  DashboardModel copyWith({
    String? deviceStatus,
    num? temperature,
    num? airTemp,
    num? dust,
    num? voltage,
    num? current,
    num? power,
    bool? pumpStatus,
    bool? wiperStatus,
    String? mode,
    String? lastUpdate,
  }) {
    return DashboardModel(
      deviceStatus: deviceStatus ?? this.deviceStatus,
      temperature: temperature ?? this.temperature,
      airTemp: airTemp ?? this.airTemp,
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
