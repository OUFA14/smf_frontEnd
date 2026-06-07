import 'package:flutter/material.dart';

import '../../models/notification_message.dart';
import '../../services/websocket_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _service = WebSocketService.instance;

  @override
  Widget build(BuildContext context) {
    final notifications = _service.notifications;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () async {
                await _service.markAllRead();
                if (!mounted) return;
                setState(() {});
              },
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(child: Text('No notifications received yet.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final item = notifications[index];
                return _NotificationCard(item: item);
              },
            ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});

  final NotificationMessage item;

  @override
  Widget build(BuildContext context) {
    final accent = _colorFor(item.type);
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: accent.withAlpha(35), child: Icon(Icons.notifications_active, color: accent)),
        title: Text(item.type.replaceAll('_', ' ')),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(item.message),
            const SizedBox(height: 4),
            Text(item.timestamp.toLocal().toString()),
          ],
        ),
        trailing: item.macAddress.isEmpty ? null : Text(item.macAddress),
      ),
    );
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'SOS_ALERT':
        return Colors.red;
      case 'UNAUTHORIZED_ACCESS':
        return Colors.orange;
      case 'DEVICE_OFFLINE':
        return Colors.amber;
      case 'DEVICE_ONLINE':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
}
