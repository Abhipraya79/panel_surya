class AppState {
  AppState._();
  
  static final AppState instance = AppState._();

  // Biometric state
  bool isBiometricAuthenticating = false;

  // Cooling Screen States
  bool isCooling = false;
  bool peltierOn = false;
  bool fanOn = false;

  // Cleaning/Controller Screen States
  bool isManualMode = true;
  bool wiperOn = false;
  bool pumpOn = false;
  bool schedule07 = true;
  bool schedule18 = true;
  bool isCleaning = false;
}
