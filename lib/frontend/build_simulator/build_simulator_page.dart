import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'build_simulator_coordinator.dart';
import '../equipment_library/models/equipment_library_item.dart';
import '../equipment_library/repository/equipment_library_repository.dart';
import 'services/ai_build_recommendation_service.dart';
import 'services/build_ai_status_service.dart';
import 'services/build_calculator_service.dart';
import 'services/build_persistence_service.dart';
import 'services/build_recommendation_service.dart';
import 'services/build_weapon_rule_service.dart';
import 'services/crystal_library_service.dart';
import 'widgets/armor_selector.dart';
import 'widgets/character_stats_selector.dart';
import 'widgets/gacha_card.dart';
import 'widgets/helmet_selector.dart';
import 'widgets/main_weapon_selector.dart';
import 'widgets/ring_selector.dart';
import 'widgets/sub_weapon_selector.dart';
import 'widgets/toram_card.dart';

part 'build_simulator_layout.dart';
part 'build_simulator_equipment_panel.dart';
part 'build_simulator_sections.dart';

enum _SummaryViewMode { metricList, tableGraph }

class BuildSimulatorScreen extends StatefulWidget {
  const BuildSimulatorScreen({super.key, this.coordinator});

  final BuildSimulatorCoordinator? coordinator;

  @override
  State<BuildSimulatorScreen> createState() => BuildSimulatorScreenState();
}

class BuildSimulatorScreenState extends State<BuildSimulatorScreen> {
  final TextEditingController _buildNameController = TextEditingController();
  final EquipmentLibraryRepository _equipmentRepository =
      EquipmentLibraryRepository();
  final AiBuildRecommendationService _aiRecommendationService =
      const AiBuildRecommendationService();

  static const List<String> _characterStatKeys =
      BuildPersistenceService.characterStatKeys;
  static const List<String> _personalStatOptions =
      BuildPersistenceService.personalStatOptions;
  static const Map<String, int> _defaultCharacterStats = <String, int>{
    'STR': 1,
    'DEX': 1,
    'INT': 1,
    'AGI': 1,
    'VIT': 1,
  };
  static const String _ruleRecommendationMessage =
      'Using local recommendation rules.';
  static const List<String> _allCrystalCategories = <String>[
    'weapon',
    'armor',
    'additional',
    'special',
    'normal',
  ];

  Map<String, EquipmentLibraryItem> _equipmentByKey =
      <String, EquipmentLibraryItem>{};
  Map<String, CrystalLibraryEntry> _crystalsByKey =
      <String, CrystalLibraryEntry>{};
  Map<String, String> _weaponTypeAlias = <String, String>{};
  Map<String, String> _subWeaponTypeAlias = <String, String>{};
  Map<String, List<String>> _mainToAllowedSubTypes =
      <String, List<String>>{};

  bool _isCharacterStatsExpanded = false;
  bool _isMainWeaponExpanded = false;
  bool _isSubWeaponExpanded = false;
  bool _isArmorExpanded = false;
  bool _isHelmetExpanded = false;
  bool _isRingExpanded = false;
  bool _isGachaExpanded = false;
  _SummaryViewMode _summaryViewMode = _SummaryViewMode.metricList;

  final Map<String, dynamic> _character = Map<String, dynamic>.from(
    _defaultCharacterStats,
  );
  int _level = 1;
  String _personalStatType = _personalStatOptions.first;
  int _personalStatValue = 0;

  String? _mainWeaponId;
  int _enhMain = 0;
  String? _mainCrystal1;
  String? _mainCrystal2;

  String? _subWeaponId;
  int _enhSub = 0;

  String? _armorId;
  int _enhArmor = 0;
  String? _armorCrystal1;
  String? _armorCrystal2;

  String? _helmetId;
  int _enhHelmet = 0;
  String? _helmetCrystal1;
  String? _helmetCrystal2;

  String? _ringId;
  int _enhRing = 0;
  String? _ringCrystal1;
  String? _ringCrystal2;

  String _gacha1Stat1 = '';
  String _gacha1Stat2 = '';
  String _gacha1Stat3 = '';
  String _gacha2Stat1 = '';
  String _gacha2Stat2 = '';
  String _gacha2Stat3 = '';
  String _gacha3Stat1 = '';
  String _gacha3Stat2 = '';
  String _gacha3Stat3 = '';

