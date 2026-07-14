import 'package:flutter/foundation.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../models/dashboard_model.dart';

/// Repository layer — wraps the datasource and handles errors.
/// Service/Provider should only call this, not the datasource directly.
class DashboardRepository {
  final DashboardRemoteDatasource _datasource;

  DashboardRepository({DashboardRemoteDatasource? datasource})
      : _datasource = datasource ?? DashboardRemoteDatasource();

  Future<DashboardModel?> getDashboard() async {
    try {
      return await _datasource.fetchDashboard();
    } catch (e) {
      debugPrint('[FLUTTER] DashboardRepository.getDashboard error: $e');
      rethrow;
    }
  }
}
