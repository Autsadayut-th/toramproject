import 'dart:convert';

import 'package:http/http.dart' as http;

class ToramDataGithubService {
  const ToramDataGithubService._();

  static const String repository = 'ThammanoonSrijan/toram-data';
  static const String branch = 'main';
  static const String _baseUrl =
      'https://raw.githubusercontent.com/$repository/$branch';

  static final Map<String, Future<dynamic>> _jsonCache =
      <String, Future<dynamic>>{};

  static Uri resolveUri(String relativePath) {
    final String normalizedPath = relativePath.trim().replaceFirst(
      RegExp(r'^/+'),
      '',
    );
    return Uri.parse('$_baseUrl/$normalizedPath');
  }

  static Future<dynamic> loadJson(
    String relativePath, {
    Duration timeout = const Duration(seconds: 15),
  }) {
    final String normalizedPath = relativePath.trim();
    final Future<dynamic>? cached = _jsonCache[normalizedPath];
    if (cached != null) {
      return cached;
    }

    final Future<dynamic> future = _fetchJson(
      normalizedPath,
      timeout: timeout,
    );
    _jsonCache[normalizedPath] = future;
    return future.catchError((Object error) {
      _jsonCache.remove(normalizedPath);
      throw error;
    });
  }

  static Future<Map<String, dynamic>> loadMap(
    String relativePath, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final dynamic decoded = await loadJson(relativePath, timeout: timeout);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    throw FormatException('Expected JSON object at $relativePath');
  }

  static Future<List<dynamic>> loadList(
    String relativePath, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final dynamic decoded = await loadJson(relativePath, timeout: timeout);
    if (decoded is List<dynamic>) {
      return decoded;
    }
    throw FormatException('Expected JSON array at $relativePath');
  }

  static Future<dynamic> _fetchJson(
    String relativePath, {
    required Duration timeout,
  }) async {
    final Uri uri = resolveUri(relativePath);
    final http.Response response = await http.get(uri).timeout(timeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'GitHub data request failed (${response.statusCode}) for $relativePath',
      );
    }
    return jsonDecode(response.body);
  }

  static void clearCache() {
    _jsonCache.clear();
  }
}
