import '../Screens/announcements/announcement_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class AnnouncementsService {
  AnnouncementsService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<List<AnnouncementModel>> getAnnouncements({
    String? status,
    String? search,
  }) async {
    final query = <String, String>{
      if (status != null && status.isNotEmpty) 'status': status,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    };
    final path = Uri(
            path: '/announcements/',
            queryParameters: query.isEmpty ? null : query)
        .toString();
    final response = await _apiService.get(
      path,
      headers: await AuthService.instance.authHeaders(),
    );

    final rawData = response.data;
    final rawAnnouncements = rawData is List
        ? rawData
        : rawData is Map<String, dynamic>
            ? rawData['announcements'] as List<dynamic>? ??
                rawData['items'] as List<dynamic>? ??
                rawData['content'] as List<dynamic>? ??
                const []
            : const <dynamic>[];

    return rawAnnouncements
        .whereType<Map<String, dynamic>>()
        .map(AnnouncementModel.fromJson)
        .toList();
  }

  Future<AnnouncementModel> createAnnouncement({
    required String title,
    required String message,
    required String priority,
    DateTime? scheduledFor,
  }) async {
    final response = await _apiService.post(
      '/announcements/',
      headers: await AuthService.instance.authHeaders(),
      body: {
        'title': title,
        'message': message,
        'priority': priority.toUpperCase(),
        if (scheduledFor != null)
          'scheduledFor': scheduledFor.toUtc().toIso8601String(),
      },
    );

    return AnnouncementModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AnnouncementModel> getAnnouncement(String id) async {
    final response = await _apiService.get(
      '/announcements/$id',
      headers: await AuthService.instance.authHeaders(),
    );

    return AnnouncementModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteAnnouncement(String id) async {
    await _apiService.delete(
      '/announcements/$id',
      headers: await AuthService.instance.authHeaders(),
    );
  }
}
