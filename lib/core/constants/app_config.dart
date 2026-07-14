/// Centralized backend configuration for Panel Care app.
/// Change baseUrl / socketUrl to point to your deployed backend.
class AppConfig {
  AppConfig._();

  /// REST API base URL.
  /// Android Emulator  → use 10.0.2.2 instead of localhost.
  /// Physical device   → use the machine's LAN IP (e.g. 192.168.1.x).
  static const String baseUrl = 'http://192.168.100.12:5000';
  static const String socketUrl = 'http://192.168.100.12:5000';
  static const bool isDebugMode = true;
  static const String environment = 'development';

}
