import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'ai/recommendation_item.dart';

class RecommendationFeedbackAggregate {
  const RecommendationFeedbackAggregate({
    required this.likes,
    required this.dislikes,
  });

  final int likes;
  final int dislikes;

  int get total => likes + dislikes;
  int get net => likes - dislikes;

  double get approvalRate {
    if (total <= 0) {
      return 0.5;
    }
    return likes / total;
  }
}

class RecommendationFeedbackSnapshot {
  const RecommendationFeedbackSnapshot({
    required this.byRecommendationId,
    required this.byCategory,
  });

  const RecommendationFeedbackSnapshot.empty()
    : byRecommendationId = const <String, RecommendationFeedbackAggregate>{},
      byCategory = const <String, RecommendationFeedbackAggregate>{};

  final Map<String, RecommendationFeedbackAggregate> byRecommendationId;
  final Map<String, RecommendationFeedbackAggregate> byCategory;

  bool get isEmpty => byRecommendationId.isEmpty && byCategory.isEmpty;
}

class RecommendationFeedbackService {
  RecommendationFeedbackService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? _safeAuth(),
       _firestore = firestore ?? _safeFirestore();

  static const String _collectionName = 'recommendation_feedback';
  static const int _defaultPersonalLimit = 150;
  static const int _defaultGlobalLimit = 300;

  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;

