class Announcement {
  final String id;
  final String title;
  final String message;
  final String priority; // LOW, MEDIUM, HIGH
  final String status; // SENT, SCHEDULED
  final String? scheduledFor;
  final String? sentAt;
  final String createdAt;
  final String createdById;
  final String createdByUsername;

  Announcement({
    required this.id,
    required this.title,
    required this.message,
    required this.priority,
    required this.status,
    this.scheduledFor,
    this.sentAt,
    required this.createdAt,
    required this.createdById,
    required this.createdByUsername,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      priority: json['priority'] ?? 'MEDIUM',
      status: json['status'] ?? 'SENT',
      scheduledFor: json['scheduledFor'],
      sentAt: json['sentAt'],
      createdAt: json['createdAt'] ?? '',
      createdById: json['createdById'] ?? '',
      createdByUsername: json['createdByUsername'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'priority': priority,
      'status': status,
      'scheduledFor': scheduledFor,
      'sentAt': sentAt,
      'createdAt': createdAt,
      'createdById': createdById,
      'createdByUsername': createdByUsername,
    };
  }

  // Get priority color
  String getPriorityColor() {
    switch (priority) {
      case 'HIGH':
        return '#FF6B6B'; // Red
      case 'MEDIUM':
        return '#FFA500'; // Orange
      case 'LOW':
        return '#4CAF50'; // Green
      default:
        return '#9C27B0'; // Purple
    }
  }

  // Get status display text
  String getStatusDisplay() {
    return status.replaceAll('_', ' ').toUpperCase();
  }
}
