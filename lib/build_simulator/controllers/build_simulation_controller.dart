import '../../equipment_library/models/equipment_library_item.dart';
import '../services/build_calculator_service.dart';
import '../services/build_recommendation_service.dart';
import '../services/build_rule_set_service.dart';
import '../services/ai/recommendation_item.dart';

class BuildSimulationRequest {
  const BuildSimulationRequest({
    required this.character,
    required this.level,
    required this.personalStatType,
    required this.personalStatValue,
    required this.enhMain,
    required this.enhSub,
    required this.enhArmor,
    required this.enhHelmet,
    required this.enhRing,
    required this.armorMode,
    required this.mainToAllowedSubTypes,
    required this.ruleSet,
    required this.mainWeaponId,
    required this.subWeaponId,
    required this.armorId,
    required this.helmetId,
    required this.ringId,
    required this.findEquipmentByKey,
    required this.equippedCrystalStats,
    required this.avatarStats,
    required this.crystalKeysByEquipment,
    required this.crystalUpgradeFromByKey,
    required this.normalizeMainWeaponType,
  });

  final Map<String, dynamic> character;
  final int level;
  final String personalStatType;
  final int personalStatValue;
  final int enhMain;
  final int enhSub;
  final int enhArmor;
  final int enhHelmet;
  final int enhRing;
  final String armorMode;
  final Map<String, List<String>> mainToAllowedSubTypes;
  final BuildRuleSet? ruleSet;
  final String? mainWeaponId;
  final String? subWeaponId;
  final String? armorId;
  final String? helmetId;
  final String? ringId;
  final EquipmentLibraryItem? Function(String? key) findEquipmentByKey;
  final List<EquipmentStat> equippedCrystalStats;
  final List<EquipmentStat> avatarStats;
  final Map<String, List<String>> crystalKeysByEquipment;
  final Map<String, String?> crystalUpgradeFromByKey;
  final String Function(String? rawType) normalizeMainWeaponType;
}

class BuildSimulationResult {
  const BuildSimulationResult({
    required this.context,
    required this.summary,
    required this.recommendationItems,
    required this.recommendations,
  });

  final BuildCalculationContext context;
  final Map<String, num> summary;
  final List<AiRecommendationItem> recommendationItems;
  final List<String> recommendations;
}

class BuildSimulationController {
  const BuildSimulationController();

  BuildSimulationResult recalculateAll(BuildSimulationRequest request) {
    final EquipmentLibraryItem? mainWeapon = request.findEquipmentByKey(
      request.mainWeaponId,
    );
    final EquipmentLibraryItem? subWeapon = request.findEquipmentByKey(
      request.subWeaponId,
    );
    final EquipmentLibraryItem? armor = request.findEquipmentByKey(
      request.armorId,
    );
    final EquipmentLibraryItem? helmet = request.findEquipmentByKey(
      request.helmetId,
    );
    final EquipmentLibraryItem? ring = request.findEquipmentByKey(
      request.ringId,
    );

    final List<EquipmentLibraryItem> equippedItems = <EquipmentLibraryItem>[
      if (mainWeapon != null) mainWeapon,
      if (subWeapon != null) subWeapon,
      if (armor != null) armor,
      if (helmet != null) helmet,
      if (ring != null) ring,
    ];

    final BuildCalculationContext context =
        BuildCalculatorService.buildCalculationContext(
          armorState: request.armorMode,
          mainWeapon: mainWeapon,
          subWeapon: subWeapon,
          armor: armor,
          helmet: helmet,
          ring: ring,
          equippedCrystalStats: request.equippedCrystalStats,
          avatarStats: request.avatarStats,
          mainToAllowedSubTypes: request.mainToAllowedSubTypes,
        );

    final Map<String, num> summary = BuildCalculatorService
        .calculateSummaryFromContext(
          context: context,
          character: request.character,
          level: request.level,
          personalStatType: request.personalStatType,
          personalStatValue: request.personalStatValue,
          enhanceMain: request.enhMain,
          enhanceSub: request.enhSub,
          enhanceArmor: request.enhArmor,
          enhanceHelmet: request.enhHelmet,
          enhanceRing: request.enhRing,
          ruleSet: request.ruleSet,
        );

    final List<AiRecommendationItem> recommendationItems =
        BuildRecommendationService.generateItems(
          summary: summary,
          character: request.character,
          level: request.level,
          personalStatType: request.personalStatType,
          personalStatValue: request.personalStatValue,
          mainWeaponId: request.mainWeaponId,
          subWeaponId: request.subWeaponId,
          armorId: request.armorId,
          helmetId: request.helmetId,
          ringId: request.ringId,
          enhanceMain: request.enhMain,
          enhanceArmor: request.enhArmor,
          enhanceHelmet: request.enhHelmet,
          enhanceRing: request.enhRing,
          equippedItems: equippedItems,
          equippedCrystalStats: request.equippedCrystalStats,
          crystalKeysByEquipment: request.crystalKeysByEquipment,
          crystalUpgradeFromByKey: request.crystalUpgradeFromByKey,
          normalizedMainWeaponType: request.normalizeMainWeaponType(
            mainWeapon?.type,
          ),
          ruleSet: request.ruleSet,
        );

    return BuildSimulationResult(
      context: context,
      summary: summary,
      recommendationItems: recommendationItems,
      recommendations: recommendationItems
          .map((AiRecommendationItem item) => item.normalizedMessage)
          .toList(growable: false),
    );
  }