  static FirebaseAuth? _safeAuth() {
    try {
      if (Firebase.apps.isEmpty) {
        return null;
      }
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  static FirebaseFirestore? _safeFirestore() {
    try {
      if (Firebase.apps.isEmpty) {
        return null;
      }
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  String? get currentUserId {
    final String uid = _auth?.currentUser?.uid.trim() ?? '';
    if (uid.isEmpty) {
      return null;
    }
    return uid;
  }

  Future<void> submitFeedback({
    required String? userId,
    required String reaction,
    required AiRecommendationItem recommendation,
    required String source,
    required int level,
    required String personalStatType,
    required int personalStatValue,
    required Map<String, num> summary,
    required Map<String, dynamic> character,
    required Map<String, dynamic> equipmentSlots,
  }) async {
    final FirebaseFirestore? firestore = _firestore;
    if (firestore == null) {
      return;
    }

    final String normalizedReaction = reaction.trim().toLowerCase();
    if (normalizedReaction != 'like' && normalizedReaction != 'dislike') {
      return;
    }
    if (!recommendation.isValid) {
      return;
    }

    final String? resolvedUserId = _resolveUserId(userId);
    final Map<String, dynamic> payload = <String, dynamic>{
      'recommendation': recommendation.toJson(),
      'reaction': normalizedReaction,
      'source': source.trim().toLowerCase(),
      'build': <String, dynamic>{
        'level': level,
        'personalStatType': personalStatType.trim().toUpperCase(),
        'personalStatValue': personalStatValue,
        'summary': Map<String, num>.from(summary),
        'character': Map<String, dynamic>.from(character),
        'equipmentSlots': Map<String, dynamic>.from(equipmentSlots),
      },
      'createdAt': FieldValue.serverTimestamp(),
    };
    if (resolvedUserId != null) {
      payload['userId'] = resolvedUserId;
    }

    await firestore.collection(_collectionName).add(payload);
  }

  Future<RecommendationFeedbackSnapshot> loadFeedbackSnapshot({
    String? userId,
    int personalLimit = _defaultPersonalLimit,
    int globalLimit = _defaultGlobalLimit,
  }) async {
    final FirebaseFirestore? firestore = _firestore;
    if (firestore == null) {
      return const RecommendationFeedbackSnapshot.empty();
    }

    final String? resolvedUserId = _resolveUserId(userId);
    final Set<String> seenDocIds = <String>{};
    final Map<String, _MutableAggregate> byRecommendationId =
        <String, _MutableAggregate>{};
    final Map<String, _MutableAggregate> byCategory =
        <String, _MutableAggregate>{};

    if (resolvedUserId != null) {
      final QuerySnapshot<Map<String, dynamic>> personalSnapshot =
          await firestore
              .collection(_collectionName)
              .where('userId', isEqualTo: resolvedUserId)
              .limit(personalLimit.clamp(1, 500).toInt())
              .get();
      _consumeSnapshot(
        snapshot: personalSnapshot,
        weight: 2,
        seenDocIds: seenDocIds,
        byRecommendationId: byRecommendationId,
        byCategory: byCategory,
      );
    }

    final QuerySnapshot<Map<String, dynamic>> globalSnapshot = await firestore
        .collection(_collectionName)
        .limit(globalLimit.clamp(1, 1000).toInt())
        .get();
    _consumeSnapshot(
      snapshot: globalSnapshot,
      weight: 1,
      seenDocIds: seenDocIds,
      byRecommendationId: byRecommendationId,
      byCategory: byCategory,
    );

    return RecommendationFeedbackSnapshot(
      byRecommendationId: _freeze(byRecommendationId),
      byCategory: _freeze(byCategory),
    );
  }

  int priorityDeltaFor({
    required AiRecommendationItem recommendation,
    required RecommendationFeedbackSnapshot snapshot,
  }) {
    final double score = preferenceScoreFor(
      recommendation: recommendation,
      snapshot: snapshot,
    );
    final double volume = _feedbackVolumeFor(
      recommendation: recommendation,
      snapshot: snapshot,
    );
    if (volume < 3) {
      return 0;
    }
    if (volume >= 10 && score >= 0.75) {
      return -2;
    }
    if (volume >= 4 && score >= 0.6) {
      return -1;
    }
    if (volume >= 10 && score <= 0.25) {
      return 2;
    }
    if (volume >= 4 && score <= 0.4) {
      return 1;
    }
    return 0;
  }

  double preferenceScoreFor({
    required AiRecommendationItem recommendation,
    required RecommendationFeedbackSnapshot snapshot,
  }) {
    final RecommendationFeedbackAggregate? idAggregate =
        snapshot.byRecommendationId[recommendation.id.trim()];
    final RecommendationFeedbackAggregate? categoryAggregate =
        snapshot.byCategory[AiRecommendationItem.normalizeCategory(
          recommendation.category,
        )];
    final double weightedLikes =
        (idAggregate?.likes ?? 0) + ((categoryAggregate?.likes ?? 0) * 0.35);
    final double weightedDislikes =
        (idAggregate?.dislikes ?? 0) +
        ((categoryAggregate?.dislikes ?? 0) * 0.35);
    final double weightedTotal = weightedLikes + weightedDislikes;
    if (weightedTotal <= 0) {
      return 0.5;
    }
    return weightedLikes / weightedTotal;
  }

  double _feedbackVolumeFor({
    required AiRecommendationItem recommendation,
    required RecommendationFeedbackSnapshot snapshot,
  }) {
    final RecommendationFeedbackAggregate? idAggregate =
        snapshot.byRecommendationId[recommendation.id.trim()];
    final RecommendationFeedbackAggregate? categoryAggregate =
        snapshot.byCategory[AiRecommendationItem.normalizeCategory(
          recommendation.category,
        )];
    return (idAggregate?.total ?? 0) + ((categoryAggregate?.total ?? 0) * 0.35);
  }

  void _consumeSnapshot({
    required QuerySnapshot<Map<String, dynamic>> snapshot,
    required int weight,
    required Set<String> seenDocIds,
    required Map<String, _MutableAggregate> byRecommendationId,
    required Map<String, _MutableAggregate> byCategory,
  }) {
    for (final QueryDocumentSnapshot<Map<String, dynamic>> document
        in snapshot.docs) {
      if (!seenDocIds.add(document.id)) {
        continue;
      }

      final Map<String, dynamic> data = document.data();
      final String reaction = (data['reaction'] ?? '')
          .toString()
          .trim()
          .toLowerCase();
      if (reaction != 'like' && reaction != 'dislike') {
        continue;
      }
      final dynamic rawRecommendation = data['recommendation'];
      if (rawRecommendation is! Map) {
        continue;
      }
      final Map<String, dynamic> recommendation = Map<String, dynamic>.from(
        rawRecommendation,
      );
      final String recommendationId =
          recommendation['id']?.toString().trim() ?? '';
      final String category = AiRecommendationItem.normalizeCategory(
        recommendation['category']?.toString() ?? '',
      );

      if (recommendationId.isNotEmpty) {
        final _MutableAggregate aggregate =
            byRecommendationId[recommendationId] ?? _MutableAggregate();
        aggregate.add(reaction: reaction, weight: weight);
        byRecommendationId[recommendationId] = aggregate;
      }

      final _MutableAggregate categoryAggregate =
          byCategory[category] ?? _MutableAggregate();
      categoryAggregate.add(reaction: reaction, weight: weight);
      byCategory[category] = categoryAggregate;
    }
  }

  Map<String, RecommendationFeedbackAggregate> _freeze(
    Map<String, _MutableAggregate> source,
  ) {
    final Map<String, RecommendationFeedbackAggregate> frozen =
        <String, RecommendationFeedbackAggregate>{};
    for (final MapEntry<String, _MutableAggregate> entry in source.entries) {
      final String key = entry.key.trim();
      if (key.isEmpty) {
        continue;
      }
      frozen[key] = RecommendationFeedbackAggregate(
        likes: entry.value.likes,
        dislikes: entry.value.dislikes,
      );
    }
    return frozen;
  }

  String? _resolveUserId(String? userId) {
    final String normalizedInput = userId?.trim() ?? '';
    if (normalizedInput.isNotEmpty) {
      return normalizedInput;
    }
    return currentUserId;
  }
}

class _MutableAggregate {
  int likes = 0;
  int dislikes = 0;

  void add({required String reaction, required int weight}) {
    final int normalizedWeight = weight < 1 ? 1 : weight;
    if (reaction == 'like') {
      likes += normalizedWeight;
      return;
    }
    if (reaction == 'dislike') {
      dislikes += normalizedWeight;
    }
  }
}
