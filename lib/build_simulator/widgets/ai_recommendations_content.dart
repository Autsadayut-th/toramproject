import 'package:flutter/material.dart';

import '../services/ai/recommendation_item.dart';

class AiRecommendationsContent extends StatelessWidget {
  const AiRecommendationsContent({
    super.key,
    required this.aiMessage,
    required this.statusIcon,
    required this.statusColor,
    required this.statusLabel,
    required this.sourceLabel,
    required this.canGenerateAi,
    required this.canSendFeedback,
    required this.isLoading,
    required this.onGenerate,
    required this.recommendationItems,
    required this.feedbackByRecommendationId,
    required this.showAllRecommendations,
    required this.onToggleShowAll,
    this.onFeedback,
    this.isSmallScreen = false,
    this.useCardShadow = false,
    this.showLoginGenerateHint = false,
    this.showLoginFeedbackHint = false,
    this.collapsedRecommendationLimit = 3,
  });

  final String aiMessage;
  final IconData statusIcon;
  final Color statusColor;
  final String statusLabel;
  final String sourceLabel;
  final bool canGenerateAi;
  final bool canSendFeedback;
  final bool isLoading;
  final VoidCallback onGenerate;
  final List<AiRecommendationItem> recommendationItems;
  final Map<String, String> feedbackByRecommendationId;
  final bool showAllRecommendations;
  final VoidCallback onToggleShowAll;
  final void Function(AiRecommendationItem recommendation, String reaction)?
  onFeedback;
  final bool isSmallScreen;
  final bool useCardShadow;
  final bool showLoginGenerateHint;
  final bool showLoginFeedbackHint;
  final int collapsedRecommendationLimit;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool hasOverflowRecommendations =
        recommendationItems.length > collapsedRecommendationLimit;
    final List<AiRecommendationItem> visibleRecommendationItems =
        showAllRecommendations || !hasOverflowRecommendations
        ? recommendationItems
        : recommendationItems
              .take(collapsedRecommendationLimit)
              .toList(growable: false);

    final List<Widget> children = <Widget>[];
    if (isLoading) {
      children
        ..add(
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Center(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    width: 42,
                    height: 42,
                    child: Image.asset(
                      'assets/logo/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.auto_awesome,
                          size: 24,
                          color: colorScheme.tertiary,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Generating recommendations...',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurface.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        ..addAll(
          List<Widget>.generate(3, (int index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
                border: Border(
                  left: BorderSide(
                    color: colorScheme.tertiary.withValues(alpha: 0.7),
                    width: 3,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    height: 11,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 180,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            );
          }),
        );
    } else if (visibleRecommendationItems.isEmpty) {
      children.add(
        Text(
          'No recommendations yet.',
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.75),
            fontSize: 12,
          ),
        ),
      );
    } else {
      for (int i = 0; i < visibleRecommendationItems.length; i++) {
        final AiRecommendationItem recommendation = visibleRecommendationItems[i];
        final String feedbackState =
            feedbackByRecommendationId[recommendation.id] ?? '';
        final String categoryLabel = recommendation.category
            .replaceAll('_', ' ')
            .trim();
        children.add(
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.symmetric(
              vertical: isSmallScreen ? 10 : 12,
              horizontal: isSmallScreen ? 10 : 12,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(
                  color: colorScheme.primary.withValues(alpha: 0.85),
                  width: 3,
                ),
              ),
              boxShadow: useCardShadow
                  ? <BoxShadow>[
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${i + 1}.',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 12 : 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        recommendation.message,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 11.5 : 12.5,
                          height: 1.35,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.onSurface.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Text(
                        categoryLabel,
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.onSurface.withValues(alpha: 0.82),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (recommendation.explanation.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 6),
                  Text(
                    recommendation.explanation.trim(),
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurface.withValues(alpha: 0.75),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    InkWell(
                      onTap: !canSendFeedback || onFeedback == null
                          ? null
                          : () => onFeedback!(recommendation, 'like'),
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        child: Icon(
                          Icons.thumb_up_alt_outlined,
                          size: 14,
                          color: feedbackState == 'like'
                              ? colorScheme.primary
                              : colorScheme.onSurface.withValues(alpha: 0.54),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: !canSendFeedback || onFeedback == null
                          ? null
                          : () => onFeedback!(recommendation, 'dislike'),
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        child: Icon(
                          Icons.thumb_down_alt_outlined,
                          size: 14,
                          color: feedbackState == 'dislike'
                              ? colorScheme.error
                              : colorScheme.onSurface.withValues(alpha: 0.54),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'p${recommendation.priority} - ${(recommendation.confidence * 100).round()}%',
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.onSurface.withValues(alpha: 0.54),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(statusIcon, size: 14, color: statusColor),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                aiMessage,
                maxLines: isSmallScreen ? 2 : 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: statusColor),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.center,
          child: OutlinedButton.icon(
            onPressed: !canGenerateAi || isLoading ? null : onGenerate,
            icon: Icon(
              !canGenerateAi
                  ? Icons.lock_outline
                  : isLoading
                  ? Icons.sync
                  : Icons.auto_awesome,
              size: 14,
            ),
            label: Text(
              !canGenerateAi
                  ? 'Login for AI'
                  : isLoading
                  ? 'Generating...'
                  : 'Generate',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.onSurface,
              side: BorderSide(
                color: colorScheme.onSurface.withValues(alpha: 0.35),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 20 : 24,
                vertical: isSmallScreen ? 9 : 10,
              ),
              shape: const StadiumBorder(),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              sourceLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.82),
              ),
            ),
          ),
        ),
        if (showLoginGenerateHint) ...<Widget>[
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Login is required for AI Generate.',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withValues(alpha: 0.54),
              ),
            ),
          ),
        ],
        if (showLoginFeedbackHint) ...<Widget>[
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Login to send recommendation feedback.',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withValues(alpha: 0.54),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Column(children: children),
        if (!isLoading && hasOverflowRecommendations) ...<Widget>[
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: onToggleShowAll,
              child: Text(
                showAllRecommendations
                    ? 'Show less'
                    : 'Show more (${recommendationItems.length - collapsedRecommendationLimit})',
              ),
            ),
          ),
        ],
      ],
    );
  }
}
