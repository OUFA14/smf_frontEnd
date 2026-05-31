import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:smf_main/models/announcement.dart';
import 'package:smf_main/models/api_response.dart';
import 'api_client.dart';

class AnnouncementService {
  final ApiClient _apiClient;

  AnnouncementService(this._apiClient);

  Future<List<Announcement>> getAllAnnouncements({String? status, String? search}) async {
    try {
      String endpoint = '/announcements';
      final params = <String>[];

      if (status != null) {
        params.add('status=$status');
      }
      if (search != null) {
        params.add('search=$search');
      }

      if (params.isNotEmpty) {
        endpoint += '?${params.join('&')}';
      }

      final response = await _apiClient.get(endpoint, requireAuth: true);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        return data
            .map((announcement) => Announcement.fromJson(announcement))
            .toList();
      } else {
        throw Exception('Failed to load announcements');
      }
    } catch (e) {
      throw Exception('Error fetching announcements: $e');
    }
  }

  Future<Announcement> getAnnouncementById(String id) async {
    try {
      final response = await _apiClient.get('/announcements/$id', requireAuth: true);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return Announcement.fromJson(jsonResponse['data']);
      } else if (response.statusCode == 404) {
        throw Exception('Announcement not found');
      } else {
        throw Exception('Failed to load announcement');
      }
    } catch (e) {
      throw Exception('Error fetching announcement: $e');
    }
  }

  Future<Announcement> createAnnouncement({
    required String title,
    required String message,
    required String priority,
    String? scheduledFor,
  }) async {
    try {
      final body = {
        'title': title,
        'message': message,
        'priority': priority,
      };

      if (scheduledFor != null) {
        body['scheduledFor'] = scheduledFor;
      }

      final response = await _apiClient.post(
        '/announcements',
        body,
        requireAuth: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return Announcement.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Failed to create announcement');
      }
    } catch (e) {
      throw Exception('Error creating announcement: $e');
    }
  }

  Future<void> deleteAnnouncement(String id) async {
    try {
      final response = await _apiClient.delete(
        '/announcements/$id',
        requireAuth: true,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete announcement');
      }
    } catch (e) {
      throw Exception('Error deleting announcement: $e');
    }
  }
}
