import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toramonline/build_simulator/services/ai/recommendation_item.dart';
import 'package:toramonline/build_simulator/widgets/ai_recommendations_content.dart';

void main() {
  Widget buildHarness({
    required bool isLoading,
    required String statusLabel,
    required String aiMessage,
    required List<AiRecommendationItem> items,
    Map<String, String> feedbackByRecommendationId = const <String, String>{},
    bool canSendFeedback = true,
    void Function(AiRecommendationItem recommendation, String reaction)? onFeedback,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: AiRecommendationsContent(
          aiMessage: aiMessage,
          statusIcon: Icons.info_outline,
          statusColor: Colors.blue,
          statusLabel: statusLabel,
          sourceLabel: 'Source: Fallback rule',
          canGenerateAi: true,
          canSendFeedback: canSendFeedback,
          isLoading: isLoading,
          onGenerate: () {},
          recommendationItems: items,
          feedbackByRecommendationId: feedbackByRecommendationId,
          showAllRecommendations: true,
          onToggleShowAll: () {},
          onFeedback: onFeedback,
        ),
      ),
    );
  }

  testWidgets('transitions from loading to fallback recommendations', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildHarness(
        isLoading: true,
        statusLabel: 'Loading',
        aiMessage: 'AI explaining local recommendations...',
        items: const <AiRecommendationItem>[],
      ),
    );

    expect(find.text('Generating recommendations...'), findsOneWidget);
    expect(find.text('Loading'), findsOneWidget);

    final List<AiRecommendationItem> fallbackItems = <AiRecommendationItem>[
      AiRecommendationItem.fromText(
        message: 'Upgrade refine level for stronger damage output.',
        category: 'rule',
        source: 'fallback',
        priority: 2,
        confidence: 0.8,
      ),
    ];

    await tester.pumpWidget(
      buildHarness(
        isLoading: false,
        statusLabel: 'Fallback',
        aiMessage: 'Using local fallback recommendations.',
        items: fallbackItems,
      ),
    );
    await tester.pump();

    expect(find.text('Generating recommendations...'), findsNothing);
    expect(find.text('Fallback'), findsOneWidget);
    expect(
      find.text('Upgrade refine level for stronger damage output.'),
      findsOneWidget,
    );
  });

  testWidgets('feedback tap sends like reaction callback', (
    WidgetTester tester,
  ) async {
    final List<String> reactions = <String>[];
    final AiRecommendationItem item = AiRecommendationItem.fromText(
      message: 'Balance STR and DEX for this build.',
      category: 'stat',
      source: 'rule',
      priority: 3,
      confidence: 0.7,
    );

    await tester.pumpWidget(
      buildHarness(
        isLoading: false,
        statusLabel: 'Fallback',
        aiMessage: 'Using local fallback recommendations.',
        items: <AiRecommendationItem>[item],
        onFeedback: (AiRecommendationItem recommendation, String reaction) {
          reactions.add('${recommendation.id}:$reaction');
        },
      ),
    );

    final Finder thumbsUp = find.byIcon(Icons.thumb_up_alt_outlined);
    expect(thumbsUp, findsOneWidget);

    await tester.tap(thumbsUp);
    await tester.pump();

    expect(reactions, hasLength(1));
    expect(reactions.single.endsWith(':like'), isTrue);
  });
}
