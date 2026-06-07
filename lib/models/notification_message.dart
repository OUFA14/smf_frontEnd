class NotificationMessage {
  final String eventId;
  final String type;
  final String macAddress;
  final String message;
  final DateTime timestamp;
  final String? metadata;

  const NotificationMessage({
    required this.eventId,
    required this.type,
    required this.macAddress,
    required this.message,
    required this.timestamp,
    this.metadata,
  });

  factory NotificationMessage.fromJson(Map<String, dynamic> json) {
    return NotificationMessage(
      eventId: json['eventId']?.toString() ?? json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'INFO',
      macAddress: json['macAddress']?.toString() ?? json['deviceId']?.toString() ?? '',
      message: json['message']?.toString() ?? 'New system event received',
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
      metadata: json['metadata']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'type': type,
        'macAddress': macAddress,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
        'metadata': metadata,
      };

  String get label => type.replaceAll('_', ' ').toLowerCase();
}
