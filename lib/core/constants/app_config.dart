/// Centralized backend configuration for Panel Care app.
/// Change baseUrl / socketUrl to point to your deployed backend.
class AppConfig {
  AppConfig._();

  static const String baseUrl = 'http://panelcare.allvvnt.my.id/api';
  static const String socketUrl = 'http://panelcare.allvvnt.my.id';
  static const bool isDebugMode = false;
  static const String environment = 'production';

}
