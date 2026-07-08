import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

/// Centralized service for Firebase Realtime Database in Panel Care.
/// Manages sensor telemetry streaming and actuator control writes.
class FirebaseDbService {
  FirebaseDbService._();

  static final FirebaseDatabase _db = FirebaseDatabase.instance;

  /// References to database nodes
  static final DatabaseReference telemetryRef = _db.ref('telemetry');
  static final DatabaseReference actuatorsRef = _db.ref('actuators');
  static final DatabaseReference settingsRef = _db.ref('settings');
  static final DatabaseReference schedulesRef = _db.ref('schedules');

  // ─── Real-time Streams ─────────────────────────────────────────────────────

  /// Stream of telemetry sensor values
  static Stream<DatabaseEvent> get telemetryStream => telemetryRef.onValue;

  /// Stream of actuator statuses
  static Stream<DatabaseEvent> get actuatorsStream => actuatorsRef.onValue;

  /// Stream of system settings (e.g. Setpoint Temperature)
  static Stream<DatabaseEvent> get settingsStream => settingsRef.onValue;

  /// Stream of schedules (RTC schedules)
  static Stream<DatabaseEvent> get schedulesStream => schedulesRef.onValue;

  // ─── Actuator Controls (Write operations) ──────────────────────────────────

  /// Updates the status of a specific actuator
  static Future<void> updateActuator(String key, bool isOn) async {
    try {
      await actuatorsRef.child(key).set(isOn);
      debugPrint('FirebaseDbService: Actuator [$key] updated to $isOn');
    } catch (e) {
      debugPrint('FirebaseDbService: Error updating actuator [$key]: $e');
    }
  }

  /// Sets the cooling pump speed (PWM percentage)
  static Future<void> updateCoolingPumpSpeed(int pwmPercent) async {
    try {
      await actuatorsRef.child('cooling_pump_speed').set(pwmPercent);
    } catch (e) {
      debugPrint('FirebaseDbService: Error updating cooling pump PWM: $e');
    }
  }

  // ─── Settings Controls (Write operations) ──────────────────────────────────

  /// Updates the temperature setpoint trigger for auto cooling
  static Future<void> updateTempSetpoint(int setpoint) async {
    try {
      await settingsRef.child('setpoint_temp').set(setpoint);
      debugPrint('FirebaseDbService: Setpoint Temp updated to $setpoint');
    } catch (e) {
      debugPrint('FirebaseDbService: Error updating setpoint temperature: $e');
    }
  }

  // ─── Schedules Controls (Write operations) ──────────────────────────────────

  /// Updates a specific RTC schedule trigger state
  static Future<void> updateScheduleState(String timeKey, bool enabled) async {
    try {
      await schedulesRef.child(timeKey).set(enabled);
      debugPrint('FirebaseDbService: Schedule [$timeKey] updated to $enabled');
    } catch (e) {
      debugPrint('FirebaseDbService: Error updating schedule state [$timeKey]: $e');
    }
  }
}
