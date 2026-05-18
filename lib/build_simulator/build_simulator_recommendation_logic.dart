part of 'build_simulator_page.dart';

extension _BuildSimulatorRecommendationLogic on BuildSimulatorScreenState {
  void _invalidateEffectiveRecommendationItemsCache() {
    _effectiveRecommendationItemsCache = null;
    _effectiveRecommendationItemsCacheKey = 0;
  }

  int _buildEffectiveRecommendationItemsCacheKey() {
    final List<String> recommendationItemSignatures = _recommendationItems
        .map((AiRecommendationItem item) {
          return '${item.id}|${item.priority}|${item.confidence}|${item.source}|${item.normalizedMessage}';
        })
        .toList(growable: false);
    final List<String> feedbackEntries =
        _feedbackByRecommendationId.entries
            .map((MapEntry<String, String> entry) {
              return '${entry.key}:${entry.value}';
            })
            .toList(growable: false)
          ..sort();
    return Object.hash(
      _aiRecommendationSource,
      _feedbackSnapshot.hashCode,
      Object.hashAll(_recommendations),
      Object.hashAll(recommendationItemSignatures),
      Object.hashAll(feedbackEntries),
    );
  }

  void _markCalculationContextDirty() {
    _isCalculationContextDirty = true;
  }

  void _setStateAndRecalculate(VoidCallback action) {
    // อัพเดท UI ทันที สำหรับ immediate feedback
    _setUiState(() {
      action();
      _enforceMainWeaponRule();
      _enforceSubWeaponRule();
      _markCalculationContextDirty();
    });

    // ดีบาว นซ์ recalculation เพื่อลด lag
    // ถ้า user เปลี่ยนค่าหลายครั้งต่อเนื่อง จะรวม recalculation เป็นครั้งเดียว
    _recalculationDebouncer.call(() {
      if (!mounted) return;
      _setUiState(_recalculateAll);
    });
  }

