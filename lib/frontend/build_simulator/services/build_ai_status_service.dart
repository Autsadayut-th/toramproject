class BuildAiStatusService {
  const BuildAiStatusService._();

  static bool isRemoteAiSource(String source) {
    final String normalizedSource = source.trim().toLowerCase();
    return normalizedSource == 'gemini';
  }

  static String buildStatusMessage({
    required String source,
    required String ruleRecommendationMessage,
    String? details,
  }) {
    final String normalizedSource = source.trim().toLowerCase();
    if (normalizedSource == 'gemini') {
      return 'AI recommendations from Google Gemini.';
    }

    final String sanitized = _sanitizeStatusDetails(details);
    if (sanitized.isEmpty) {
      return 'AI unavailable. $ruleRecommendationMessage';
    }
    return 'AI unavailable: $sanitized';
  }

  static String _sanitizeStatusDetails(String? details) {
    if (details == null || details.trim().isEmpty) {
      return '';
    }

    String text = details.trim();
    const List<String> prefixes = <String>[
      'Exception:',
      'FormatException:',
      'TimeoutException:',
    ];
    for (final String prefix in prefixes) {
      if (text.startsWith(prefix)) {
        text = text.substring(prefix.length).trim();
        break;
      }
    }

    text = text.replaceAll(RegExp(r'\s+'), ' ');
    if (text.length > 170) {
      return '${text.substring(0, 170)}...';
    }
    return text;
  }
}
