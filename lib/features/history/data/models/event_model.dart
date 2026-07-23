class EventModel {
  final String id;
  final String deviceId;
  final String event;
  final String timestamp;
  final String receivedAt;

  EventModel({
    required this.id,
    required this.deviceId,
    required this.event,
    required this.timestamp,
    required this.receivedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? '',
      deviceId: json['deviceId'] ?? '',
      event: json['event'] ?? '',
      timestamp: json['timestamp'] ?? '',
      receivedAt: json['receivedAt'] ?? '',
    );
  }
}
