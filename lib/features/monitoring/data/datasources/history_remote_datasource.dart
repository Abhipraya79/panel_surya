import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_config.dart';
import '../models/telemetry_history_model.dart';

/// Handles REST API calls for telemetry history.
/// Only communicates with backend — no business logic.
class HistoryRemoteDatasource {
  final http.Client _client;

  HistoryRemoteDatasource({http.Client? client})
      : _client = client ?? http.Client();

  /// Fetches telemetry history from GET /api/telemetry/history.
  Future<List<TelemetryHistoryModel>> fetchHistory({
    int limit = 20,
    int page = 1,
  }) async {
    final uri = Uri.parse(
      '${AppConfig.baseUrl}/api/telemetry/history?limit=$limit&page=$page',
    );

    try {
      debugPrint('[HISTORY] Request limit=$limit page=$page → $uri');

      final response = await _client.get(uri).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final rawList = json['data'] as List<dynamic>;

        final records = rawList
            .map((item) => TelemetryHistoryModel.fromJson(
                  item as Map<String, dynamic>,
                ))
            .toList();

        debugPrint('[HISTORY] Loaded ${records.length} records');
        return records;
      } else {
        throw Exception(
          'GET /api/telemetry/history failed: HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('[HISTORY] Error: $e');
      rethrow;
    }
  }
}
