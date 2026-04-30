import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'build_simulator_coordinator.dart';
import '../custom_equipment/custom_equipment.dart';
import '../equipment_library/models/equipment_library_item.dart';
import '../equipment_library/repository/equipment_library_repository.dart';
import 'services/ai_build_recommendation_service.dart';
import 'services/ai/recommendation_item.dart';
import 'services/avatar_gacha_data_service.dart';
import 'services/build_ai_status_service.dart';
import 'services/build_calculator_service.dart';
import 'services/build_persistence_service.dart';
import 'services/build_recommendation_service.dart';
import 'services/build_rule_set_service.dart';
import 'services/build_weapon_rule_service.dart';
import 'services/crystal_library_service.dart';
import 'services/firebase_saved_builds_service.dart';
import 'services/recommendation_feedback_service.dart';
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
part 'build_simulator_data_loading.dart';
part 'build_simulator_recommendation_logic.dart';
part 'build_simulator_persistence_actions.dart';
part 'build_simulator_custom_equipment.dart';

enum _SummaryViewMode { metricList, itemDetails }

class BuildSimulatorScreen extends StatefulWidget {
  const BuildSimulatorScreen({
    super.key,
    this.coordinator,
    this.currentUserId,
    this.isAuthenticated = false,
    this.hasAdvancedAccess = false,
  });

  final BuildSimulatorCoordinator? coordinator;
  final String? currentUserId;
  final bool isAuthenticated;
  final bool hasAdvancedAccess;

  @override
  State<BuildSimulatorScreen> createState() => BuildSimulatorScreenState();
}

class BuildSimulatorScreenState extends State<BuildSimulatorScreen> {
  final TextEditingController _buildNameController = TextEditingController();
  final EquipmentLibraryRepository _equipmentRepository =
      EquipmentLibraryRepository();
  final AiBuildRecommendationService _aiRecommendationService =
      const AiBuildRecommendationService();
  final FirebaseSavedBuildsService _savedBuildsService =
      FirebaseSavedBuildsService();
  final RecommendationFeedbackService _recommendationFeedbackService =
      RecommendationFeedbackService();
  final CustomEquipmentStorageService _customEquipmentStorageService =
      const CustomEquipmentStorageService();
  final FirebaseCustomEquipmentService _firebaseCustomEquipmentService =
      FirebaseCustomEquipmentService();

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
  static const int _defaultTotalStatPoints = 776;
  static const String _ruleRecommendationMessage =
      'Using GitHub toram-data rules. Press Generate for AI.';
  static const String _guestAiLockedMessage =
      'Guest mode: Login required to generate AI recommendations.';
  static const int _guestSavedBuildLimit = 2;
  static const String _guestSaveLimitMessage = 'Limit 2 builds only.';
  static const List<String> _allCrystalCategories = <String>[
    'weapon',
    'armor',
    'additional',
    'special',
    'normal',
  ];

  Map<String, EquipmentLibraryItem> _equipmentByKey =
      <String, EquipmentLibraryItem>{};
  Map<String, String> _equipmentCategoryByKey = <String, String>{};
  Map<String, EquipmentLibraryItem> _libraryEquipmentByKey =
      <String, EquipmentLibraryItem>{};
  Map<String, String> _libraryEquipmentCategoryByKey = <String, String>{};
  Map<String, EquipmentLibraryItem> _customEquipmentByKey =
      <String, EquipmentLibraryItem>{};
  Map<String, String> _customEquipmentCategoryByKey = <String, String>{};
  Map<String, CustomEquipmentItem> _customEquipmentItemByKey =
      <String, CustomEquipmentItem>{};
  Map<String, CrystalLibraryEntry> _crystalsByKey =
      <String, CrystalLibraryEntry>{};
  Map<String, String> _weaponTypeAlias = <String, String>{};
  Map<String, String> _subWeaponTypeAlias = <String, String>{};
  Map<String, List<String>> _mainToAllowedSubTypes = <String, List<String>>{};
  BuildRuleSet? _ruleSet;

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
  int _totalStatPoints = _defaultTotalStatPoints;
  String _personalStatType = _personalStatOptions.first;
  int _personalStatValue = 0;

