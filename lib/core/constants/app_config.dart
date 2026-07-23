/// Centralized backend configuration for Panel Care app.
/// Change baseUrl / socketUrl to point to your deployed backend.
class AppConfig {
  AppConfig._();

  static const String baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://panelcare.allvvnt.my.id/api');
  static const String socketUrl = String.fromEnvironment('SOCKET_URL', defaultValue: 'http://panelcare.allvvnt.my.id');
  static const bool isDebugMode = bool.fromEnvironment('DEBUG', defaultValue: false);
  static const String environment = String.fromEnvironment('ENV', defaultValue: 'production');
  static const String deviceId = String.fromEnvironment('DEVICE_ID', defaultValue: 'panel001');

}
