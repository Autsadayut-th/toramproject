import '../../equipment_library/models/equipment_library_item.dart';
import 'ai/ai_models.dart';
import 'ai/ai_recommendation_engine.dart';
import 'ai/recommendation_item.dart';
import 'build_rule_set_service.dart';

class BuildRecommendationService {
  static const AiRecommendationEngine _engine = AiRecommendationEngine();

  static List<AiRecommendationItem> generateItems({
    required Map<String, num> summary,
    required Map<String, dynamic> character,
    required int level,
    required String personalStatType,
    required int personalStatValue,
    required String? mainWeaponId,
    required String? subWeaponId,
    required String? armorId,
    required String? helmetId,
    required String? ringId,
    required int enhanceMain,
    required int enhanceArmor,
    required int enhanceHelmet,
    required int enhanceRing,
    required Iterable<EquipmentLibraryItem> equippedItems,
    required Iterable<EquipmentStat> equippedCrystalStats,
    required Map<String, List<String>> crystalKeysByEquipment,
    required Map<String, String?> crystalUpgradeFromByKey,
    required String? normalizedMainWeaponType,
    BuildRuleSet? ruleSet,
  }) {
    return _engine.generateItems(
      _buildInput(
        summary: summary,
        character: character,
        level: level,
        personalStatType: personalStatType,
        personalStatValue: personalStatValue,
        mainWeaponId: mainWeaponId,
        subWeaponId: subWeaponId,
        armorId: armorId,
        helmetId: helmetId,
        ringId: ringId,
        enhanceMain: enhanceMain,
        enhanceArmor: enhanceArmor,
        enhanceHelmet: enhanceHelmet,
        enhanceRing: enhanceRing,
        equippedItems: equippedItems,
        equippedCrystalStats: equippedCrystalStats,
        crystalKeysByEquipment: crystalKeysByEquipment,
        crystalUpgradeFromByKey: crystalUpgradeFromByKey,
        normalizedMainWeaponType: normalizedMainWeaponType,
        ruleSet: ruleSet,
      ),
    );
  }

  static List<String> generate({
    required Map<String, num> summary,
    required Map<String, dynamic> character,
    required int level,
    required String personalStatType,
    required int personalStatValue,
    required String? mainWeaponId,
    required String? subWeaponId,
    required String? armorId,
    required String? helmetId,
    required String? ringId,
    required int enhanceMain,
    required int enhanceArmor,
    required int enhanceHelmet,
    required int enhanceRing,
    required Iterable<EquipmentLibraryItem> equippedItems,
    required Iterable<EquipmentStat> equippedCrystalStats,
    required Map<String, List<String>> crystalKeysByEquipment,
    required Map<String, String?> crystalUpgradeFromByKey,
    required String? normalizedMainWeaponType,
    BuildRuleSet? ruleSet,
  }) {
    return generateItems(
          summary: summary,
          character: character,
          level: level,
          personalStatType: personalStatType,
          personalStatValue: personalStatValue,
          mainWeaponId: mainWeaponId,
          subWeaponId: subWeaponId,
          armorId: armorId,
          helmetId: helmetId,
          ringId: ringId,
          enhanceMain: enhanceMain,
          enhanceArmor: enhanceArmor,
          enhanceHelmet: enhanceHelmet,
          enhanceRing: enhanceRing,
          equippedItems: equippedItems,
          equippedCrystalStats: equippedCrystalStats,
          crystalKeysByEquipment: crystalKeysByEquipment,
          crystalUpgradeFromByKey: crystalUpgradeFromByKey,
          normalizedMainWeaponType: normalizedMainWeaponType,
          ruleSet: ruleSet,
        )
        .map((AiRecommendationItem item) => item.normalizedMessage)
        .toList(growable: false);
  }

  static AiBuildInput _buildInput({
    required Map<String, num> summary,
    required Map<String, dynamic> character,
    required int level,
    required String personalStatType,
    required int personalStatValue,
    required String? mainWeaponId,
    required String? subWeaponId,
    required String? armorId,
    required String? helmetId,
    required String? ringId,
    required int enhanceMain,
    required int enhanceArmor,
    required int enhanceHelmet,
    required int enhanceRing,
    required Iterable<EquipmentLibraryItem> equippedItems,
    required Iterable<EquipmentStat> equippedCrystalStats,
    required Map<String, List<String>> crystalKeysByEquipment,
    required Map<String, String?> crystalUpgradeFromByKey,
    required String? normalizedMainWeaponType,
    BuildRuleSet? ruleSet,
  }) {
    return AiBuildInput(
      summary: Map<String, num>.from(summary),
      character: Map<String, dynamic>.from(character),
      level: level,
      personalStatType: personalStatType,
      personalStatValue: personalStatValue,
      equipmentSlots: AiEquipmentSlots(
        mainWeaponId: mainWeaponId,
        subWeaponId: subWeaponId,
        armorId: armorId,
        helmetId: helmetId,
        ringId: ringId,
        enhanceMain: enhanceMain,
        enhanceArmor: enhanceArmor,
        enhanceHelmet: enhanceHelmet,
        enhanceRing: enhanceRing,
      ),
      equippedItems: equippedItems.toList(growable: false),
      equippedCrystalStats: equippedCrystalStats.toList(growable: false),
      crystalKeysByEquipment: crystalKeysByEquipment.map(
        (String key, List<String> value) =>
            MapEntry<String, List<String>>(key, value.toList(growable: false)),
      ),
      crystalUpgradeFromByKey: Map<String, String?>.from(
        crystalUpgradeFromByKey,
      ),
      normalizedMainWeaponType: normalizedMainWeaponType ?? '',
      ruleSet: ruleSet,
    );
  }
}
