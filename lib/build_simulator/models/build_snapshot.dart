class BuildEquipmentSnapshot {
  const BuildEquipmentSnapshot({
    this.mainWeaponId,
    this.enhMain = 0,
    this.mainCrystal1,
    this.mainCrystal2,
    this.subWeaponId,
    this.enhSub = 0,
    this.armorId,
    this.armorMode = 'normal',
    this.enhArmor = 0,
    this.armorCrystal1,
    this.armorCrystal2,
    this.helmetId,
    this.enhHelmet = 0,
    this.helmetCrystal1,
    this.helmetCrystal2,
    this.ringId,
    this.enhRing = 0,
    this.ringCrystal1,
    this.ringCrystal2,
  });

  final String? mainWeaponId;
  final int enhMain;
  final String? mainCrystal1;
  final String? mainCrystal2;
  final String? subWeaponId;
  final int enhSub;
  final String? armorId;
  final String armorMode;
  final int enhArmor;
  final String? armorCrystal1;
  final String? armorCrystal2;
  final String? helmetId;
  final int enhHelmet;
  final String? helmetCrystal1;
  final String? helmetCrystal2;
  final String? ringId;
  final int enhRing;
  final String? ringCrystal1;
  final String? ringCrystal2;
}

class BuildGachaSnapshot {
  const BuildGachaSnapshot({
    this.gacha1Stat1 = '',
    this.gacha1Stat2 = '',
    this.gacha1Stat3 = '',
    this.gacha2Stat1 = '',
    this.gacha2Stat2 = '',
    this.gacha2Stat3 = '',
    this.gacha3Stat1 = '',
    this.gacha3Stat2 = '',
    this.gacha3Stat3 = '',
  });

  final String gacha1Stat1;
  final String gacha1Stat2;
  final String gacha1Stat3;
  final String gacha2Stat1;
  final String gacha2Stat2;
  final String gacha2Stat3;
  final String gacha3Stat1;
  final String gacha3Stat2;
  final String gacha3Stat3;
}

class BuildSnapshot {
  const BuildSnapshot({
    required this.name,
    required this.character,
    required this.level,
    required this.totalStatPoints,
    required this.personalStatType,
    required this.personalStatValue,
    required this.equipment,
    required this.gacha,
    required this.isCharacterStatsExpanded,
    required this.isMainWeaponExpanded,
    required this.isSubWeaponExpanded,
    required this.isArmorExpanded,
    required this.isHelmetExpanded,
    required this.isRingExpanded,
    required this.isGachaExpanded,
    required this.summary,
  });

  final String name;
  final Map<String, dynamic> character;
  final int level;
  final int totalStatPoints;
  final String personalStatType;
  final int personalStatValue;
  final BuildEquipmentSnapshot equipment;
  final BuildGachaSnapshot gacha;
  final bool isCharacterStatsExpanded;
  final bool isMainWeaponExpanded;
  final bool isSubWeaponExpanded;
  final bool isArmorExpanded;
  final bool isHelmetExpanded;
  final bool isRingExpanded;
  final bool isGachaExpanded;
  final Map<String, num> summary;
}
