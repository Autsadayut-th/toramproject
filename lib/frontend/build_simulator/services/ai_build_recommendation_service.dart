import 'dart:convert';

import 'package:http/http.dart' as http;

class AiBuildRecommendationResult {
  const AiBuildRecommendationResult({
    required this.recommendations,
    required this.source,
    required this.message,
  });

  final List<String> recommendations;
  final String source;
  final String message;
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
    final String message = decoded['message']?.toString().trim() ?? '';
    return AiBuildRecommendationResult(
      recommendations: recommendations.take(6).toList(growable: false),
      source: source.isEmpty ? 'unknown' : source,
      message: message,
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
      if (item.isEmpty) {
        continue;
      }
      final List<String> nested = _extractNestedRecommendations(item);
      if (nested.isNotEmpty) {
        for (final String nestedItem in nested) {
          if (!items.contains(nestedItem)) {
            items.add(nestedItem);
          }
        }
        continue;
      }

      if (_looksLikeRecommendationJson(item) || items.contains(item)) {
        continue;
      }
      items.add(item);
    }
    return items;
  }

  bool _looksLikeRecommendationJson(String text) {
    final String normalized = text.trim().toLowerCase();
    if (normalized.isEmpty) {
      return false;
    }
    return normalized.startsWith('{') ||
        normalized.startsWith('[') ||
        normalized.contains('"recommendations"');
  }

  List<String> _extractNestedRecommendations(String text) {
    final String cleaned = text.trim();
    if (cleaned.isEmpty) {
      return const <String>[];
    }

    try {
      final dynamic parsed = jsonDecode(cleaned);
      if (parsed is List) {
        return parsed
            .map((dynamic value) => value.toString().trim())
            .where((String value) => value.isNotEmpty)
            .toList(growable: false);
      }
      if (parsed is Map<String, dynamic> && parsed['recommendations'] is List) {
        return (parsed['recommendations'] as List)
            .map((dynamic value) => value.toString().trim())
            .where((String value) => value.isNotEmpty)
            .toList(growable: false);
      }
    } catch (_) {
      // Keep empty to let caller handle fallback paths.
    }

    final RegExp looseRegex = RegExp(
      r'"recommendations"\s*:\s*\[([\s\S]*?)\]',
      caseSensitive: false,
    );
    final RegExpMatch? match = looseRegex.firstMatch(cleaned);
    if (match == null) {
      return const <String>[];
    }
    final String body = match.group(1) ?? '';
    final Iterable<RegExpMatch> tokens = RegExp(
      r'"((?:\\.|[^"\\])*)"',
    ).allMatches(body);
    final List<String> values = <String>[];
    for (final RegExpMatch token in tokens) {
      final String rawToken = token.group(1) ?? '';
      if (rawToken.isEmpty) {
        continue;
      }
      final String value = rawToken.replaceAll(r'\"', '"').trim();
      if (value.isNotEmpty) {
        values.add(value);
      }
    }
    return values.toList(growable: false);
  }
}
