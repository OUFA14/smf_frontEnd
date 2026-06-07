import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/notification_message.dart';

class NotificationHelper {
  NotificationHelper._();

  static final NotificationHelper instance = NotificationHelper._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<void> showNotification(NotificationMessage message) async {
    await initialize();

    final priority = _priorityForType(message.type);
    final importance = _importanceForType(message.type);
    const channelId = 'smf_alerts';

    const androidDetails = AndroidNotificationDetails(
      channelId,
      'SMF Alerts',
      channelDescription: 'Critical system notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      message.timestamp.millisecondsSinceEpoch.remainder(100000),
      _titleForType(message.type),
      message.message,
      details,
      payload: message.toJson().toString(),
    );

    debugPrint('Notification shown: ${message.type} priority=$priority importance=$importance');
  }

  Color colorForType(String type) {
    switch (type) {
      case 'SOS_ALERT':
        return const Color(0xFFD32F2F);
      case 'UNAUTHORIZED_ACCESS':
        return const Color(0xFFF57C00);
      case 'DEVICE_OFFLINE':
        return const Color(0xFFFBC02D);
      case 'DEVICE_ONLINE':
        return const Color(0xFF2E7D32);
      default:
        return const Color(0xFF1976D2);
    }
  }

  String _titleForType(String type) {
    switch (type) {
      case 'SOS_ALERT':
        return 'SOS Alert';
      case 'UNAUTHORIZED_ACCESS':
        return 'Unauthorized Access';
      case 'DEVICE_OFFLINE':
        return 'Device Offline';
      case 'DEVICE_ONLINE':
        return 'Device Online';
      default:
        return 'SMF Notification';
    }
  }

  int _priorityForType(String type) {
    return type == 'SOS_ALERT' ? 2 : type == 'UNAUTHORIZED_ACCESS' ? 1 : 0;
  }

  int _importanceForType(String type) {
    return type == 'SOS_ALERT' ? 2 : type == 'UNAUTHORIZED_ACCESS' ? 1 : 0;
  }
}
