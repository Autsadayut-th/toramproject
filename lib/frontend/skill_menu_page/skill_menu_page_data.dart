part of 'skill_menu_page.dart';

class SkillMenuRepository {
  const SkillMenuRepository();

  static const Map<String, String> splitAssetPaths = <String, String>{
    'Weapon': 'assets/data/skill_menu/skills_weapon.json',
    'Buff': 'assets/data/skill_menu/skills_buff.json',
    'Assist': 'assets/data/skill_menu/skills_assist.json',
    'Other': 'assets/data/skill_menu/skills_other.json',
  };

  Future<SkillLibraryData> load() async {
    final Map<String, dynamic> mergedTrees = <String, dynamic>{};
    final Map<String, String> treeCategoryByTree = <String, String>{};

    for (final MapEntry<String, String> group in splitAssetPaths.entries) {
      final String categoryName = group.key;
      final String path = group.value;
      final String rawJson = await rootBundle.loadString(path);
      final dynamic decoded = jsonDecode(rawJson);
      if (decoded is! Map<String, dynamic>) {
        throw FormatException('Skill JSON root must be an object: $path');
      }

      for (final MapEntry<String, dynamic> entry in decoded.entries) {
        final String treeName = entry.key.trim();
        if (treeName.isEmpty) {
          continue;
        }
        if (mergedTrees.containsKey(treeName)) {
          throw FormatException(
            'Duplicate skill tree "$treeName" in split files.',
          );
        }
        mergedTrees[treeName] = entry.value;
        treeCategoryByTree[treeName] = categoryName;
      }
    }

    if (mergedTrees.isEmpty) {
      throw const FormatException('No skill trees were found in split files.');
    }

    return SkillLibraryData.fromJson(
      mergedTrees,
      treeCategoryByTree: treeCategoryByTree,
    );
  }
}

class SkillLibraryData {
  SkillLibraryData({
    required Map<String, List<SkillEntry>> skillsByTree,
    required Map<String, String> treeCategoryByTree,
  }) : skillsByTree = Map<String, List<SkillEntry>>.unmodifiable(
         skillsByTree.map(
           (String key, List<SkillEntry> value) =>
               MapEntry<String, List<SkillEntry>>(
                 key,
                 List<SkillEntry>.unmodifiable(value),
               ),
         ),
       ),
       treeCategoryByTree = Map<String, String>.unmodifiable(
         treeCategoryByTree,
       );

  final Map<String, List<SkillEntry>> skillsByTree;
  final Map<String, String> treeCategoryByTree;

  List<String> get treeNames => skillsByTree.keys.toList(growable: false);

  int get totalSkills => skillsByTree.values.fold<int>(
    0,
    (int sum, List<SkillEntry> skills) => sum + skills.length,
  );

  String categoryForTree(String treeName) {
    return treeCategoryByTree[treeName] ?? 'Other';
  }

  int totalSkillsInCategory(String categoryName) {
    int total = 0;
    for (final MapEntry<String, List<SkillEntry>> entry
        in skillsByTree.entries) {
      if (categoryForTree(entry.key) == categoryName) {
        total += entry.value.length;
      }
    }
    return total;
  }

  factory SkillLibraryData.fromJson(
    Map<String, dynamic> json, {
    required Map<String, String> treeCategoryByTree,
  }) {
    final Map<String, List<SkillEntry>> parsed = <String, List<SkillEntry>>{};
    final Map<String, String> categories = <String, String>{};

    for (final MapEntry<String, dynamic> entry in json.entries) {
      final String treeName = entry.key.trim();
      if (treeName.isEmpty) {
        continue;
      }

      final List<dynamic> rawSkills =
          entry.value as List<dynamic>? ?? const <dynamic>[];
      final List<SkillEntry> skills = rawSkills
          .whereType<Map<String, dynamic>>()
          .map((Map<String, dynamic> raw) {
            return SkillEntry.fromJson(raw, treeName: treeName);
          })
          .where((SkillEntry skill) => skill.name.trim().isNotEmpty)
          .toList(growable: false);
      if (skills.isEmpty) {
        continue;
      }

      parsed[treeName] = skills;
      categories[treeName] = treeCategoryByTree[treeName] ?? 'Other';
    }

    if (parsed.isEmpty) {
      throw const FormatException('No skill trees were found in JSON.');
    }

    return SkillLibraryData(
      skillsByTree: parsed,
      treeCategoryByTree: categories,
    );
  }
}

class SkillEntry {
  const SkillEntry({
    required this.name,
    required this.unlockLevel,
    required this.mp,
    required this.type,
    required this.element,
    required this.combo,
    required this.comboMiddle,
    required this.range,
    required this.description,
    required this.imageAssetPath,
  });

  final String name;
  final int? unlockLevel;
  final String mp;
  final String type;
  final String element;
  final String combo;
  final String comboMiddle;
  final String range;
  final String description;
  final String imageAssetPath;

  factory SkillEntry.fromJson(
    Map<String, dynamic> json, {
    required String treeName,
  }) {
    final String imageValue = _stringValue(json['image']);
    final String imagePathValue = _stringValue(json['image_path']);
    final String fallbackImageAssetPath = _defaultImageAssetPath(
      treeName: treeName,
      skillName: _stringValue(json['name']),
    );
    final String imageAssetPath = imageValue.isNotEmpty
        ? imageValue
        : imagePathValue.isNotEmpty
        ? imagePathValue
        : fallbackImageAssetPath;
    return SkillEntry(
      name: _stringValue(json['name']),
      unlockLevel: _intValue(json['unlock_level']),
      mp: _stringValue(json['mp']),
      type: _stringValue(json['type']),
      element: _stringValue(json['element']),
      combo: _stringValue(json['combo']),
      comboMiddle: _stringValue(json['combo_middle']),
      range: _stringValue(json['range']),
      description: _stringValue(json['description']),
      imageAssetPath: imageAssetPath,
    );
  }
}

String _defaultImageAssetPath({
  required String treeName,
  required String skillName,
}) {
  return SkillImageAssetConfig.resolveDefaultImageAssetPath(
    treeName: treeName,
    skillName: skillName,
  );
}

String _stringValue(dynamic value) {
  if (value == null) {
    return '';
  }
  return value.toString().trim();
}

int? _intValue(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value.trim());
  }
  return null;
}
