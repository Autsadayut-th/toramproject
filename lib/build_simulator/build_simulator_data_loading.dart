part of 'build_simulator_page.dart';

extension _BuildSimulatorDataLoading on BuildSimulatorScreenState {
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
      onUpsertCustomEquipment: _onUpsertCustomEquipment,
      onDeleteCustomEquipmentById: _onDeleteCustomEquipmentById,
      onClearAllData: _onClearAll,
      onGenerateAiRecommendations: _generateAiRecommendationsNow,
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
      selectedItemDetails: _selectedItemDetailsSnapshot(),
      aiRecommendations: _recommendations,
      isAiRecommendationLoading: _isAiRecommendationLoading,
      aiRecommendationSource: _aiRecommendationSource,
      aiRecommendationMessage: _aiRecommendationMessage,
    );
  }

  String? get _activeUserId {
    if (!widget.isAuthenticated) {
      return null;
    }
    final String? widgetUserId = widget.currentUserId?.trim();
    if (widgetUserId == null || widgetUserId.isEmpty) {
      return _savedBuildsService.currentUserId;
    }
    return widgetUserId;
  }

  Future<void> _refreshRecommendationFeedbackSnapshot({
    bool force = false,
  }) async {
    if (_activeUserId == null) {
      _setUiState(() {
        _feedbackSnapshot = const RecommendationFeedbackSnapshot.empty();
      });
      return;
    }

    if (_isLoadingFeedbackSnapshot) {
      return;
    }
    if (!force && !_feedbackSnapshot.isEmpty) {
      return;
    }

    _isLoadingFeedbackSnapshot = true;
    try {
      final RecommendationFeedbackSnapshot snapshot =
          await _recommendationFeedbackService.loadFeedbackSnapshot(
            userId: _activeUserId,
          );
      if (!mounted) {
        return;
      }
      _setUiState(() {
        _feedbackSnapshot = snapshot;
        final List<AiRecommendationItem> ranked =
            _effectiveRecommendationItems();
        _recommendationItems = ranked;
        _recommendations = ranked
            .map((AiRecommendationItem item) => item.normalizedMessage)
            .toList(growable: false);
      });
    } catch (error, stackTrace) {
      if (!error.toString().contains('permission-denied')) {
        _reportBackgroundLoadFailure(
          label: 'Recommendation feedback aggregation load',
          error: error,
          stackTrace: stackTrace,
        );
      }
    } finally {
      _isLoadingFeedbackSnapshot = false;
    }
  }

  Future<void> _refreshCloudSavedBuilds({bool force = false}) async {
    final String? activeUserId = _activeUserId;
    if (activeUserId == null) {
      _loadedCloudUserId = null;
      _hasPendingCloudSync = false;
      if (_savedBuilds.isEmpty) {
        return;
      }
      _setUiState(() {
        _savedBuilds.clear();
      });
      return;
    }

    if (!force && _loadedCloudUserId == activeUserId) {
      return;
    }
    if (_isLoadingCloudSavedBuilds) {
      return;
    }

    _isLoadingCloudSavedBuilds = true;
    try {
      final List<Map<String, dynamic>> cloudBuilds = await _savedBuildsService
          .fetchSavedBuilds();
      if (!mounted || _activeUserId != activeUserId) {
        return;
      }

      List<Map<String, dynamic>> normalized =
          BuildPersistenceService.normalizeBuildList(
            cloudBuilds,
            summaryTemplate: BuildCalculatorService.summaryTemplate,
          );
      final int? maxSavedBuilds = _maxSavedBuilds;
      bool truncated = false;
      if (maxSavedBuilds != null && normalized.length > maxSavedBuilds) {
        normalized = normalized.take(maxSavedBuilds).toList(growable: false);
        truncated = true;
      }

      _setUiState(() {
        _savedBuilds
          ..clear()
          ..addAll(normalized);
      });
      _loadedCloudUserId = activeUserId;
      if (truncated) {
        _showRestrictionMessage(
          BuildSimulatorScreenState._guestSaveLimitMessage,
        );
      }
    } catch (error, stackTrace) {
      _reportBackgroundLoadFailure(
        label: 'Cloud saved builds fetch',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        _showRestrictionMessage('Unable to load cloud saved builds.');
      }
    } finally {
      _isLoadingCloudSavedBuilds = false;
    }
  }

  void _scheduleCloudSync() {
    if (_isLoadingCloudSavedBuilds) {
      return;
    }
    if (_activeUserId == null) {
      return;
    }
    _hasPendingCloudSync = true;
    if (_isSavingCloudSavedBuilds) {
      return;
    }
    unawaited(_flushCloudSync());
  }

  Future<void> _flushCloudSync() async {
    if (_isSavingCloudSavedBuilds) {
      return;
    }
    _isSavingCloudSavedBuilds = true;
    try {
      while (_hasPendingCloudSync && mounted) {
        _hasPendingCloudSync = false;
        final String? activeUserId = _activeUserId;
        if (activeUserId == null) {
          return;
        }
        final List<Map<String, dynamic>> payload = _savedBuilds
            .map(
              (Map<String, dynamic> build) => Map<String, dynamic>.from(build),
            )
            .toList(growable: false);
        await _savedBuildsService.saveSavedBuilds(payload);
        _loadedCloudUserId = activeUserId;
      }
    } catch (error, stackTrace) {
      _reportBackgroundLoadFailure(
        label: 'Cloud saved builds sync',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        _showRestrictionMessage('Unable to sync saved builds to cloud.');
      }
    } finally {
      _isSavingCloudSavedBuilds = false;
    }
  }

  List<Map<String, dynamic>> _selectedItemDetailsSnapshot() {
    return <Map<String, dynamic>>[
      _slotDetailSnapshot(
        slotLabel: 'Main Weapon',
        item: _findEquipmentByKey(_mainWeaponId),
      ),
      _slotDetailSnapshot(
        slotLabel: 'Sub Weapon',
        item: _findEquipmentByKey(_subWeaponId),
      ),
      _slotDetailSnapshot(
        slotLabel: 'Armor',
        item: _findEquipmentByKey(_armorId),
      ),
      _slotDetailSnapshot(
        slotLabel: 'Additional',
        item: _findEquipmentByKey(_helmetId),
      ),
      _slotDetailSnapshot(
        slotLabel: 'Special',
        item: _findEquipmentByKey(_ringId),
      ),
      _gachaDetailSnapshot(),
    ];
  }

  Map<String, dynamic> _gachaDetailSnapshot() {
    final List<Map<String, String>> stats = <Map<String, String>>[];
    _appendGachaStatDetail(
      stats: stats,
      sectionLabel: 'Top',
      slotIndex: 1,
      rawSelection: _gacha1Stat1,
    );
    _appendGachaStatDetail(
      stats: stats,
      sectionLabel: 'Top',
      slotIndex: 2,
      rawSelection: _gacha1Stat2,
    );
    _appendGachaStatDetail(
      stats: stats,
      sectionLabel: 'Top',
      slotIndex: 3,
      rawSelection: _gacha1Stat3,
    );
    _appendGachaStatDetail(
      stats: stats,
      sectionLabel: 'Bottom',
      slotIndex: 1,
      rawSelection: _gacha2Stat1,
    );
    _appendGachaStatDetail(
      stats: stats,
      sectionLabel: 'Bottom',
      slotIndex: 2,
      rawSelection: _gacha2Stat2,
    );
    _appendGachaStatDetail(
      stats: stats,
      sectionLabel: 'Bottom',
      slotIndex: 3,
      rawSelection: _gacha2Stat3,
    );
    _appendGachaStatDetail(
      stats: stats,
      sectionLabel: 'Accessory',
      slotIndex: 1,
      rawSelection: _gacha3Stat1,
    );
    _appendGachaStatDetail(
      stats: stats,
      sectionLabel: 'Accessory',
      slotIndex: 2,
      rawSelection: _gacha3Stat2,
    );
    _appendGachaStatDetail(
      stats: stats,
      sectionLabel: 'Accessory',
      slotIndex: 3,
      rawSelection: _gacha3Stat3,
    );

    return <String, dynamic>{
      'slotLabel': 'Avatar Gacha',
      'itemName': stats.isEmpty ? '' : 'Top / Bottom / Accessory',
      'stats': stats,
    };
  }

  void _appendGachaStatDetail({
    required List<Map<String, String>> stats,
    required String sectionLabel,
    required int slotIndex,
    required String rawSelection,
  }) {
    final String selection = rawSelection.trim();
    if (selection.isEmpty) {
      return;
    }
    final EquipmentStat? decoded =
        AvatarGachaDataService.decodeSelectionAsEquipmentStat(selection);
    if (decoded == null) {
      stats.add(<String, String>{
        'label': '$sectionLabel Slot $slotIndex',
        'value': selection,
      });
      return;
    }

    stats.add(<String, String>{
      'label':
          '$sectionLabel Slot $slotIndex - ${_snapshotEquipmentStatLabel(decoded)}',
      'value': _snapshotEquipmentStatValue(decoded),
    });
  }

  Map<String, dynamic> _slotDetailSnapshot({
    required String slotLabel,
    required EquipmentLibraryItem? item,
  }) {
    final String itemName = item?.name.trim() ?? '';
    final List<Map<String, String>> stats = <Map<String, String>>[];
    if (item != null) {
      final List<EquipmentStat> baseStats = item.stats
          .where((EquipmentStat stat) {
            return stat.valueType.trim().toLowerCase() == 'base';
          })
          .toList(growable: false);
      final List<EquipmentStat> regularStats = item.stats
          .where((EquipmentStat stat) {
            return stat.valueType.trim().toLowerCase() != 'base';
          })
          .toList(growable: false);
      final List<EquipmentStat> orderedStats = <EquipmentStat>[
        ...baseStats,
        ...regularStats,
      ];
      for (final EquipmentStat stat in orderedStats) {
        stats.add(<String, String>{
          'label': _snapshotEquipmentStatLabel(stat),
          'value': _snapshotEquipmentStatValue(stat),
        });
      }
    }
    return <String, dynamic>{
      'slotLabel': slotLabel,
      'itemName': itemName,
      'stats': stats,
    };
  }

  String _snapshotEquipmentStatLabel(EquipmentStat stat) {
    final String normalizedKey = stat.statKey.trim().toLowerCase();
    final bool isBase = stat.valueType.trim().toLowerCase() == 'base';
    if (isBase) {
      switch (normalizedKey) {
        case 'weapon_atk':
          return 'Base ATK';
        case 'def':
          return 'Base DEF';
        case 'mdef':
          return 'Base MDEF';
        case 'stability':
          return 'Base Stability %';
        default:
          return 'Base ${_snapshotHumanizeStatKey(normalizedKey)}';
      }
    }

    switch (normalizedKey) {
      case 'weapon_atk':
        return 'Weapon ATK';
      case 'maxhp':
        return 'MaxHP';
      case 'maxmp':
        return 'MaxMP';
      case 'critical_rate':
        return 'Critical Rate';
      case 'critical_damage':
        return 'Critical Damage';
      case 'physical_pierce':
        return 'Physical Pierce';
      case 'magic_pierce':
        return 'Magic Pierce';
      case 'attack_mp_recovery':
        return 'Attack MP Recovery';
      case 'guard_power':
        return 'Guard Power';
      case 'guard_recharge':
        return 'Guard Recharge';
      case 'aggro':
        return 'Aggro';
      case 'aspd':
        return 'ASPD';
      case 'cspd':
        return 'CSPD';
      case 'atk':
        return 'ATK';
      case 'matk':
        return 'MATK';
      case 'def':
        return 'DEF';
      case 'mdef':
        return 'MDEF';
      case 'str':
        return 'STR';
      case 'dex':
        return 'DEX';
      case 'int':
        return 'INT';
      case 'agi':
        return 'AGI';
      case 'vit':
        return 'VIT';
      case 'stability':
        return 'Stability';
      case 'accuracy':
        return 'Accuracy';
      default:
        return _snapshotHumanizeStatKey(normalizedKey);
    }
  }

  String _snapshotEquipmentStatValue(EquipmentStat stat) {
    final String valueText = _snapshotFormatCompactNumber(stat.value);
    final bool isPercent = stat.valueType.trim().toLowerCase() == 'percent';
    final String sign = stat.value >= 0 ? '+' : '';
    return '$sign$valueText${isPercent ? '%' : ''}';
  }

  String _snapshotFormatCompactNumber(num value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    final String fixed = value.toStringAsFixed(2);
    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  String _snapshotHumanizeStatKey(String key) {
    if (key.isEmpty) {
      return '-';
    }

    String mapped = key.toLowerCase().replaceAllMapped(RegExp(r'[a-z0-9]+'), (
      Match match,
    ) {
      final String token = match.group(0)!;
      if (token == 'pct') {
        return '%';
      }
      const Set<String> uppercaseTokens = <String>{
        'atk',
        'matk',
        'def',
        'mdef',
        'str',
        'dex',
        'int',
        'agi',
        'vit',
        'aspd',
        'cspd',
        'hp',
        'mp',
        'ampr',
        'dmg',
        'exp',
        'm',
      };
      if (uppercaseTokens.contains(token)) {
        return token.toUpperCase();
      }
      if (token.length == 1) {
        return token.toUpperCase();
      }
      return '${token[0].toUpperCase()}${token.substring(1)}';
    });

    mapped = mapped.replaceAll('_', ' ');
    mapped = mapped.replaceAll(RegExp(r'\s+'), ' ');
    mapped = mapped.replaceAll(' )', ')');
    return mapped.trim();
  }

  Future<void> _loadEquipmentLibrary() async {
    try {
      final Map<String, List<EquipmentLibraryItem>> allCategories =
          await _equipmentRepository.loadAllCategories();
      final Map<String, EquipmentLibraryItem> byKey =
          <String, EquipmentLibraryItem>{};
      final Map<String, String> categoryByKey = <String, String>{};
      for (final MapEntry<String, List<EquipmentLibraryItem>> entry
          in allCategories.entries) {
        final String normalizedCategory = entry.key.trim().toLowerCase();
        final List<EquipmentLibraryItem> items = entry.value;
        for (final EquipmentLibraryItem item in items) {
          final String normalizedKey = item.key.trim().toLowerCase();
          if (normalizedKey.isEmpty) {
            continue;
          }
          byKey[normalizedKey] = item;
          categoryByKey[normalizedKey] = normalizedCategory;
        }
      }
      if (!mounted) {
        return;
      }
      _applyEquipmentCache(byKey, categoryByKey);
    } catch (error, stackTrace) {
      _reportBackgroundLoadFailure(
        label: 'Equipment library load',
        error: error,
        stackTrace: stackTrace,
        userMessage:
            'Unable to load equipment data from GitHub. Please check your network.',
      );
      if (!mounted) {
        return;
      }
      _applyEquipmentCache(
        const <String, EquipmentLibraryItem>{},
        const <String, String>{},
      );
    }
  }

  Future<void> _loadCrystalLibrary() async {
    try {
      final List<CrystalLibraryEntry> entries =
          await CrystalLibraryService.loadByCategories(
            BuildSimulatorScreenState._allCrystalCategories,
          );
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
    } catch (error, stackTrace) {
      _reportBackgroundLoadFailure(
        label: 'Crystal library load',
        error: error,
        stackTrace: stackTrace,
        userMessage:
            'Unable to load crystal data from GitHub. Please check your network.',
      );
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
        _subWeaponTypeAlias = Map<String, String>.from(
          config.subWeaponTypeAlias,
        );
        _mainToAllowedSubTypes = config.mainToAllowedSubTypes.map((
          String key,
          List<String> values,
        ) {
          return MapEntry<String, List<String>>(
            key,
            values.toList(growable: false),
          );
        });
      });
    } catch (error, stackTrace) {
      _reportBackgroundLoadFailure(
        label: 'Weapon rule config load',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _loadRuleSetConfig() async {
    try {
      final BuildRuleSet loaded = await BuildRuleSetService.load();
      if (!mounted) {
        return;
      }
      _setStateAndRecalculate(() {
        _ruleSet = loaded;
      });
    } catch (error, stackTrace) {
      _reportBackgroundLoadFailure(
        label: 'Build rule set load',
        error: error,
        stackTrace: stackTrace,
        userMessage:
            'Unable to load build rules from GitHub. Using fallback behavior.',
      );
    }
  }

  void _applyEquipmentCache(
    Map<String, EquipmentLibraryItem> byKey,
    Map<String, String> categoryByKey,
  ) {
    _setUiState(() {
      _libraryEquipmentByKey = byKey;
      _libraryEquipmentCategoryByKey = categoryByKey;
      _equipmentByKey = _mergedEquipmentCacheByKey();
      _equipmentCategoryByKey = _mergedEquipmentCategoryByKey();
      _recalculateAll();
    });
  }

  void _applyCustomEquipmentCache(
    Map<String, EquipmentLibraryItem> byKey,
    Map<String, String> categoryByKey,
  ) {
    _setUiState(() {
      _customEquipmentByKey = byKey;
      _customEquipmentCategoryByKey = categoryByKey;
      _equipmentByKey = _mergedEquipmentCacheByKey();
      _equipmentCategoryByKey = _mergedEquipmentCategoryByKey();
      _recalculateAll();
    });
  }

  Map<String, EquipmentLibraryItem> _mergedEquipmentCacheByKey() {
    return <String, EquipmentLibraryItem>{
      ..._libraryEquipmentByKey,
      ..._customEquipmentByKey,
    };
  }

  Map<String, String> _mergedEquipmentCategoryByKey() {
    return <String, String>{
      ..._libraryEquipmentCategoryByKey,
      ..._customEquipmentCategoryByKey,
    };
  }

  void _applyCrystalCache(Map<String, CrystalLibraryEntry> byKey) {
    _setUiState(() {
      _crystalsByKey = byKey;
      _recalculateAll();
    });
  }

  void _reportBackgroundLoadFailure({
    required String label,
    required Object error,
    required StackTrace stackTrace,
    String? userMessage,
  }) {
    debugPrint('[BuildSimulator] $label failed: $error');
    debugPrintStack(
      label: '[BuildSimulator] $label stack',
      stackTrace: stackTrace,
    );
    if (userMessage != null && userMessage.trim().isNotEmpty) {
      _showRestrictionMessage(userMessage);
    }
  }

  void _showRestrictionMessage(String message) {
    if (!mounted) {
      return;
    }
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.surfaceContainerHigh,
      ),
    );
  }
}
