import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_config.dart';
import '../../../../core/socket/socket_service.dart';
import '../../data/models/event_model.dart';

class EventProvider extends ChangeNotifier {
  final List<EventModel> _events = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _eventSub;

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  EventProvider() {
    loadEvents();
    _listenToSocket();
  }

  void _listenToSocket() {
    _eventSub = SocketService.instance.eventStream.listen((data) {
      // Data might be exactly what EventModel expects, if not adapt it.
      // E.g. deviceId, event, timestamp. It might not have 'id' yet.
      final newEvent = EventModel(
        id: data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        deviceId: data['deviceId'] ?? '',
        event: data['event'] ?? '',
        timestamp: data['timestamp'] ?? '',
        receivedAt: data['receivedAt'] ?? DateTime.now().toIso8601String(),
      );

      _events.insert(0, newEvent);
      // Keep only last 100 in memory
      if (_events.length > 100) {
        _events.removeLast();
      }
      notifyListeners();
    });
  }

  Future<void> loadEvents({int page = 1, int limit = 50}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uri = Uri.parse('${AppConfig.baseUrl}/events?page=$page&limit=$limit');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          final List data = body['data'] ?? [];
          if (page == 1) {
            _events.clear();
          }
          _events.addAll(data.map((e) => EventModel.fromJson(e)));
        } else {
          _errorMessage = body['message'] ?? 'Failed to load events';
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearEvents() {
    _events.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }
}
