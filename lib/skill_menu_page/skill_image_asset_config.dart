part of 'skill_menu_page.dart';

class SkillImageAssetConfig {
  const SkillImageAssetConfig._();

  static const Map<String, String> treeFolderByTreeName = <String, String>{
    'blade': 'blade',
    'shot': 'Shot',
    'crusher': 'Crusher',
    'dualsword': 'DualSword',
    'halberd': 'Halberd',
    'magic': 'Magic',
    'mononofu': 'Mononofu',
    'sprite': 'Sprite',
  };

  static const Map<String, Map<String, String>> fileOverridesByTree =
      <String, Map<String, String>>{
        'blade': <String, String>{'trigger slash': 'tiggerslash.png'},
        'crusher': <String, String>{
          'forefist punch': 'forefist punch.png',
          'goliath punch': 'goliath punch.png',
          'god hand': 'god hand.png',
          'divine rigid body': 'divine rigid body.png',
          'floating kick': 'floating kick.png',
          'geyser kick': 'geyser kick.png',
        },
        'magic': <String, String>{
          'rapid charge': 'rapid charge.png',
          'enchanted barrier': 'enchantedbarriers.png',
        },
        'halberd': <String, String>{'almighty wield': 'godspeedwield (1).png'},
        'mononofu': <String, String>{
          'pommel strike': 'pomelstrike.png',
          'nukiuchi sennosen': 'nukiuchi sennosen.png',
        },
        'sprite': <String, String>{'sprite upgrade': 'sprite upgrade.png'},
      };

  static String resolveDefaultImageAssetPath({
    required String treeName,
    required String skillName,
  }) {
    final String normalizedTree = treeName.trim().toLowerCase();
    final String normalizedSkillName = skillName.trim().toLowerCase();
    if (normalizedTree.isEmpty || normalizedSkillName.isEmpty) {
      return '';
    }

    final String? folder = treeFolderByTreeName[normalizedTree];
    if (folder == null) {
      return '';
    }

    String effectiveSkillName = skillName.trim();
    if (normalizedTree == 'magic') {
      effectiveSkillName = effectiveSkillName.replaceFirst(
        RegExp(r'^magic:\s*', caseSensitive: false),
        '',
      );
    }

    final String normalizedFileName = _normalizeSkillImageFileName(
      effectiveSkillName,
    );
    if (normalizedFileName.isEmpty) {
      return '';
    }

    final String fileName =
        fileOverridesByTree[normalizedTree]?[normalizedSkillName] ??
        '$normalizedFileName.png';
    return 'assets/data/skill_menu/images/$folder/$fileName';
  }

  static String _normalizeSkillImageFileName(String skillName) {
    return skillName.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }
}
