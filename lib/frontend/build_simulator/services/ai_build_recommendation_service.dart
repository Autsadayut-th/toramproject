import 'dart:convert';

import 'package:http/http.dart' as http;

class AiBuildRecommendationResult {
  const AiBuildRecommendationResult({
    required this.recommendations,
    required this.source,
  });

  final List<String> recommendations;
  final String source;
}

class AiBuildRecommendationService {
  const AiBuildRecommendationService();

  Future<AiBuildRecommendationResult> fetchRecommendations({
    required Map<String, dynamic> payload,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final Uri endpoint = _resolveEndpoint();
    final http.Response response = await http
        .post(
          endpoint,
          headers: const <String, String>{'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        )
        .timeout(timeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'AI recommendation request failed (${response.statusCode})',
      );
    }

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid AI response payload.');
    }

    final List<String> recommendations = _readStringList(
      decoded['recommendations'],
    );
    if (recommendations.isEmpty) {
      throw const FormatException('AI response has no recommendations.');
    }

    final String source =
        decoded['source']?.toString().trim().toLowerCase() ?? 'unknown';
    return AiBuildRecommendationResult(
      recommendations: recommendations.take(6).toList(growable: false),
      source: source.isEmpty ? 'unknown' : source,
    );
  }

  Uri _resolveEndpoint() {
    final Uri base = Uri.base;
    if (base.host.isEmpty) {
      return Uri.parse('/api/recommend');
    }
    return Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
      path: '/api/recommend',
    );
  }

  List<String> _readStringList(dynamic value) {
    if (value is! List) {
      return const <String>[];
    }
    final List<String> items = <String>[];
    for (final dynamic raw in value) {
      final String item = raw?.toString().trim() ?? '';
      if (item.isEmpty || items.contains(item)) {
        continue;
      }
      items.add(item);
    }
    return items;
  }
}
