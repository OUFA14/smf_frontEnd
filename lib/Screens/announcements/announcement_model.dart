class AnnouncementModel {
  final String? id;
  final String title;
  final String message;
  final String priority;
  final String sender;
  final DateTime timestamp;
  final String status;
  final DateTime? scheduledFor;
  final DateTime? sentAt;
  final DateTime? createdAt;
  bool isRead;

  AnnouncementModel({
    this.id,
    required this.title,
    required this.message,
    required this.priority,
    required this.sender,
    required this.timestamp,
    this.status = 'SENT',
    this.scheduledFor,
    this.sentAt,
    this.createdAt,
    this.isRead = false,
  });

  bool get isScheduled => status.toUpperCase() == 'SCHEDULED';

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    final status = (json['status'] ?? 'SENT').toString().toUpperCase();
    final createdAt = _parseDate(json['createdAt']);
    final scheduledFor = _parseDate(json['scheduledFor']);
    final sentAt = _parseDate(json['sentAt']);

    return AnnouncementModel(
      id: json['id']?.toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      priority: _titleCasePriority((json['priority'] ?? 'MEDIUM').toString()),
      sender:
          (json['createdByUsername'] ?? json['sender'] ?? 'Admin').toString(),
      timestamp: sentAt ?? scheduledFor ?? createdAt ?? DateTime.now(),
      status: status,
      scheduledFor: scheduledFor,
      sentAt: sentAt,
      createdAt: createdAt,
      isRead: json['isRead'] == true,
    );
  }

  AnnouncementModel copyWith({
    String? id,
    String? title,
    String? message,
    String? priority,
    String? sender,
    DateTime? timestamp,
    String? status,
    DateTime? scheduledFor,
    DateTime? sentAt,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      priority: priority ?? this.priority,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      sentAt: sentAt ?? this.sentAt,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static String _titleCasePriority(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return 'Medium';
    return '${normalized[0].toUpperCase()}${normalized.substring(1)}';
  }
}