  Map<String, num> _summary = Map<String, num>.from(
    BuildCalculatorService.summaryTemplate,
  );

  List<String> _recommendations = const <String>[];
  Timer? _aiRecommendationDebounce;
  int _aiRecommendationRequestToken = 0;
  bool _isAiRecommendationLoading = false;
  String _aiRecommendationSource = 'rule';
  String _aiRecommendationMessage = _ruleRecommendationMessage;
  bool _showRecommendationsPanel = true;

  final List<Map<String, dynamic>> _savedBuilds = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _recalculateAll();
    _attachCoordinator();
    _loadEquipmentLibrary();
    _loadCrystalLibrary();
    _loadWeaponRuleConfig();
  }

  @override
  void didUpdateWidget(covariant BuildSimulatorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.coordinator != widget.coordinator) {
      oldWidget.coordinator?.detachHandlers();
      _attachCoordinator();
    }
  }

  @override
  void dispose() {
    _aiRecommendationDebounce?.cancel();
    widget.coordinator?.detachHandlers();
    _buildNameController.dispose();
    super.dispose();
  }

  void _attachCoordinator() {
    widget.coordinator?.attachHandlers(
      onLoadBuildById: _onLoadBuildById,
      onSaveBuildByName: _onSaveBuildByName,
      onDeleteBuildById: _onDeleteBuildById,
      onRenameBuildById: _onRenameBuildById,
      onToggleFavoriteBuildById: _onToggleFavoriteBuildById,
      onReplaceSavedBuilds: _onReplaceSavedBuilds,
      onMergeSavedBuilds: _onMergeSavedBuilds,
      onSetShowRecommendations: _setShowRecommendationsPanel,
      onClearAllData: _onClearAll,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _syncCoordinatorSnapshot();
    });
  }

  void _syncCoordinatorSnapshot() {
    widget.coordinator?.updateSnapshot(
      savedBuilds: _savedBuilds,
      showRecommendations: _showRecommendationsPanel,
      equipmentCacheCount: _equipmentByKey.length,
      summary: _summary,
      aiRecommendations: _recommendations,
      isAiRecommendationLoading: _isAiRecommendationLoading,
      aiRecommendationSource: _aiRecommendationSource,
      aiRecommendationMessage: _aiRecommendationMessage,
    );
  }

  Future<void> _loadEquipmentLibrary() async {
    try {
      final Map<String, List<EquipmentLibraryItem>> allCategories =
          await _equipmentRepository.loadAllCategories();
      final Map<String, EquipmentLibraryItem> byKey =
          <String, EquipmentLibraryItem>{};
      for (final List<EquipmentLibraryItem> items in allCategories.values) {
        for (final EquipmentLibraryItem item in items) {
          final String normalizedKey = item.key.trim().toLowerCase();
          if (normalizedKey.isEmpty) {
            continue;
          }
          byKey[normalizedKey] = item;
        }
      }
      if (!mounted) {
        return;
      }
      _applyEquipmentCache(byKey);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _applyEquipmentCache(const <String, EquipmentLibraryItem>{});
    }
  }

  Future<void> _loadCrystalLibrary() async {
    try {
      final List<CrystalLibraryEntry> entries =
          await CrystalLibraryService.loadByCategories(_allCrystalCategories);
      final Map<String, CrystalLibraryEntry> byKey =
          <String, CrystalLibraryEntry>{};
      for (final CrystalLibraryEntry entry in entries) {
        final String normalizedKey = entry.normalizedKey;
        if (normalizedKey.isEmpty) {
          continue;
        }
        byKey[normalizedKey] = entry;
      }
      if (!mounted) {
        return;
      }
      _applyCrystalCache(byKey);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _applyCrystalCache(const <String, CrystalLibraryEntry>{});
    }
  }

  Future<void> _loadWeaponRuleConfig() async {
    try {
      final BuildWeaponRuleConfig config = await BuildWeaponRuleService.load();
      if (!mounted) {
        return;
      }
      _setStateAndRecalculate(() {
        _weaponTypeAlias = Map<String, String>.from(config.weaponTypeAlias);
        _subWeaponTypeAlias = Map<String, String>.from(config.subWeaponTypeAlias);
        _mainToAllowedSubTypes = config.mainToAllowedSubTypes.map(
          (String key, List<String> values) {
            return MapEntry<String, List<String>>(
              key,
              values.toList(growable: false),
            );
          },
        );
      });
    } catch (_) {}
  }

  void _applyEquipmentCache(Map<String, EquipmentLibraryItem> byKey) {
    _setUiState(() {
      _equipmentByKey = byKey;
      _recalculateAll();
    });
  }

  void _applyCrystalCache(Map<String, CrystalLibraryEntry> byKey) {
    _setUiState(() {
      _crystalsByKey = byKey;
      _recalculateAll();
    });
  }

  void _setUiState(VoidCallback action) {
    setState(action);
    _syncCoordinatorSnapshot();
  }

  void _setStateAndRecalculate(VoidCallback action) {
    _setUiState(() {
      action();
      _enforceSubWeaponRule();
      _recalculateAll();
    });
  }

  String _normalizeMainWeaponType(String? rawType) {
    final String type = rawType?.trim() ?? '';
    if (type.isEmpty) {
      return '';
    }
    final String aliasFromMain = _weaponTypeAlias[type]?.trim() ?? '';
    if (aliasFromMain.isNotEmpty) {
      return aliasFromMain;
    }
    final String aliasFromSub = _subWeaponTypeAlias[type]?.trim() ?? '';
    if (aliasFromSub.isNotEmpty) {
      return aliasFromSub;
    }
    return type;
  }

  String _normalizeSubWeaponType(String? rawType) {
    final String type = rawType?.trim() ?? '';
    if (type.isEmpty) {
      return '';
    }
    final String aliasFromSub = _subWeaponTypeAlias[type]?.trim() ?? '';
    if (aliasFromSub.isNotEmpty) {
      return aliasFromSub;
    }
    final String aliasFromMain = _weaponTypeAlias[type]?.trim() ?? '';
    if (aliasFromMain.isNotEmpty) {
      return aliasFromMain;
    }
    return type;
  }

  List<String>? _allowedSubWeaponTypeNames() {
    if (_mainToAllowedSubTypes.isEmpty) {
      return null;
    }
    final EquipmentLibraryItem? mainItem = _findEquipmentByKey(_mainWeaponId);
    if (mainItem == null) {
      return null;
    }
    final String normalizedMainType = _normalizeMainWeaponType(mainItem.type);
    if (normalizedMainType.isEmpty) {
      return null;
    }
    final List<String>? allowedSubTypeKeys = _mainToAllowedSubTypes[normalizedMainType];
    if (allowedSubTypeKeys == null) {
      return null;
    }

    final Set<String> displayTypes = <String>{};
    for (final String normalizedType in allowedSubTypeKeys) {
      final String typeKey = normalizedType.trim();
      if (typeKey.isEmpty) {
        continue;
      }
      displayTypes.add(typeKey);
      _subWeaponTypeAlias.forEach((String display, String alias) {
        if (alias == typeKey) {
          displayTypes.add(display);
        }
      });
      _weaponTypeAlias.forEach((String display, String alias) {
        if (alias == typeKey) {
          displayTypes.add(display);
        }
      });
    }

    return displayTypes.isEmpty
        ? const <String>[]
        : displayTypes.toList(growable: false);
  }

  bool _isSubWeaponSelectionAllowed(String? subWeaponKey) {
    final String key = subWeaponKey?.trim() ?? '';
    if (key.isEmpty || _mainToAllowedSubTypes.isEmpty) {
      return true;
    }

    final EquipmentLibraryItem? mainItem = _findEquipmentByKey(_mainWeaponId);
    final EquipmentLibraryItem? subItem = _findEquipmentByKey(key);
    if (mainItem == null || subItem == null) {
      return true;
    }

    final String normalizedMainType = _normalizeMainWeaponType(mainItem.type);
    if (normalizedMainType.isEmpty) {
      return true;
    }
    final List<String>? allowedSubTypes = _mainToAllowedSubTypes[normalizedMainType];
    if (allowedSubTypes == null) {
      return true;
    }

    final String normalizedSubType = _normalizeSubWeaponType(subItem.type);
    if (normalizedSubType.isEmpty) {
      return true;
    }
    return allowedSubTypes.contains(normalizedSubType);
  }

  void _enforceSubWeaponRule() {
    if (_isSubWeaponSelectionAllowed(_subWeaponId)) {
      return;
    }
    _subWeaponId = null;
    _enhSub = 0;
  }

  bool _isRemoteAiSource(String source) {
    return BuildAiStatusService.isRemoteAiSource(source);
  }

  EquipmentLibraryItem? _findEquipmentByKey(String? equipmentKey) {
    final String normalizedKey = (equipmentKey ?? '').trim().toLowerCase();
    if (normalizedKey.isEmpty) {
      return null;
    }
    return _equipmentByKey[normalizedKey];
  }

  String _equipmentName(String? equipmentKey) {
    return _findEquipmentByKey(equipmentKey)?.name ?? '';
  }

  CrystalLibraryEntry? _findCrystalByKey(String? crystalKey) {
    final String normalizedKey = (crystalKey ?? '').trim().toLowerCase();
    if (normalizedKey.isEmpty) {
      return null;
    }
    return _crystalsByKey[normalizedKey];
  }

  String _formatStatPreview(EquipmentStat stat) {
    final bool isPercent = stat.valueType.toLowerCase() == 'percent';
    final num value = stat.value;
    final String valueText = value == value.toInt()
        ? value.toInt().toString()
        : value.toString();
    final String sign = value >= 0 ? '+' : '';
    return '${stat.statKey.toUpperCase()} $sign$valueText${isPercent ? '%' : ''}';
  }

  List<String> _equipmentStatPreview(String? equipmentKey, {int limit = 4}) {
    final EquipmentLibraryItem? item = _findEquipmentByKey(equipmentKey);
    if (item == null) {
      return const <String>[];
    }
    return item.stats
        .take(limit)
        .map(_formatStatPreview)
        .toList(growable: false);
  }

  Iterable<EquipmentLibraryItem> _equippedItems() sync* {
    final EquipmentLibraryItem? main = _findEquipmentByKey(_mainWeaponId);
    if (main != null) {
      yield main;
    }
    final EquipmentLibraryItem? sub = _findEquipmentByKey(_subWeaponId);
    if (sub != null) {
      yield sub;
    }
    final EquipmentLibraryItem? armor = _findEquipmentByKey(_armorId);
    if (armor != null) {
      yield armor;
    }
    final EquipmentLibraryItem? helmet = _findEquipmentByKey(_helmetId);
    if (helmet != null) {
      yield helmet;
    }
    final EquipmentLibraryItem? ring = _findEquipmentByKey(_ringId);
    if (ring != null) {
      yield ring;
    }
  }

  Iterable<String?> _equippedCrystalKeys() sync* {
    yield _mainCrystal1;
    yield _mainCrystal2;
    yield _armorCrystal1;
    yield _armorCrystal2;
    yield _helmetCrystal1;
    yield _helmetCrystal2;
    yield _ringCrystal1;
    yield _ringCrystal2;
  }

  Iterable<EquipmentStat> _equippedCrystalStats() sync* {
    for (final String? crystalKey in _equippedCrystalKeys()) {
      final CrystalLibraryEntry? entry = _findCrystalByKey(crystalKey);
      if (entry == null) {
        continue;
      }
      for (final EquipmentStat stat in entry.stats) {
        yield stat;
      }
    }
  }

  void _recalculateAll() {
    _summary = BuildCalculatorService.calculateSummary(
      character: _character,
      level: _level,
      personalStatType: _personalStatType,
      personalStatValue: _personalStatValue,
      enhanceMain: _enhMain,
      enhanceSub: _enhSub,
      enhanceArmor: _enhArmor,
      enhanceHelmet: _enhHelmet,
      enhanceRing: _enhRing,
      subWeaponType: _findEquipmentByKey(_subWeaponId)?.type,
      equippedItems: _equippedItems(),
      equippedCrystalStats: _equippedCrystalStats(),
    );
    final List<EquipmentLibraryItem> equippedItems = _equippedItems().toList(
      growable: false,
    );
    _recommendations = BuildRecommendationService.generate(
      summary: _summary,
      character: _character,
      level: _level,
      personalStatType: _personalStatType,
      personalStatValue: _personalStatValue,
      mainWeaponId: _mainWeaponId,
      subWeaponId: _subWeaponId,
      armorId: _armorId,
      helmetId: _helmetId,
      ringId: _ringId,
      enhanceMain: _enhMain,
      enhanceArmor: _enhArmor,
      enhanceHelmet: _enhHelmet,
      enhanceRing: _enhRing,
      equippedItems: equippedItems,
    );
    _aiRecommendationSource = 'rule';
    _aiRecommendationMessage = _ruleRecommendationMessage;
    _scheduleAiRecommendations(equippedItems);
  }

  void _scheduleAiRecommendations(List<EquipmentLibraryItem> equippedItems) {
    _aiRecommendationDebounce?.cancel();
    final Map<String, dynamic> payload = _buildAiRequestPayload(
      equippedItems: equippedItems,
      fallbackRecommendations: _recommendations,
    );
    _aiRecommendationDebounce = Timer(const Duration(milliseconds: 650), () {
      final int token = ++_aiRecommendationRequestToken;
      _refreshAiRecommendations(token: token, payload: payload);
    });
  }

  Map<String, dynamic> _buildAiRequestPayload({
    required List<EquipmentLibraryItem> equippedItems,
    required List<String> fallbackRecommendations,
  }) {
    return <String, dynamic>{
      'level': _level,
      'personalStatType': _personalStatType,
      'personalStatValue': _personalStatValue,
      'character': Map<String, dynamic>.from(_character),
      'summary': Map<String, num>.from(_summary),
      'equipmentSlots': <String, dynamic>{
        'mainWeaponId': _mainWeaponId,
        'subWeaponId': _subWeaponId,
        'armorId': _armorId,
        'helmetId': _helmetId,
        'ringId': _ringId,
        'enhanceMain': _enhMain,
        'enhanceArmor': _enhArmor,
        'enhanceHelmet': _enhHelmet,
        'enhanceRing': _enhRing,
      },
      'equippedItems': equippedItems
          .map(
            (EquipmentLibraryItem item) => <String, dynamic>{
              'name': item.name,
              'type': item.type,
              'stats': item.stats
                  .map(
                    (EquipmentStat stat) => <String, dynamic>{
                      'statKey': stat.statKey,
                      'value': stat.value,
                      'valueType': stat.valueType,
                    },
                  )
                  .toList(growable: false),
            },
          )
          .toList(growable: false),
      'fallbackRecommendations': List<String>.from(fallbackRecommendations),
    };
  }

  Future<void> _refreshAiRecommendations({
    required int token,
    required Map<String, dynamic> payload,
  }) async {
    if (!mounted) {
      return;
    }

    _setUiState(() {
      _isAiRecommendationLoading = true;
      _aiRecommendationMessage = 'AI analyzing your build...';
    });

    try {
      final AiBuildRecommendationResult result = await _aiRecommendationService
          .fetchRecommendations(payload: payload);
      if (!mounted || token != _aiRecommendationRequestToken) {
        return;
      }
      _setUiState(() {
        _recommendations = result.recommendations;
        _isAiRecommendationLoading = false;
        _aiRecommendationSource = result.source;
        _aiRecommendationMessage = _buildAiStatusMessage(
          source: result.source,
          details: result.message,
        );
      });
    } catch (error) {
      if (!mounted || token != _aiRecommendationRequestToken) {
        return;
      }
      _setUiState(() {
        _isAiRecommendationLoading = false;
        _aiRecommendationSource = 'fallback';
        _aiRecommendationMessage = _buildAiStatusMessage(
          source: 'fallback',
          details: error.toString(),
        );
      });
    }
  }

  String _buildAiStatusMessage({required String source, String? details}) {
    return BuildAiStatusService.buildStatusMessage(
      source: source,
      ruleRecommendationMessage: _ruleRecommendationMessage,
      details: details,
    );
  }

  int _findBuildIndexById(String buildId) {
    return BuildPersistenceService.findBuildIndexById(_savedBuilds, buildId);
  }

  void _applyBuildSnapshot(Map<String, dynamic> build) {
    _applyCharacterSnapshot(build);
    _applyEquipmentSnapshot(build);
    _applyGachaSnapshot(build);
    _applyExpandedStateSnapshot(build);
  }

  void _applyCharacterSnapshot(Map<String, dynamic> build) {
    final dynamic rawCharacter = build['character'];
    final Map<dynamic, dynamic> characterMap = rawCharacter is Map
        ? rawCharacter
        : const <dynamic, dynamic>{};
    for (final String key in _characterStatKeys) {
      _character[key] = BuildPersistenceService.readIntValue(characterMap[key]);
    }
    _level = BuildPersistenceService.readIntValue(
      build['level'],
      fallback: _level,
    ).clamp(1, 300).toInt();
    _personalStatType = BuildPersistenceService.normalizePersonalStatType(
      build['personalStatType'],
    );
    _personalStatValue = BuildPersistenceService.readIntValue(
      build['personalStatValue'],
      fallback: _personalStatValue,
    ).clamp(0, 255).toInt();
  }

  void _applyEquipmentSnapshot(Map<String, dynamic> build) {
    _mainWeaponId = BuildPersistenceService.readOptionalStringValue(
      build['mainWeaponId'],
    );
    _enhMain = BuildPersistenceService.readIntValue(
      build['enhMain'],
    ).clamp(0, 15).toInt();
    _mainCrystal1 = BuildPersistenceService.readOptionalStringValue(
      build['mainCrystal1'],
    );
    _mainCrystal2 = BuildPersistenceService.readOptionalStringValue(
      build['mainCrystal2'],
    );

    _subWeaponId = BuildPersistenceService.readOptionalStringValue(
      build['subWeaponId'],
    );
    _enhSub = BuildPersistenceService.readIntValue(
      build['enhSub'],
    ).clamp(0, 15).toInt();

    _armorId = BuildPersistenceService.readOptionalStringValue(
      build['armorId'],
    );
    _enhArmor = BuildPersistenceService.readIntValue(
      build['enhArmor'],
    ).clamp(0, 15).toInt();
    _armorCrystal1 = BuildPersistenceService.readOptionalStringValue(
      build['armorCrystal1'],
    );
    _armorCrystal2 = BuildPersistenceService.readOptionalStringValue(
      build['armorCrystal2'],
    );

    _helmetId = BuildPersistenceService.readOptionalStringValue(
      build['helmetId'],
    );
    _enhHelmet = BuildPersistenceService.readIntValue(
      build['enhHelmet'],
    ).clamp(0, 15).toInt();
    _helmetCrystal1 = BuildPersistenceService.readOptionalStringValue(
      build['helmetCrystal1'],
    );
    _helmetCrystal2 = BuildPersistenceService.readOptionalStringValue(
      build['helmetCrystal2'],
    );

    _ringId = BuildPersistenceService.readOptionalStringValue(build['ringId']);
    _enhRing = BuildPersistenceService.readIntValue(
      build['enhRing'],
    ).clamp(0, 15).toInt();
    _ringCrystal1 = BuildPersistenceService.readOptionalStringValue(
      build['ringCrystal1'],
    );
    _ringCrystal2 = BuildPersistenceService.readOptionalStringValue(
      build['ringCrystal2'],
    );
  }

  void _applyGachaSnapshot(Map<String, dynamic> build) {
    _gacha1Stat1 = BuildPersistenceService.readStringValue(
      build['gacha1Stat1'],
    );
    _gacha1Stat2 = BuildPersistenceService.readStringValue(
      build['gacha1Stat2'],
    );
    _gacha1Stat3 = BuildPersistenceService.readStringValue(
      build['gacha1Stat3'],
    );
    _gacha2Stat1 = BuildPersistenceService.readStringValue(
      build['gacha2Stat1'],
    );
    _gacha2Stat2 = BuildPersistenceService.readStringValue(
      build['gacha2Stat2'],
    );
    _gacha2Stat3 = BuildPersistenceService.readStringValue(
      build['gacha2Stat3'],
    );
    _gacha3Stat1 = BuildPersistenceService.readStringValue(
      build['gacha3Stat1'],
    );
    _gacha3Stat2 = BuildPersistenceService.readStringValue(
      build['gacha3Stat2'],
    );
    _gacha3Stat3 = BuildPersistenceService.readStringValue(
      build['gacha3Stat3'],
    );
  }

  void _applyExpandedStateSnapshot(Map<String, dynamic> build) {
    _isCharacterStatsExpanded = BuildPersistenceService.readBoolValue(
      build['isCharacterStatsExpanded'],
      fallback: _isCharacterStatsExpanded,
    );
    _isMainWeaponExpanded = BuildPersistenceService.readBoolValue(
      build['isMainWeaponExpanded'],
      fallback: _isMainWeaponExpanded,
    );
    _isSubWeaponExpanded = BuildPersistenceService.readBoolValue(
      build['isSubWeaponExpanded'],
      fallback: _isSubWeaponExpanded,
    );
    _isArmorExpanded = BuildPersistenceService.readBoolValue(
      build['isArmorExpanded'],
      fallback: _isArmorExpanded,
    );
    _isHelmetExpanded = BuildPersistenceService.readBoolValue(
      build['isHelmetExpanded'],
      fallback: _isHelmetExpanded,
    );
    _isRingExpanded = BuildPersistenceService.readBoolValue(
      build['isRingExpanded'],
      fallback: _isRingExpanded,
    );
    _isGachaExpanded = BuildPersistenceService.readBoolValue(
      build['isGachaExpanded'],
      fallback: _isGachaExpanded,
    );
  }

  Map<String, dynamic> _buildCurrentSnapshot(String normalizedName) {
    return BuildPersistenceService.createBuildSnapshot(
      name: normalizedName,
      character: _character,
      level: _level,
      personalStatType: _personalStatType,
      personalStatValue: _personalStatValue,
      mainWeaponId: _mainWeaponId,
      enhMain: _enhMain,
      mainCrystal1: _mainCrystal1,
      mainCrystal2: _mainCrystal2,
      subWeaponId: _subWeaponId,
      enhSub: _enhSub,
      armorId: _armorId,
      enhArmor: _enhArmor,
      armorCrystal1: _armorCrystal1,
      armorCrystal2: _armorCrystal2,
      helmetId: _helmetId,
      enhHelmet: _enhHelmet,
      helmetCrystal1: _helmetCrystal1,
      helmetCrystal2: _helmetCrystal2,
      ringId: _ringId,
      enhRing: _enhRing,
      ringCrystal1: _ringCrystal1,
      ringCrystal2: _ringCrystal2,
      gacha1Stat1: _gacha1Stat1,
      gacha1Stat2: _gacha1Stat2,
      gacha1Stat3: _gacha1Stat3,
      gacha2Stat1: _gacha2Stat1,
      gacha2Stat2: _gacha2Stat2,
      gacha2Stat3: _gacha2Stat3,
      gacha3Stat1: _gacha3Stat1,
      gacha3Stat2: _gacha3Stat2,
      gacha3Stat3: _gacha3Stat3,
      isCharacterStatsExpanded: _isCharacterStatsExpanded,
      isMainWeaponExpanded: _isMainWeaponExpanded,
      isSubWeaponExpanded: _isSubWeaponExpanded,
      isArmorExpanded: _isArmorExpanded,
      isHelmetExpanded: _isHelmetExpanded,
      isRingExpanded: _isRingExpanded,
      isGachaExpanded: _isGachaExpanded,
      summary: _summary,
    );
  }

  void _onSaveBuildByName(String name) {
    final String normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      return;
    }

    _setUiState(() {
      _savedBuilds.add(_buildCurrentSnapshot(normalizedName));
    });
  }

  void _onSaveBuild() {
    _onSaveBuildByName(_buildNameController.text);
    _buildNameController.clear();
  }

  void _onLoadBuildById(String buildId) {
    final int index = _findBuildIndexById(buildId);
    if (index < 0) {
      return;
    }
    _onLoadBuild(index);
  }

  void _onLoadBuild(int index) {
    if (index < 0 || index >= _savedBuilds.length) {
      return;
    }

    final Map<String, dynamic> build = _savedBuilds[index];
    _setStateAndRecalculate(() {
      _applyBuildSnapshot(build);
    });
  }

  void _onRenameBuildById(String buildId, String nextName) {
    final String normalizedName = nextName.trim();
    if (normalizedName.isEmpty) {
      return;
    }
    final int index = _findBuildIndexById(buildId);
    if (index < 0) {
      return;
    }
    _setUiState(() {
      _savedBuilds[index]['name'] = normalizedName;
      _savedBuilds[index]['savedAt'] = DateTime.now().toIso8601String();
    });
  }

  void _onToggleFavoriteBuildById(String buildId) {
    final int index = _findBuildIndexById(buildId);
    if (index < 0) {
      return;
    }
    _setUiState(() {
      final bool currentFavorite = BuildPersistenceService.readBoolValue(
        _savedBuilds[index]['isFavorite'],
      );
      _savedBuilds[index]['isFavorite'] = !currentFavorite;
      _savedBuilds[index]['savedAt'] = DateTime.now().toIso8601String();
    });
  }

  void _onDeleteBuildById(String buildId) {
    final int index = _findBuildIndexById(buildId);
    if (index < 0) {
      return;
    }
    _onDeleteBuild(index);
  }

  void _onDeleteBuild(int index) {
    if (index < 0 || index >= _savedBuilds.length) {
      return;
    }
    _setUiState(() {
      _savedBuilds.removeAt(index);
    });
  }

  void _onReplaceSavedBuilds(List<Map<String, dynamic>> rawBuilds) {
    final List<Map<String, dynamic>> normalized =
        BuildPersistenceService.normalizeBuildList(
          rawBuilds,
          summaryTemplate: BuildCalculatorService.summaryTemplate,
        );
    _setUiState(() {
      _savedBuilds
        ..clear()
        ..addAll(normalized);
    });
  }

  void _onMergeSavedBuilds(List<Map<String, dynamic>> rawBuilds) {
    final Set<String> reservedIds = <String>{};
    for (int i = 0; i < _savedBuilds.length; i++) {
      reservedIds.add(BuildPersistenceService.buildIdFor(_savedBuilds[i], i));
    }

    final List<Map<String, dynamic>> normalized =
        BuildPersistenceService.normalizeBuildList(
          rawBuilds,
          reservedIds: reservedIds,
          summaryTemplate: BuildCalculatorService.summaryTemplate,
        );
    if (normalized.isEmpty) {
      return;
    }
    _setUiState(() {
      _savedBuilds.addAll(normalized);
    });
  }

  void _resetCharacterDefaults() {
    _character.addAll(_defaultCharacterStats);
    _level = 1;
    _personalStatType = _personalStatOptions.first;
    _personalStatValue = 0;
  }

  void _resetEquipmentSelections() {
    _mainWeaponId = null;
    _enhMain = 0;
    _mainCrystal1 = null;
    _mainCrystal2 = null;

    _subWeaponId = null;
    _enhSub = 0;

    _armorId = null;
    _enhArmor = 0;
    _armorCrystal1 = null;
    _armorCrystal2 = null;

    _helmetId = null;
    _enhHelmet = 0;
    _helmetCrystal1 = null;
    _helmetCrystal2 = null;

    _ringId = null;
    _enhRing = 0;
    _ringCrystal1 = null;
    _ringCrystal2 = null;
  }

  void _resetGachaStats() {
    _gacha1Stat1 = '';
    _gacha1Stat2 = '';
    _gacha1Stat3 = '';
    _gacha2Stat1 = '';
    _gacha2Stat2 = '';
    _gacha2Stat3 = '';
    _gacha3Stat1 = '';
    _gacha3Stat2 = '';
    _gacha3Stat3 = '';
  }

  void _resetExpandedStates() {
    _isCharacterStatsExpanded = false;
    _isMainWeaponExpanded = false;
    _isSubWeaponExpanded = false;
    _isArmorExpanded = false;
    _isHelmetExpanded = false;
    _isRingExpanded = false;
    _isGachaExpanded = false;
  }

  void _onClearAll() {
    _setStateAndRecalculate(() {
      _resetCharacterDefaults();
      _resetEquipmentSelections();
      _resetGachaStats();
      _resetExpandedStates();

      _showRecommendationsPanel = true;
      _summaryViewMode = _SummaryViewMode.metricList;
      _savedBuilds.clear();
      _buildNameController.clear();
    });
  }

  void _setShowRecommendationsPanel(bool value) {
    _setUiState(() {
      _showRecommendationsPanel = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildScreenUI(context);
  }
}
