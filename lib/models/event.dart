class Event {
  final String eventId;
  final String deviceId;
  final String macAddress;
  final String event;
  final String timestamp;

  Event({
    required this.eventId,
    required this.deviceId,
    required this.macAddress,
    required this.event,
    required this.timestamp,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['eventId'] ?? '',
      deviceId: json['deviceId'] ?? '',
      macAddress: json['macAddress'] ?? '',
      event: json['event'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'deviceId': deviceId,
      'macAddress': macAddress,
      'event': event,
      'timestamp': timestamp,
    };
  }

  bool isAlertEvent() =>
      event.contains('ALERT') || event.contains('ERROR') || event.contains('OFFLINE');
}