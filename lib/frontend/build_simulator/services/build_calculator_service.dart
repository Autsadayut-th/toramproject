import '../../equipment_library/models/equipment_library_item.dart';

class BuildCalculatorService {
  static const Map<String, num> summaryTemplate = <String, num>{
    'ATK': 0,
    'MATK': 0,
    'DEF': 0,
    'MDEF': 0,
    'STR': 0,
    'DEX': 0,
    'INT': 0,
    'AGI': 0,
    'VIT': 0,
    'ASPD': 0,
    'CritRate': 0,
    'PhysicalPierce': 0,
    'ElementPierce': 0,
    'Accuracy': 0,
    'Stability': 0,
    'HP': 0,
    'MP': 0,
  };

  static const List<String> characterStatKeys = <String>[
    'STR',
    'DEX',
    'INT',
    'AGI',
    'VIT',
  ];

  static const List<String> personalStatOptions = <String>[
    'CRT',
    'LUK',
    'TEC',
    'MNT',
  ];

  static const Set<String> percentDisplaySummaryKeys = <String>{
    'CritRate',
    'PhysicalPierce',
    'ElementPierce',
    'Stability',
  };

  static const Map<String, String> _summaryKeyByStatKey = <String, String>{
    'atk': 'ATK',
    'weapon_atk': 'ATK',
    'matk': 'MATK',
    'def': 'DEF',
    'mdef': 'MDEF',
    'str': 'STR',
    'dex': 'DEX',
    'int': 'INT',
    'agi': 'AGI',
    'vit': 'VIT',
    'aspd': 'ASPD',
    'critical_rate': 'CritRate',
    'physical_pierce': 'PhysicalPierce',
    'magic_pierce': 'ElementPierce',
    'accuracy': 'Accuracy',
    'stability': 'Stability',
    'hp': 'HP',
    'mp': 'MP',
  };

  static const Set<String> _pointBasedPercentSummaryKeys = <String>{
    'PhysicalPierce',
    'ElementPierce',
    'Stability',
  };

  static Map<String, num> calculateSummary({
    required Map<String, dynamic> character,
    required int level,
    required String personalStatType,
    required int personalStatValue,
    required int enhanceMain,
    required int enhanceArmor,
    required int enhanceHelmet,
    required int enhanceRing,
    required Iterable<EquipmentLibraryItem> equippedItems,
  }) {
    final Map<String, num> baseByKey = Map<String, num>.from(summaryTemplate);
    final Map<String, num> percentByKey = <String, num>{};
    final Map<String, num> flatByKey = <String, num>{};

    final int normalizedLevel = level.clamp(1, 300).toInt();
    final String normalizedPersonalType = personalStatType.trim().toUpperCase();
    final int normalizedPersonalValue = personalStatValue.clamp(0, 255).toInt();
    final num dexValue = _readNumericValue(character['DEX']);
    final num baseCritRate =
        25 + (normalizedPersonalType == 'CRT' ? normalizedPersonalValue : 0);

    baseByKey.addAll(<String, num>{
      'STR': _readNumericValue(character['STR']),
      'DEX': dexValue,
      'INT': _readNumericValue(character['INT']),
      'AGI': _readNumericValue(character['AGI']),
      'VIT': _readNumericValue(character['VIT']),
      'Accuracy': normalizedLevel + dexValue,
      'CritRate': baseCritRate,
      'ATK': enhanceMain * 10,
      'DEF': enhanceArmor * 5,
      'MDEF': enhanceHelmet * 5,
      'HP': enhanceArmor * 20,
      'MP': enhanceRing * 10,
    });

    for (final EquipmentLibraryItem item in equippedItems) {
      for (final EquipmentStat stat in item.stats) {
        final String? summaryKey =
            _summaryKeyByStatKey[stat.statKey.toLowerCase()];
        if (summaryKey == null) {
          continue;
        }

        final bool isPercent = stat.valueType.toLowerCase() == 'percent';
        if (isPercent && !_pointBasedPercentSummaryKeys.contains(summaryKey)) {
          percentByKey[summaryKey] =
              (percentByKey[summaryKey] ?? 0) + stat.value;
          continue;
        }

        final String normalizedStatKey = stat.statKey.toLowerCase();
        if (normalizedStatKey == 'weapon_atk') {
          baseByKey[summaryKey] = (baseByKey[summaryKey] ?? 0) + stat.value;
          continue;
        }
        flatByKey[summaryKey] = (flatByKey[summaryKey] ?? 0) + stat.value;
      }
    }

    final Map<String, num> nextSummary = Map<String, num>.from(summaryTemplate);
    for (final String key in summaryTemplate.keys) {
      final num baseValue = baseByKey[key] ?? 0;
      final num flatValue = flatByKey[key] ?? 0;
      if (_pointBasedPercentSummaryKeys.contains(key)) {
        nextSummary[key] = baseValue + flatValue;
        continue;
      }
      final num percentValue = percentByKey[key] ?? 0;
      nextSummary[key] = (baseValue * (1 + (percentValue / 100))) + flatValue;
    }

    return nextSummary;
  }

  static num _readNumericValue(dynamic value) {
    if (value is num) {
      return value;
    }
    if (value is String) {
      return num.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }
}