  BuildSimulationResult recalculateCharacterOnly({
    required BuildSimulationRequest request,
    required BuildCalculationContext cachedContext,
  }) {
    final Map<String, num> summary = BuildCalculatorService
        .calculateSummaryFromContext(
          context: cachedContext,
          character: request.character,
          level: request.level,
          personalStatType: request.personalStatType,
          personalStatValue: request.personalStatValue,
          enhanceMain: request.enhMain,
          enhanceSub: request.enhSub,
          enhanceArmor: request.enhArmor,
          enhanceHelmet: request.enhHelmet,
          enhanceRing: request.enhRing,
          ruleSet: request.ruleSet,
        );

    final EquipmentLibraryItem? mainWeapon = request.findEquipmentByKey(
      request.mainWeaponId,
    );
    final EquipmentLibraryItem? subWeapon = request.findEquipmentByKey(
      request.subWeaponId,
    );
    final EquipmentLibraryItem? armor = request.findEquipmentByKey(
      request.armorId,
    );
    final EquipmentLibraryItem? helmet = request.findEquipmentByKey(
      request.helmetId,
    );
    final EquipmentLibraryItem? ring = request.findEquipmentByKey(
      request.ringId,
    );

    final List<EquipmentLibraryItem> equippedItems = <EquipmentLibraryItem>[
      if (mainWeapon != null) mainWeapon,
      if (subWeapon != null) subWeapon,
      if (armor != null) armor,
      if (helmet != null) helmet,
      if (ring != null) ring,
    ];

    final List<AiRecommendationItem> recommendationItems =
        BuildRecommendationService.generateItems(
          summary: summary,
          character: request.character,
          level: request.level,
          personalStatType: request.personalStatType,
          personalStatValue: request.personalStatValue,
          mainWeaponId: request.mainWeaponId,
          subWeaponId: request.subWeaponId,
          armorId: request.armorId,
          helmetId: request.helmetId,
          ringId: request.ringId,
          enhanceMain: request.enhMain,
          enhanceArmor: request.enhArmor,
          enhanceHelmet: request.enhHelmet,
          enhanceRing: request.enhRing,
          equippedItems: equippedItems,
          equippedCrystalStats: request.equippedCrystalStats,
          crystalKeysByEquipment: request.crystalKeysByEquipment,
          crystalUpgradeFromByKey: request.crystalUpgradeFromByKey,
          normalizedMainWeaponType: request.normalizeMainWeaponType(
            mainWeapon?.type,
          ),
          ruleSet: request.ruleSet,
        );

    return BuildSimulationResult(
      context: cachedContext,
      summary: summary,
      recommendationItems: recommendationItems,
      recommendations: recommendationItems
          .map((AiRecommendationItem item) => item.normalizedMessage)
          .toList(growable: false),
    );
  }
}
