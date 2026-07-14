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
    final uri = Uri.parse('${AppConfig.baseUrl}/api/dashboard');

    try {
      debugPrint('[FLUTTER] REST Fetching dashboard from $uri');
      final response = await _client.get(uri).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final data = json['data'] as Map<String, dynamic>;
        debugPrint('[FLUTTER] REST Loaded');
        return DashboardModel.fromJson(data);
      } else {
        throw Exception(
          'GET /api/dashboard failed with status ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('[FLUTTER] REST Error: $e');
      rethrow;
    }
  }
}
