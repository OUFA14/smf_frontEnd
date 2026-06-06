import '../models/worker_profile.dart';
import 'api_service.dart';
import 'auth_service.dart';

class WorkersService {
  WorkersService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<WorkerProfile> getWorker(String id) async {
    final endpoints = <String>[
      '/workers/$id',
      '/workers/user/$id',
      '/workers/me',
      '/workers/profile/$id',
    ];

    for (final endpoint in endpoints) {
      try {
        final response = await _apiService.get(
          endpoint,
          headers: await AuthService.instance.authHeaders(),
        );
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return WorkerProfile.fromJson(data);
        }
        if (data is Map) {
          return WorkerProfile.fromJson(Map<String, dynamic>.from(data));
        }
      } on ApiException catch (error) {
        if (endpoint == endpoints.last) rethrow;
        if (error.statusCode != null && error.statusCode! >= 400) {
          continue;
        }
        rethrow;
      }
    }

    throw const ApiException('Worker profile not found');
  }

  Future<WorkerProfile> createWorker({
    required String userId,
    required Map<String, String> fields,
  }) async {
    final response = await _apiService.post(
      '/workers',
      headers: await AuthService.instance.authHeaders(),
      body: {
        'user_id': userId,
        ...fields,
      },
    );

    return WorkerProfile.fromJson(response.data as Map<String, dynamic>);
  }

  Future<WorkerProfile> updateWorker({
    required String id,
    required Map<String, String> fields,
  }) async {
    final response = await _apiService.patch(
      '/workers/$id',
      headers: await AuthService.instance.authHeaders(),
      body: {
        'user_id': id,
        ...fields,
      },
    );

    return WorkerProfile.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteWorker(String id) async {
    await _apiService.delete(
      '/workers/$id',
      headers: await AuthService.instance.authHeaders(),
    );
  }
}
