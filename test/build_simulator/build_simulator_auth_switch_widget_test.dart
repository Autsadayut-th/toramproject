import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toramonline/build_simulator/services/ai/recommendation_item.dart';
import 'package:toramonline/build_simulator/widgets/ai_recommendations_content.dart';

void main() {
  Widget buildHarness({required bool canSendFeedback}) {
    return MaterialApp(
      home: Scaffold(
        body: AiRecommendationsContent(
          aiMessage: 'Using local fallback recommendations.',
          statusIcon: Icons.rule,
          statusColor: Colors.blue,
          statusLabel: 'Fallback',
          sourceLabel: 'Source: Fallback rule',
          canGenerateAi: true,
          canSendFeedback: canSendFeedback,
          isLoading: false,
          onGenerate: () {},
          recommendationItems: <AiRecommendationItem>[
            AiRecommendationItem.fromText(
              message: 'Keep refining your setup.',
              category: 'analysis',
              source: 'rule',
              priority: 3,
              confidence: 0.7,
            ),
          ],
          feedbackByRecommendationId: const <String, String>{},
          showAllRecommendations: true,
          onToggleShowAll: () {},
          showLoginFeedbackHint: !canSendFeedback,
        ),
      ),
    );
  }

  testWidgets('auth-like feedback hint hides when feedback is enabled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildHarness(canSendFeedback: false));
    expect(find.text('Login to send recommendation feedback.'), findsOneWidget);

    await tester.pumpWidget(buildHarness(canSendFeedback: true));
    await tester.pump();

    expect(find.text('Login to send recommendation feedback.'), findsNothing);
  });
}
