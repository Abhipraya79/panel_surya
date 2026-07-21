import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_config.dart';
import '../models/dashboard_model.dart';

/// Handles all REST API calls related to the dashboard.
/// Only communicates with the backend — no business logic here.
class DashboardRemoteDatasource {
  final http.Client _client;

  DashboardRemoteDatasource({http.Client? client})
      : _client = client ?? http.Client();

  /// Fetches the latest dashboard data from GET /api/dashboard.
  Future<DashboardModel> fetchDashboard() async {
    final uri = Uri.parse('${AppConfig.baseUrl}/dashboard');

    try {
      debugPrint('[API REQUEST] GET $uri');
      final response = await _client.get(uri).timeout(
            const Duration(seconds: 10),
          );

      debugPrint('[API RESPONSE] GET $uri - Code ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final data = json['data'] as Map<String, dynamic>;
        return DashboardModel.fromJson(data);
      } else {
        throw Exception(
          'GET /api/dashboard failed with status ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('[API ERROR] GET $uri - Exception $e');
      rethrow;
    }
  }
}