  String? _mainWeaponId;
  int _enhMain = 0;
  String? _mainCrystal1;
  String? _mainCrystal2;

  String? _subWeaponId;
  int _enhSub = 0;

  String? _armorId;
  String _armorMode = 'normal';
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
  List<AiRecommendationItem> _recommendationItems =
      const <AiRecommendationItem>[];
  final Map<String, String> _feedbackByRecommendationId = <String, String>{};
  int _aiRecommendationRequestToken = 0;
  bool _isAiRecommendationLoading = false;
  String _aiRecommendationSource = 'rule';
  String _aiRecommendationMessage = _ruleRecommendationMessage;
  bool _showRecommendationsPanel = true;

  final List<Map<String, dynamic>> _savedBuilds = <Map<String, dynamic>>[];
  bool _isLoadingCloudSavedBuilds = false;
  bool _isSavingCloudSavedBuilds = false;
  bool _hasPendingCloudSync = false;
  String? _loadedCloudUserId;
  bool _isSyncingCustomEquipment = false;
  String? _loadedCustomEquipmentUserId;
  RecommendationFeedbackSnapshot _feedbackSnapshot =
      const RecommendationFeedbackSnapshot.empty();
  bool _isLoadingFeedbackSnapshot = false;

  bool get _canUseAiGeneration => widget.hasAdvancedAccess;
  bool get _shouldShowRecommendationsPanel =>
      _canUseAiGeneration && _showRecommendationsPanel;
  int? get _maxSavedBuilds =>
      widget.hasAdvancedAccess ? null : _guestSavedBuildLimit;
  bool get _isSavedBuildLimitReached {
    final int? maxSavedBuilds = _maxSavedBuilds;
    return maxSavedBuilds != null && _savedBuilds.length >= maxSavedBuilds;
  }

  @override
  void initState() {
    super.initState();
    _recalculateAll();
    _attachCoordinator();
    _loadEquipmentLibrary();
    _loadCrystalLibrary();
    _loadWeaponRuleConfig();
    _loadRuleSetConfig();
    unawaited(_refreshCustomEquipmentAccess(force: true));
    unawaited(_refreshCloudSavedBuilds(force: true));
    unawaited(_refreshRecommendationFeedbackSnapshot(force: true));
  }

  @override
  void didUpdateWidget(covariant BuildSimulatorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.coordinator != widget.coordinator) {
      oldWidget.coordinator?.detachHandlers();
      _attachCoordinator();
    }
    if (oldWidget.hasAdvancedAccess != widget.hasAdvancedAccess) {
      _setUiState(() {
        if (!_canUseAiGeneration) {
          _isAiRecommendationLoading = false;
        }
        _aiRecommendationSource = 'rule';
        _aiRecommendationMessage = _canUseAiGeneration
            ? _ruleRecommendationMessage
            : _guestAiLockedMessage;
      });
    }
    final bool authStateChanged =
        oldWidget.isAuthenticated != widget.isAuthenticated;
    final bool userChanged = oldWidget.currentUserId != widget.currentUserId;
    if (authStateChanged || userChanged) {
      unawaited(_refreshCustomEquipmentAccess(force: true));
      unawaited(_refreshCloudSavedBuilds(force: true));
      unawaited(_refreshRecommendationFeedbackSnapshot(force: true));
    }
  }

  @override
  void dispose() {
    widget.coordinator?.detachHandlers();
    _buildNameController.dispose();
    super.dispose();
  }

  void _setUiState(VoidCallback action) {
    setState(action);
    _syncCoordinatorSnapshot();
  }

  @override
  Widget build(BuildContext context) {
    return _buildScreenUI(context);
  }
}
