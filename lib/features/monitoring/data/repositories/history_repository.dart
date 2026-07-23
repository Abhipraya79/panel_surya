import 'package:flutter/foundation.dart';
import '../datasources/history_remote_datasource.dart';
import '../models/telemetry_history_model.dart';

/// Repository layer — wraps datasource with error handling.
class HistoryRepository {
  final HistoryRemoteDatasource _datasource;

  HistoryRepository({HistoryRemoteDatasource? datasource})
      : _datasource = datasource ?? HistoryRemoteDatasource();

  Future<List<TelemetryHistoryModel>?> getHistory({
    int limit = 20,
    int page = 1,
    DateTime? startDate,
    DateTime? endDate,
    String? interval,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      return await _datasource.fetchHistory(
        limit: limit,
        page: page,
        startDate: startDate,
        endDate: endDate,
        interval: interval,
        search: search,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
    } catch (e) {
      debugPrint('[HISTORY] HistoryRepository.getHistory error: $e');
      rethrow;
    }
  }
}
