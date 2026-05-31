class Device {
  final String id;
  final String macAddress;
  final String? ownerId;
  final String status;
  final String? label;
  final double? lastLocationLat;
  final double? lastLocationLon;

  Device({
    required this.id,
    required this.macAddress,
    this.ownerId,
    required this.status,
    this.label,
    this.lastLocationLat,
    this.lastLocationLon,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] ?? '',
      macAddress: json['macAddress'] ?? '',
      ownerId: json['ownerId'],
      status: json['status'] ?? 'OFFLINE',
      label: json['label'],
      lastLocationLat: json['lastLocationLat'] as double?,
      lastLocationLon: json['lastLocationLon'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'macAddress': macAddress,
      'ownerId': ownerId,
      'status': status,
      'label': label,
      'lastLocationLat': lastLocationLat,
      'lastLocationLon': lastLocationLon,
    };
  }

  bool isOnline() => status == 'ONLINE';
}