  void _setStateAndRecalculateCharacterOnly(VoidCallback action) {
    _setUiState(action);
    _recalculationDebouncer.call(() {
      if (!mounted) {
        return;
      }
      _setUiState(_recalculateCharacterOnly);
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

  Set<String> _allowedMainWeaponTypeKeys() {
    final Set<String> allowedTypeKeys = <String>{};
    for (final String alias in _weaponTypeAlias.values) {
      final String normalized = alias.trim();
      if (normalized.isNotEmpty) {
        allowedTypeKeys.add(normalized);
      }
    }
    for (final String key in _mainToAllowedSubTypes.keys) {
      final String normalized = key.trim();
      if (normalized.isNotEmpty) {
        allowedTypeKeys.add(normalized);
      }
    }
    return allowedTypeKeys;
  }

  List<String>? _allowedMainWeaponTypeNames() {
    if (_weaponTypeAlias.isEmpty) {
      return null;
    }

    final Set<String> displayTypes = <String>{};
    _weaponTypeAlias.forEach((String display, String alias) {
      final String displayType = display.trim();
      if (displayType.isNotEmpty) {
        displayTypes.add(displayType);
      }
      final String aliasType = alias.trim();
      if (aliasType.isNotEmpty) {
        displayTypes.add(aliasType);
      }
    });

    if (displayTypes.isEmpty) {
      return null;
    }
    return displayTypes.toList(growable: false);
  }

  bool _isMainWeaponSelectionAllowed(String? mainWeaponKey) {
    final String key = mainWeaponKey?.trim() ?? '';
    if (key.isEmpty) {
      return true;
    }
    final Set<String> allowedTypeKeys = _allowedMainWeaponTypeKeys();
    if (allowedTypeKeys.isEmpty) {
      return true;
    }

    final EquipmentLibraryItem? mainItem = _findEquipmentByKey(key);
    if (mainItem == null) {
      return true;
    }
    final String normalizedMainType = _normalizeMainWeaponType(mainItem.type);
    if (normalizedMainType.isEmpty) {
      return false;
    }
    return allowedTypeKeys.contains(normalizedMainType);
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
    final List<String>? allowedSubTypeKeys =
        _mainToAllowedSubTypes[normalizedMainType];
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
    final List<String>? allowedSubTypes =
        _mainToAllowedSubTypes[normalizedMainType];
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

  void _enforceMainWeaponRule() {
    if (_isMainWeaponSelectionAllowed(_mainWeaponId)) {
      return;
    }
    _mainWeaponId = null;
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

  List<String> _equipmentStatPreview(String? equipmentKey) {
    final EquipmentLibraryItem? item = _findEquipmentByKey(equipmentKey);
    if (item == null) {
      return const <String>[];
    }
    return item.stats.map(_formatStatPreview).toList(growable: false);
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

  List<EquipmentStat> _equippedCrystalStatsList() {
    return _equippedCrystalStats().toList(growable: false);
  }

  Iterable<String> _selectedGachaValues() sync* {
    final List<String> values = <String>[
      _gacha1Stat1,
      _gacha1Stat2,
      _gacha1Stat3,
      _gacha2Stat1,
      _gacha2Stat2,
      _gacha2Stat3,
      _gacha3Stat1,
      _gacha3Stat2,
      _gacha3Stat3,
    ];
    for (final String raw in values) {
      final String normalized = raw.trim();
      if (normalized.isEmpty) {
        continue;
      }
      yield normalized;
    }
  }

  List<EquipmentStat> _selectedGachaStatsList() {
    return _selectedGachaValues()
        .map(AvatarGachaDataService.decodeSelectionAsEquipmentStat)
        .whereType<EquipmentStat>()
        .toList(growable: false);
  }

  Map<String, List<String>> _crystalKeysByEquipment() {
    return <String, List<String>>{
      'Main Weapon': _normalizedCrystalKeys(<String?>[
        _mainCrystal1,
        _mainCrystal2,
      ]),
      'Armor': _normalizedCrystalKeys(<String?>[
        _armorCrystal1,
        _armorCrystal2,
      ]),
      'Helmet': _normalizedCrystalKeys(<String?>[
        _helmetCrystal1,
        _helmetCrystal2,
      ]),
      'Ring': _normalizedCrystalKeys(<String?>[_ringCrystal1, _ringCrystal2]),
    };
  }

  Map<String, String?> _crystalUpgradeFromByKey() {
    return _crystalsByKey.map((String key, CrystalLibraryEntry entry) {
      final String normalizedParent = (entry.upgradeFrom ?? '')
          .trim()
          .toLowerCase();
      return MapEntry<String, String?>(
        key,
        normalizedParent.isEmpty ? null : normalizedParent,
      );
    });
  }

  List<String> _normalizedCrystalKeys(Iterable<String?> values) {
    final List<String> keys = <String>[];
    for (final String? raw in values) {
      final String key = raw?.trim().toLowerCase() ?? '';
      if (key.isEmpty) {
        continue;
      }
      keys.add(key);
    }
    return keys.toList(growable: false);
  }

  BuildSimulationRequest _buildSimulationRequest() {
    return BuildSimulationRequest(
      character: Map<String, dynamic>.from(_character),
      level: _level,
      personalStatType: _personalStatType,
      personalStatValue: _personalStatValue,
      enhMain: _enhMain,
      enhSub: _enhSub,
      enhArmor: _enhArmor,
      enhHelmet: _enhHelmet,
      enhRing: _enhRing,
      armorMode: _armorMode,
      mainToAllowedSubTypes: _mainToAllowedSubTypes,
      ruleSet: _ruleSet,
      mainWeaponId: _mainWeaponId,
      subWeaponId: _subWeaponId,
      armorId: _armorId,
      helmetId: _helmetId,
      ringId: _ringId,
      findEquipmentByKey: _findEquipmentByKey,
      equippedCrystalStats: _equippedCrystalStatsList(),
      avatarStats: _selectedGachaStatsList(),
      crystalKeysByEquipment: _crystalKeysByEquipment(),
      crystalUpgradeFromByKey: _crystalUpgradeFromByKey(),
      normalizeMainWeaponType: _normalizeMainWeaponType,
    );
  }

  void _applySimulationResult(BuildSimulationResult result) {
    _calculationContextCache = result.context;
    _isCalculationContextDirty = false;
    _summary = result.summary;
    _recommendationItems = result.recommendationItems;
    _recommendations = result.recommendations;
    _showAllRecommendations = false;
    _invalidateEffectiveRecommendationItemsCache();
    _pruneRecommendationFeedback();
    _aiRecommendationUiState = _AiRecommendationUiState.fallback;
    _aiRecommendationSource = 'rule';
    _aiRecommendationMessage = _canUseAiGeneration
        ? BuildSimulatorScreenState._ruleRecommendationMessage
        : BuildSimulatorScreenState._guestAiLockedMessage;
  }

  void _recalculateAll() {
    final BuildSimulationResult result = _buildSimulationController
        .recalculateAll(_buildSimulationRequest());
    _applySimulationResult(result);
  }

  void _recalculateCharacterOnly() {
    final BuildCalculationContext? cached = _calculationContextCache;
    if (_isCalculationContextDirty || cached == null) {
      _recalculateAll();
      return;
    }
    final BuildSimulationResult result = _buildSimulationController
        .recalculateCharacterOnly(
          request: _buildSimulationRequest(),
          cachedContext: cached,
        );
    _applySimulationResult(result);
  }

  void _generateAiRecommendationsNow() {
    if (!_canUseAiGeneration) {
      _setUiState(() {
        _aiRecommendationUiState = _AiRecommendationUiState.error;
        _aiRecommendationSource = 'rule';
        _aiRecommendationMessage =
            BuildSimulatorScreenState._guestAiLockedMessage;
        _invalidateEffectiveRecommendationItemsCache();
      });
      _showRestrictionMessage('Login required to use AI Generate.');
      return;
    }
    final AiRecommendationRequestPayload payload = _buildAiRequestPayload(
      fallbackRecommendations: _recommendations,
      fallbackRecommendationItems: _recommendationItems,
    );
    final int token = ++_aiRecommendationRequestToken;
    _refreshAiRecommendations(token: token, payload: payload);
  }

  AiRecommendationRequestPayload _buildAiRequestPayload({
    required List<String> fallbackRecommendations,
    required List<AiRecommendationItem> fallbackRecommendationItems,
  }) {
    return AiRecommendationRequestPayload(
      level: _level,
      personalStatType: _personalStatType,
      personalStatValue: _personalStatValue,
      character: Map<String, dynamic>.from(_character),
      summary: Map<String, num>.from(_summary),
      equipmentSlots: <String, dynamic>{
        'mainWeaponId': _mainWeaponId,
        'subWeaponId': _subWeaponId,
        'armorId': _armorId,
        'armorMode': _armorMode,
        'helmetId': _helmetId,
        'ringId': _ringId,
        'enhanceMain': _enhMain,
        'enhanceArmor': _enhArmor,
        'enhanceHelmet': _enhHelmet,
        'enhanceRing': _enhRing,
      },
      fallbackRecommendations: List<String>.from(fallbackRecommendations),
      fallbackRecommendationItems: List<AiRecommendationItem>.from(
        fallbackRecommendationItems,
      ),
    );
  }

  Future<void> _refreshAiRecommendations({
    required int token,
    required AiRecommendationRequestPayload payload,
  }) async {
    if (!mounted) {
      return;
    }

    _setUiState(() {
      _isAiRecommendationLoading = true;
      _aiRecommendationUiState = _AiRecommendationUiState.loading;
      _aiRecommendationMessage = 'AI explaining local recommendations...';
    });

    try {
      final BuildRecommendationUiResult result =
          await _buildRecommendationController.fetchRecommendations(
            payload: payload,
          );
      if (!mounted || token != _aiRecommendationRequestToken) {
        return;
      }
      _setUiState(() {
        _recommendationItems = result.recommendationItems;
        _recommendations = result.recommendations;
        _showAllRecommendations = false;
        _invalidateEffectiveRecommendationItemsCache();
        _pruneRecommendationFeedback();
        _isAiRecommendationLoading = false;
        _aiRecommendationSource = result.source;
        _aiRecommendationUiState = result.isFallback
            ? _AiRecommendationUiState.fallback
            : _AiRecommendationUiState.success;
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
        _recommendationItems = _buildRecommendationController.buildFallbackItems(
          _recommendations,
        );
        _showAllRecommendations = false;
        _isAiRecommendationLoading = false;
        _aiRecommendationUiState = _AiRecommendationUiState.error;
        _aiRecommendationSource = 'fallback';
        _invalidateEffectiveRecommendationItemsCache();
        _aiRecommendationMessage = _buildAiStatusMessage(
          source: 'fallback',
          details: _aiErrorDetails(error),
        );
      });
    }
  }

  String _aiErrorDetails(Object error) {
    if (error is AiRecommendationRequestException) {
      final String code = error.errorCode.trim();
      if (code.isNotEmpty) {
        return '$code: ${error.message}';
      }
      return error.message;
    }
    return error.toString();
  }

  String _buildAiStatusMessage({required String source, String? details}) {
    return BuildAiStatusService.buildStatusMessage(
      source: source,
      ruleRecommendationMessage:
          BuildSimulatorScreenState._ruleRecommendationMessage,
      details: details,
    );
  }

  List<AiRecommendationItem> _effectiveRecommendationItems() {
    final int cacheKey = _buildEffectiveRecommendationItemsCacheKey();
    final List<AiRecommendationItem>? cached =
        _effectiveRecommendationItemsCache;
    if (cached != null && cacheKey == _effectiveRecommendationItemsCacheKey) {
      return cached;
    }

    final List<AiRecommendationItem> items = _recommendationItems.isNotEmpty
        ? _recommendationItems.toList(growable: false)
        : _recommendations
              .map((String message) {
                return AiRecommendationItem.fromText(
                  message: message,
                  category: 'analysis',
                  priority: 3,
                  source: _aiRecommendationSource,
                  confidence: 0.7,
                );
              })
              .toList(growable: false);

    int sessionPriorityDelta(AiRecommendationItem item) {
      final String feedback = _feedbackByRecommendationId[item.id] ?? '';
      if (feedback == 'like') {
        return -1;
      }
      if (feedback == 'dislike') {
        return 1;
      }
      return 0;
    }

    double aggregatePreferenceScore(AiRecommendationItem item) {
      return _recommendationFeedbackService.preferenceScoreFor(
        recommendation: item,
        snapshot: _feedbackSnapshot,
      );
    }

    int aggregatePriorityDelta(AiRecommendationItem item) {
      return _recommendationFeedbackService.priorityDeltaFor(
        recommendation: item,
        snapshot: _feedbackSnapshot,
      );
    }

    final List<AiRecommendationItem> ranked = items
        .map((AiRecommendationItem item) {
          final int adjustedPriority =
              (item.priority +
                      sessionPriorityDelta(item) +
                      aggregatePriorityDelta(item))
                  .clamp(1, 5)
                  .toInt();
          final double adjustedConfidence =
              AiRecommendationItem.normalizeConfidence(
                (item.confidence * 0.85) +
                    (aggregatePreferenceScore(item) * 0.15),
              );
          return item.copyWith(
            priority: adjustedPriority,
            confidence: adjustedConfidence,
          );
        })
        .toList(growable: false);

    ranked.sort((AiRecommendationItem a, AiRecommendationItem b) {
      final int priorityCompare = a.priority.compareTo(b.priority);
      if (priorityCompare != 0) {
        return priorityCompare;
      }
      final int sessionCompare = sessionPriorityDelta(
        a,
      ).compareTo(sessionPriorityDelta(b));
      if (sessionCompare != 0) {
        return sessionCompare;
      }
      final int aggregateScoreCompare = aggregatePreferenceScore(
        b,
      ).compareTo(aggregatePreferenceScore(a));
      if (aggregateScoreCompare != 0) {
        return aggregateScoreCompare;
      }
      return b.confidence.compareTo(a.confidence);
    });

    final List<AiRecommendationItem> readonlyRanked =
        List<AiRecommendationItem>.unmodifiable(ranked);
    _effectiveRecommendationItemsCacheKey = cacheKey;
    _effectiveRecommendationItemsCache = readonlyRanked;
    return readonlyRanked;
  }

  void _pruneRecommendationFeedback() {
    final int previousLength = _feedbackByRecommendationId.length;
    final Set<String> allowedIds = _effectiveRecommendationItems()
        .map((AiRecommendationItem item) => item.id.trim())
        .where((String id) => id.isNotEmpty)
        .toSet();
    _feedbackByRecommendationId.removeWhere((String id, String _) {
      return !allowedIds.contains(id);
    });
    if (previousLength != _feedbackByRecommendationId.length) {
      _invalidateEffectiveRecommendationItemsCache();
    }
  }

  Future<void> _onRecommendationFeedback({
    required AiRecommendationItem recommendation,
    required String reaction,
  }) async {
    if (_activeUserId == null) {
      return;
    }

    final String normalizedReaction = reaction.trim().toLowerCase();
    if (normalizedReaction != 'like' && normalizedReaction != 'dislike') {
      return;
    }
    final String id = recommendation.id.trim();
    if (id.isEmpty) {
      return;
    }

    _setUiState(() {
      _feedbackByRecommendationId[id] = normalizedReaction;
      _invalidateEffectiveRecommendationItemsCache();
      final List<AiRecommendationItem> sorted = _effectiveRecommendationItems();
      _recommendationItems = sorted;
      _recommendations = sorted
          .map((AiRecommendationItem item) => item.normalizedMessage)
          .toList(growable: false);
    });

    try {
      await _recommendationFeedbackService.submitFeedback(
        userId: _activeUserId,
        reaction: normalizedReaction,
        recommendation: recommendation,
        source: _aiRecommendationSource,
        level: _level,
        personalStatType: _personalStatType,
        personalStatValue: _personalStatValue,
        summary: Map<String, num>.from(_summary),
        character: Map<String, dynamic>.from(_character),
        equipmentSlots: <String, dynamic>{
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
      );
      unawaited(_refreshRecommendationFeedbackSnapshot(force: true));
    } catch (error, stackTrace) {
      _reportBackgroundLoadFailure(
        label: 'Recommendation feedback submit',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        _showRestrictionMessage('Unable to submit recommendation feedback.');
      }
    }
  }
}
