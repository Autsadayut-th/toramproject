class AiRecommendationItem {
  const AiRecommendationItem({
    required this.id,
    required this.message,
    required this.category,
    required this.priority,
    required this.source,
    required this.confidence,
    this.reason = '',
    this.explanation = '',
  });

  static const List<String> supportedCategories = <String>[
    'analysis',
    'stat',
    'rule',
    'crysta',
    'equipment',
    'upgrade_path',
  ];

  final String id;
  final String message;
  final String category;
  final int priority;
  final String source;
  final double confidence;
  final String reason;
  final String explanation;

  String get normalizedMessage => message.trim();

  bool get isValid => normalizedMessage.isNotEmpty;

  AiRecommendationItem copyWith({
    String? id,
    String? message,
    String? category,
    int? priority,
    String? source,
    double? confidence,
    String? reason,
    String? explanation,
  }) {
    return AiRecommendationItem(
      id: id ?? this.id,
      message: message ?? this.message,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      source: source ?? this.source,
      confidence: confidence ?? this.confidence,
      reason: reason ?? this.reason,
      explanation: explanation ?? this.explanation,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'message': message,
      'category': category,
      'priority': priority,
      'source': source,
      'confidence': confidence,
      'reason': reason,
      'explanation': explanation,
    };
  }

  static AiRecommendationItem fromText({
    required String message,
    required String category,
    required int priority,
    required String source,
    required double confidence,
    String reason = '',
    String explanation = '',
    String? id,
  }) {
    final String trimmed = message.trim();
    final String normalizedCategory = normalizeCategory(category);
    final int normalizedPriority = normalizePriority(priority);
    final double normalizedConfidence = normalizeConfidence(confidence);
    final String normalizedSource = source.trim().isEmpty
        ? 'rule'
        : source.trim().toLowerCase();
    final String normalizedReason = reason.trim();
    final String normalizedExplanation = explanation.trim();
    return AiRecommendationItem(
      id: (id ?? '').trim().isEmpty
          ? buildId(normalizedCategory, trimmed)
          : id!.trim(),
      message: trimmed,
      category: normalizedCategory,
      priority: normalizedPriority,
      source: normalizedSource,
      confidence: normalizedConfidence,
      reason: normalizedReason,
      explanation: normalizedExplanation,
    );
  }

  static String normalizeCategory(String value) {
    final String normalized = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    if (supportedCategories.contains(normalized)) {
      return normalized;
    }
    return 'analysis';
  }

  static int normalizePriority(int value) {
    return value.clamp(1, 5).toInt();
  }

  static double normalizeConfidence(double value) {
    if (!value.isFinite) {
      return 0.5;
    }
    if (value < 0) {
      return 0;
    }
    if (value > 1) {
      return 1;
    }
    return value;
  }

  static String buildId(String category, String message) {
    final String normalizedCategory = normalizeCategory(category);
    final String normalizedMessage = _slugify(message);
    if (normalizedMessage.isEmpty) {
      return '${normalizedCategory}_recommendation';
    }
    return '${normalizedCategory}_$normalizedMessage';
  }

  static String _slugify(String value) {
    String slug = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    if (slug.length > 64) {
      slug = slug.substring(0, 64);
      slug = slug.replaceFirst(RegExp(r'_+$'), '');
    }
    return slug;
  }
}
