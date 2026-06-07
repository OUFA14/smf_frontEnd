import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../models/notification_message.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'notification_helper.dart';

class WebSocketService {
  WebSocketService._();

  static final WebSocketService instance = WebSocketService._();

  static const _historyKey = 'notification_history';

  StompClient? _client;
  final StreamController<NotificationMessage> _streamController =
      StreamController.broadcast();
  final List<NotificationMessage> _notifications = <NotificationMessage>[];
  bool _isConnecting = false;
  int _unreadCount = 0;

  Stream<NotificationMessage> get stream => _streamController.stream;
  List<NotificationMessage> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _unreadCount;
  bool get isConnected => _client != null && _client!.connected;

  Future<void> connect() async {
    if (_isConnecting || isConnected) return;

    final token = AuthService.instance.accessToken;
    if (token == null || token.isEmpty) return;

    _isConnecting = true;
    try {
      final wsUrl = _webSocketUrl();
      debugPrint('Connecting STOMP WebSocket to $wsUrl');
      _client = StompClient(
        config: StompConfig(
          url: wsUrl,
          onConnect: _onConnect,
          beforeConnect: () async {
            await Future.delayed(const Duration(milliseconds: 200));
          },
          onWebSocketError: (dynamic error) {
            debugPrint('STOMP WebSocket error: $error');
          },
          stompConnectHeaders: {
            'Authorization': 'Bearer $token',
          },
          webSocketConnectHeaders: {
            'Authorization': 'Bearer $token',
          },
          reconnectDelay: const Duration(seconds: 0),
        ),
      );
      _client!.activate();
      await _loadHistory();
    } finally {
      _isConnecting = false;
    }
  }

  Future<void> disconnect() async {
    try {
      _client?.deactivate();
    } finally {
      _client = null;
      _isConnecting = false;
    }
  }

  Future<void> markAllRead() async {
    _unreadCount = 0;
  }

  Future<void> _onConnect(StompFrame frame) async {
    debugPrint('STOMP connected to /topic/alerts');
    _client!.subscribe(
      destination: '/topic/alerts',
      callback: (frame) async {
        if (frame.body == null || frame.body!.isEmpty) return;
        try {
          final decoded = jsonDecode(frame.body!);
          final message = NotificationMessage.fromJson(decoded is Map<String, dynamic>
              ? decoded
              : Map<String, dynamic>.from(decoded as Map));
          await _storeNotification(message);
          _streamController.add(message);
          _unreadCount += 1;
          await NotificationHelper.instance.showNotification(message);
        } catch (error) {
          debugPrint('Failed to parse WebSocket event: $error');
        }
      },
    );
  }

  Future<void> _storeNotification(NotificationMessage message) async {
    final existing = _notifications.where((item) => item.eventId == message.eventId).toList();
    if (existing.isNotEmpty) return;

    _notifications.insert(0, message);
    final prefs = await SharedPreferences.getInstance();
    final history = _notifications.map((item) => item.toJson()).toList();
    await prefs.setString(_historyKey, jsonEncode(history));
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) return;

    final decoded = jsonDecode(raw);
    if (decoded is List) {
      final items = decoded
          .whereType<Map>()
          .map((item) => NotificationMessage.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      _notifications
        ..clear()
        ..addAll(items);
      _unreadCount = items.length;
    }
  }

  String _webSocketUrl() {
    final baseUrl = ApiService.baseUrl;
    final normalized = baseUrl.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://');
    return '${normalized.replaceFirst('/api/v1', '')}/ws';
  }
}
