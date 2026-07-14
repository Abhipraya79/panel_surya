class AppState {
  AppState._();
  
  static final AppState instance = AppState._();

  // Biometric state
  bool isBiometricAuthenticating = false;

  // Cooling Screen States
  bool peltierOn = true;
  bool fanOn = true;

  // Cleaning/Controller Screen States
  bool isManualMode = true;
  bool wiperOn = false;
  bool pumpOn = false;
  bool schedule07 = true;
  bool schedule18 = true;
  bool isCleaning = false;
}
