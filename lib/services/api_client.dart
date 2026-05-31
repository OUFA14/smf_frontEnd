import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost:8080/api/v1';
  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  late SharedPreferences _prefs;
  String? _accessToken;
  String? _refreshToken;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _accessToken = _prefs.getString(_tokenKey);
    _refreshToken = _prefs.getString(_refreshTokenKey);
  }

  void setTokens(String accessToken, String refreshToken) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    await _prefs.setString(_tokenKey, accessToken);
    await _prefs.setString(_refreshTokenKey, refreshToken);
  }

  String? getAccessToken() => _accessToken;
  String? getRefreshToken() => _refreshToken;

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_refreshTokenKey);
  }

  Map<String, String> _getHeaders({bool requireAuth = false}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    return headers;
  }

  Future<http.Response> get(
    String endpoint, {
    bool requireAuth = false,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(requireAuth: requireAuth),
      ).timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requireAuth = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(requireAuth: requireAuth),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      throw Exception('Failed to post data: $e');
    }
  }

  Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool requireAuth = false,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(requireAuth: requireAuth),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      throw Exception('Failed to update data: $e');
    }
  }

  Future<http.Response> delete(
    String endpoint, {
    bool requireAuth = false,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(requireAuth: requireAuth),
      ).timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      throw Exception('Failed to delete data: $e');
    }
  }
}
