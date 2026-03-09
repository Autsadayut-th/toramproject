import 'ai_models.dart';
import 'recommendation_item.dart';

class AiDeterministicRecommender {
  const AiDeterministicRecommender();

  List<AiRecommendationItem> suggest(AiBuildContext context) {
    final List<AiRecommendationItem> items = <AiRecommendationItem>[];
    _addEquipmentSuggestions(items, context);
    _addCrystaSuggestions(items, context);
    _addUpgradePathSuggestions(items, context);
    return items.toList(growable: false);
  }

  void _addEquipmentSuggestions(
    List<AiRecommendationItem> items,
    AiBuildContext context,
  ) {
    final List<String> missingSlots = context.equipmentSlots
        .missingSlotLabels();
    if (missingSlots.isNotEmpty) {
      _add(
        items,
        AiRecommendationItem.fromText(
          message:
              'Equipment baseline is incomplete. Fill: ${missingSlots.join(', ')}.',
          category: 'equipment',
          priority: 1,
          source: 'rule',
          confidence: 0.97,
          reason:
              'Missing equipment slots reduce stat baseline and build stability.',
        ),
      );
    }

    if (!AiBuildContext.isEmpty(context.equipmentSlots.mainWeaponId) &&
        context.equipmentSlots.enhanceMain < 9 &&
        context.level >= 60) {
      _add(
        items,
        AiRecommendationItem.fromText(
          message:
              'Upgrade path: refine Main Weapon from +${context.equipmentSlots.enhanceMain} toward +9 for stable attack scaling.',
          category: 'upgrade_path',
          priority: 2,
          source: 'rule',
          confidence: 0.9,
          reason:
              'Weapon refine gives one of the largest deterministic damage gains.',
        ),
      );
    }
  }

  void _addCrystaSuggestions(
    List<AiRecommendationItem> items,
    AiBuildContext context,
  ) {
    for (final MapEntry<String, List<String>> entry
        in context.crystalKeysByEquipment.entries) {
      final String equipmentSlot = entry.key.trim();
      final List<String> equipped = entry.value
          .map((String key) => key.trim().toLowerCase())
          .where((String key) => key.isNotEmpty)
          .toList(growable: false);
      if (equipmentSlot.isEmpty) {
        continue;
      }

      if (equipped.isEmpty) {
        _add(
          items,
          AiRecommendationItem.fromText(
            message:
                '$equipmentSlot has no crysta. Add at least one crysta matching your main damage type.',
            category: 'crysta',
            priority: 2,
            source: 'rule',
            confidence: 0.88,
            reason: 'Empty crysta slots leave deterministic stats unused.',
          ),
        );
      } else if (equipped.length == 1) {
        _add(
          items,
          AiRecommendationItem.fromText(
            message:
                '$equipmentSlot has one crysta only. Fill second slot when available for better stat efficiency.',
            category: 'crysta',
            priority: 3,
            source: 'rule',
            confidence: 0.82,
            reason:
                'Using all available crysta slots improves total build value.',
          ),
        );
      }
    }

    final bool hasPhysicalOffenseCrysta = context.hasAnyStat(<String>{
      'critical_rate',
      'physical_pierce',
    });
    final bool hasMagicOffenseCrysta = context.hasAnyStat(<String>{
      'magic_pierce',
      'cast_speed',
      'cspd',
    });
    if (context.physicalFocus &&
        !hasPhysicalOffenseCrysta &&
        context.level >= 70) {
      _add(
        items,
        AiRecommendationItem.fromText(
          message:
              'Crysta priority: add Critical Rate or Physical Pierce crysta to stabilize physical DPS.',
          category: 'crysta',
          priority: 2,
          source: 'rule',
          confidence: 0.86,
          reason: 'Current build lacks common physical offense crysta stats.',
        ),
      );
    }
    if (!context.physicalFocus &&
        !hasMagicOffenseCrysta &&
        context.level >= 70) {
      _add(
        items,
        AiRecommendationItem.fromText(
          message:
              'Crysta priority: add Magic Pierce or CSPD-oriented crysta for smoother magic rotation.',
          category: 'crysta',
          priority: 2,
          source: 'rule',
          confidence: 0.86,
          reason: 'Current build lacks common magic offense crysta stats.',
        ),
      );
    }
  }

  void _addUpgradePathSuggestions(
    List<AiRecommendationItem> items,
    AiBuildContext context,
  ) {
    final Map<String, List<String>> childrenByParent = <String, List<String>>{};
    for (final MapEntry<String, String?> entry
        in context.crystalUpgradeFromByKey.entries) {
      final String child = entry.key.trim().toLowerCase();
      final String parent = (entry.value ?? '').trim().toLowerCase();
      if (child.isEmpty || parent.isEmpty) {
        continue;
      }
      final List<String> children = childrenByParent[parent] ?? <String>[];
      children.add(child);
      childrenByParent[parent] = children;
    }

    final Set<String> uniqueEquippedCrystals = <String>{};
    for (final List<String> keys in context.crystalKeysByEquipment.values) {
      for (final String key in keys) {
        final String normalized = key.trim().toLowerCase();
        if (normalized.isEmpty) {
          continue;
        }
        uniqueEquippedCrystals.add(normalized);
      }
    }

    for (final String equipped in uniqueEquippedCrystals) {
      final List<String> nextCandidates =
          childrenByParent[equipped] ?? const <String>[];
      if (nextCandidates.isEmpty) {
        continue;
      }
      final String next = nextCandidates.first;
      _add(
        items,
        AiRecommendationItem.fromText(
          message:
              'Upgrade path: ${_displayCrystaName(equipped)} -> ${_displayCrystaName(next)} when budget allows.',
          category: 'upgrade_path',
          priority: 3,
          source: 'rule',
          confidence: 0.8,
          reason: 'Detected known crysta upgrade chain from current equipment.',
        ),
      );
    }
  }

  String _displayCrystaName(String key) {
    final String cleaned = key.trim().toLowerCase().replaceAll('_', ' ');
    if (cleaned.isEmpty) {
      return 'Unknown Crysta';
    }
    final List<String> words = cleaned
        .split(' ')
        .where((String token) => token.isNotEmpty)
        .toList(growable: false);
    return words
        .map((String token) {
          if (token.length == 1) {
            return token.toUpperCase();
          }
          return '${token[0].toUpperCase()}${token.substring(1)}';
        })
        .join(' ');
  }

  void _add(List<AiRecommendationItem> items, AiRecommendationItem candidate) {
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
