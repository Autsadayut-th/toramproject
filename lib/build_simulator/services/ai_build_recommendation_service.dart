import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ai/recommendation_item.dart';

class AiBuildRecommendationResult {
  const AiBuildRecommendationResult({
    required this.recommendationItems,
    required this.recommendations,
    required this.source,
    required this.message,
    required this.providerMessage,
    required this.summary,
    required this.explanations,
  });

  final List<AiRecommendationItem> recommendationItems;
  final List<String> recommendations;
  final String source;
  final String message;
  final String providerMessage;
  final String summary;
  final List<String> explanations;
}

class AiBuildRecommendationService {
  const AiBuildRecommendationService();

  static const Duration _cacheTtl = Duration(minutes: 5);
  static const int _maxAttempts = 2;
  static final Map<String, _AiRecommendationCacheEntry> _cache =
      <String, _AiRecommendationCacheEntry>{};

  Future<AiBuildRecommendationResult> fetchRecommendations({
    required Map<String, dynamic> payload,
    Duration timeout = const Duration(seconds: 22),
  }) async {
    final String cacheKey = _payloadCacheKey(payload);
    final DateTime now = DateTime.now();
    final _AiRecommendationCacheEntry? cached = _cache[cacheKey];
    if (cached != null && now.difference(cached.cachedAt) <= _cacheTtl) {
      return cached.result;
    }

    final Uri endpoint = _resolveEndpoint();
    Object? lastError;
    for (int attempt = 0; attempt < _maxAttempts; attempt++) {
      try {
        final http.Response response = await http
            .post(
              endpoint,
              headers: const <String, String>{
                'Content-Type': 'application/json',
              },
              body: jsonEncode(payload),
            )
            .timeout(timeout);

        if (_isRetryableStatusCode(response.statusCode) &&
            attempt < _maxAttempts - 1) {
          await Future<void>.delayed(_retryDelay(attempt));
          continue;
        }

        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw Exception(
            'AI recommendation request failed (${response.statusCode})',
          );
        }

        final dynamic decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Invalid AI response payload.');
        }

        final String source =
            decoded['source']?.toString().trim().toLowerCase() ?? 'unknown';
        final String message = decoded['message']?.toString().trim() ?? '';
        final String providerMessage =
            decoded['providerMessage']?.toString().trim() ?? '';
        final String summary = decoded['summary']?.toString().trim() ?? '';
        final List<String> explanations = _readStringList(
          decoded['explanations'],
        );

        final List<AiRecommendationItem> recommendationItems =
            _readRecommendationItems(
              v2Payload: decoded['recommendationsV2'],
              v1Payload: decoded['recommendations'],
              source: source.isEmpty ? 'unknown' : source,
              fallbackExplanations: explanations,
            );
        if (recommendationItems.isEmpty) {
          throw const FormatException('AI response has no recommendations.');
        }

        final List<String> normalizedExplanations = recommendationItems
            .map((AiRecommendationItem item) {
              final String explanation = item.explanation.trim();
              if (explanation.isNotEmpty) {
                return explanation;
              }
              return 'This recommendation addresses: ${item.normalizedMessage}';
            })
            .toList(growable: false);

        final List<String> recommendations = recommendationItems
            .map((AiRecommendationItem item) => item.normalizedMessage)
            .where((String message) => message.isNotEmpty)
            .take(6)
            .toList(growable: false);

        final AiBuildRecommendationResult result = AiBuildRecommendationResult(
          recommendationItems: recommendationItems
              .take(6)
              .toList(growable: false),
          recommendations: recommendations,
          source: source.isEmpty ? 'unknown' : source,
          message: message,
          providerMessage: providerMessage,
          summary: summary,
          explanations: normalizedExplanations.take(6).toList(growable: false),
        );

        if (result.source == 'gemini') {
          _cache[cacheKey] = _AiRecommendationCacheEntry(
            result: result,
            cachedAt: now,
          );
        }
        return result;
      } catch (error) {
        lastError = error;
        final bool canRetry =
            _isRetryableError(error) && attempt < _maxAttempts - 1;
        if (!canRetry) {
          rethrow;
        }
        await Future<void>.delayed(_retryDelay(attempt));
      }
    }

    throw lastError ??
        const FormatException('AI recommendation request failed unexpectedly.');
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

  String _payloadCacheKey(Map<String, dynamic> payload) {
    return jsonEncode(payload);
  }

  bool _isRetryableStatusCode(int statusCode) {
    return statusCode == 429 ||
        statusCode == 502 ||
        statusCode == 503 ||
        statusCode == 504;
  }

  bool _isRetryableError(Object error) {
    if (error is http.ClientException) {
      return true;
    }
    return false;
  }

  Duration _retryDelay(int attempt) {
    final int millis = 350 * (attempt + 1);
    return Duration(milliseconds: millis);
  }

  List<AiRecommendationItem> _readRecommendationItems({
    required dynamic v2Payload,
    required dynamic v1Payload,
    required String source,
    required List<String> fallbackExplanations,
  }) {
    final List<AiRecommendationItem> normalized = <AiRecommendationItem>[];

    if (v2Payload is List) {
      for (int i = 0; i < v2Payload.length; i++) {
        final dynamic raw = v2Payload[i];
        if (raw is! Map) {
          continue;
        }
        final Map<String, dynamic> data = Map<String, dynamic>.from(raw);
        final String message = _readMessage(data);
        if (message.isEmpty) {
          continue;
        }

        final int priority = _readInt(data['priority'], fallback: 3);
        final double confidence = _readDouble(
          data['confidence'],
          fallback: 0.7,
        );
        final String category =
            data['category']?.toString().trim() ?? 'analysis';
        final String itemSource = data['source']?.toString().trim() ?? source;
        final String reason = data['reason']?.toString().trim() ?? '';
        final String explanation = _readExplanation(
          data: data,
          index: i,
          fallbackExplanations: fallbackExplanations,
        );
        final String id =
            data['id']?.toString().trim() ??
            AiRecommendationItem.buildId(category, message);

        _addItem(
          normalized,
          AiRecommendationItem.fromText(
            id: id,
            message: message,
            category: category,
            priority: priority,
            source: itemSource,
            confidence: confidence,
            reason: reason,
            explanation: explanation,
          ),
        );
      }
    }

    if (normalized.isEmpty) {
      final List<String> legacy = _readStringList(v1Payload);
      for (int i = 0; i < legacy.length; i++) {
        final String message = legacy[i].trim();
        if (message.isEmpty) {
          continue;
        }
        final String explanation = i < fallbackExplanations.length
            ? fallbackExplanations[i]
            : '';
        _addItem(
          normalized,
          AiRecommendationItem.fromText(
            message: message,
            category: 'analysis',
            priority: 3,
            source: source,
            confidence: 0.7,
            explanation: explanation,
          ),
        );
      }
    }

    return normalized.take(6).toList(growable: false);
  }

  String _readExplanation({
    required Map<String, dynamic> data,
    required int index,
    required List<String> fallbackExplanations,
  }) {
    final String direct =
        data['explanation']?.toString().trim() ??
        data['explain']?.toString().trim() ??
        '';
    if (direct.isNotEmpty) {
      return direct;
    }
    if (index < fallbackExplanations.length) {
      return fallbackExplanations[index].trim();
    }
    return '';
  }

  String _readMessage(Map<String, dynamic> data) {
    final String message =
        data['message']?.toString().trim() ??
        data['text']?.toString().trim() ??
        data['recommendation']?.toString().trim() ??
        '';
    return message;
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

  int _readInt(dynamic value, {required int fallback}) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim()) ?? fallback;
    }
    return fallback;
  }

  double _readDouble(dynamic value, {required double fallback}) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.trim()) ?? fallback;
    }
    return fallback;
  }

  void _addItem(
    List<AiRecommendationItem> items,
    AiRecommendationItem candidate,
  ) {
    if (!candidate.isValid) {
      return;
    }
    final String message = candidate.normalizedMessage;
    for (final AiRecommendationItem existing in items) {
      if (existing.normalizedMessage == message) {
        return;
      }
    }
    items.add(candidate);
  }
}

class _AiRecommendationCacheEntry {
  const _AiRecommendationCacheEntry({
    required this.result,
    required this.cachedAt,
  });

  final AiBuildRecommendationResult result;
  final DateTime cachedAt;
}
