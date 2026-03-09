part of 'build_simulator_page.dart';

extension _BuildSimulatorPersistenceActions on BuildSimulatorScreenState {
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
    for (final String key in BuildSimulatorScreenState._characterStatKeys) {
      _character[key] = BuildPersistenceService.readIntValue(characterMap[key]);
    }
    _level = BuildPersistenceService.readIntValue(
      build['level'],
      fallback: _level,
    ).clamp(1, 999).toInt();
    _totalStatPoints = BuildPersistenceService.readIntValue(
      build['totalStatPoints'],
      fallback: BuildPersistenceService.defaultTotalStatPoints,
    ).clamp(1, 9999).toInt();
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
    _armorMode = 'normal';
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
      totalStatPoints: _totalStatPoints,
      personalStatType: _personalStatType,
      personalStatValue: _personalStatValue,
      mainWeaponId: _mainWeaponId,
      enhMain: _enhMain,
      mainCrystal1: _mainCrystal1,
      mainCrystal2: _mainCrystal2,
      subWeaponId: _subWeaponId,
      enhSub: _enhSub,
      armorId: _armorId,
      armorMode: _armorMode,
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
    final int? maxSavedBuilds = _maxSavedBuilds;
    if (maxSavedBuilds != null && _savedBuilds.length >= maxSavedBuilds) {
      _showRestrictionMessage(BuildSimulatorScreenState._guestSaveLimitMessage);
      return;
    }

    _setUiState(() {
      _savedBuilds.add(_buildCurrentSnapshot(normalizedName));
    });
    _scheduleCloudSync();
  }

  void _onSaveBuild() {
    _onSaveBuildByName(_buildNameController.text);
    _buildNameController.clear();
  }

  Future<void> _onCopyBuildShareCode(int index) async {
    if (index < 0 || index >= _savedBuilds.length) {
      return;
    }
    final String code = BuildPersistenceService.encodeBuildShareCode(
      _savedBuilds[index],
    );
    await Clipboard.setData(ClipboardData(text: code));
    _showRestrictionMessage('Build code copied.');
  }

  void _onImportBuildShareCode(String rawCode) {
    final String raw = rawCode.trim();
    if (raw.isEmpty) {
      _showRestrictionMessage('Paste build code first.');
      return;
    }

    final Map<String, dynamic>? decoded =
        BuildPersistenceService.decodeBuildShareCode(
          raw,
          summaryTemplate: BuildCalculatorService.summaryTemplate,
          fallbackIndex: _savedBuilds.length,
        );
    if (decoded == null) {
      _showRestrictionMessage('Invalid build code.');
      return;
    }

    final int before = _savedBuilds.length;
    _onMergeSavedBuilds(<Map<String, dynamic>>[decoded]);
    final int after = _savedBuilds.length;
    if (after > before) {
      _showRestrictionMessage('Build code imported.');
    }
  }

  Future<void> _onRequestImportBuildShareCode() async {
    final TextEditingController codeController = TextEditingController();
    final String? code = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final ColorScheme colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: colorScheme.surfaceContainerHigh,
          title: Text(
            'Import Build Code',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          content: TextField(
            controller: codeController,
            autofocus: true,
            minLines: 2,
            maxLines: 4,
            style: TextStyle(color: colorScheme.onSurface, fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Paste shared build code (TB...)',
              hintStyle: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: colorScheme.onSurface.withValues(alpha: 0.22),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: colorScheme.onSurface.withValues(alpha: 0.45),
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(codeController.text);
              },
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: const Text('Import'),
            ),
          ],
        );
      },
    );
    codeController.dispose();
    if (code == null) {
      return;
    }
    _onImportBuildShareCode(code);
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
    _scheduleCloudSync();
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
    _scheduleCloudSync();
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
    _scheduleCloudSync();
  }

  void _onReplaceSavedBuilds(List<Map<String, dynamic>> rawBuilds) {
    List<Map<String, dynamic>> normalized =
        BuildPersistenceService.normalizeBuildList(
          rawBuilds,
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
    _scheduleCloudSync();
    if (truncated) {
      _showRestrictionMessage(BuildSimulatorScreenState._guestSaveLimitMessage);
    }
  }

  void _onMergeSavedBuilds(List<Map<String, dynamic>> rawBuilds) {
    final Set<String> reservedIds = <String>{};
    for (int i = 0; i < _savedBuilds.length; i++) {
      reservedIds.add(BuildPersistenceService.buildIdFor(_savedBuilds[i], i));
    }

    List<Map<String, dynamic>> normalized =
        BuildPersistenceService.normalizeBuildList(
          rawBuilds,
          reservedIds: reservedIds,
          summaryTemplate: BuildCalculatorService.summaryTemplate,
        );
    if (normalized.isEmpty) {
      return;
    }
    final int? maxSavedBuilds = _maxSavedBuilds;
    bool truncated = false;
    if (maxSavedBuilds != null) {
      final int remainingSlots = maxSavedBuilds - _savedBuilds.length;
      if (remainingSlots <= 0) {
        _showRestrictionMessage(
          BuildSimulatorScreenState._guestSaveLimitMessage,
        );
        return;
      }
      if (normalized.length > remainingSlots) {
        normalized = normalized.take(remainingSlots).toList(growable: false);
        truncated = true;
      }
    }
    _setUiState(() {
      _savedBuilds.addAll(normalized);
    });
    _scheduleCloudSync();
    if (truncated) {
      _showRestrictionMessage(BuildSimulatorScreenState._guestSaveLimitMessage);
    }
  }

  void _resetCharacterDefaults() {
    _character.addAll(BuildSimulatorScreenState._defaultCharacterStats);
    _level = 1;
    _totalStatPoints = BuildSimulatorScreenState._defaultTotalStatPoints;
    _personalStatType = BuildSimulatorScreenState._personalStatOptions.first;
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
    _armorMode = 'normal';
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
    _scheduleCloudSync();
  }

  Future<void> _onRequestClearAll() async {
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            final ColorScheme colorScheme = Theme.of(context).colorScheme;
            return AlertDialog(
              backgroundColor: colorScheme.surfaceContainerHigh,
              title: Text(
                'Clear All Data',
                style: TextStyle(color: colorScheme.onSurface),
              ),
              content: Text(
                'Delete all current values and saved builds?',
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;
    if (!confirmed) {
      return;
    }
    _onClearAll();
  }

  void _setShowRecommendationsPanel(bool value) {
    _setUiState(() {
      _showRecommendationsPanel = value;
    });
  }
}
