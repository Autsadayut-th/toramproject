part of 'build_simulator_page.dart';

extension _BuildSimulatorEquipmentPanelUI on BuildSimulatorScreenState {
  int _usedStatPoints() {
    int used = 5;
    for (final String key in BuildSimulatorScreenState._characterStatKeys) {
      final dynamic raw = _character[key];
      final int value = raw is num ? raw.toInt() : 0;
      used += (value - 1).clamp(0, 510).toInt();
    }
    return used + _personalStatValue.clamp(0, 255).toInt();
  }

  Widget _buildEquipmentPanel() {
    return ToramCard(
      title: 'Equipment Configuration',
      icon: Icons.shield,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 980;
          if (isDesktop) {
            return _buildDesktopEquipmentMatrix();
          }
          return _buildEquipmentPanelMobile();
        },
      ),
    );
  }

  Widget _buildDesktopEquipmentMatrix() {
    const spacing = 16.0;
    const slotHeight = 60.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildCharacterStatsSection(
                    compact: false,
                    minHeight: slotHeight,
                  ),
                  const SizedBox(height: spacing),
                  _buildSubWeaponSection(compact: false, minHeight: slotHeight),
                  const SizedBox(height: spacing),
                  _buildHelmetSection(compact: false, minHeight: slotHeight),
                ],
              ),
            ),
            const SizedBox(width: spacing),
            Expanded(
              child: Column(
                children: [
                  _buildMainWeaponSection(
                    compact: false,
                    minHeight: slotHeight,
                  ),
                  const SizedBox(height: spacing),
                  _buildArmorSection(compact: false, minHeight: slotHeight),
                  const SizedBox(height: spacing),
                  _buildRingSection(compact: false, minHeight: slotHeight),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: spacing),
        _buildGachaSection(compact: false, minHeight: slotHeight),
      ],
    );
  }

  Widget _buildEquipmentSlotBox({
    required String title,
    required IconData iconData,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
    required double minHeight,
  }) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isLight = theme.brightness == Brightness.light;
    final placeholderHeight = (minHeight - 48).isNegative
        ? 0.0
        : minHeight - 48;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: isLight ? 0.28 : 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  Icon(iconData, color: colorScheme.onSurface, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: colorScheme.onSurface.withValues(alpha: 0.75),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: colorScheme.onSurface.withValues(
                      alpha: isLight ? 0.2 : 0.12,
                    ),
                  ),
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: child,
            )
          else
            SizedBox(height: placeholderHeight),
        ],
      ),
    );
  }

  Widget _buildSectionFrame({
    required bool compact,
    required String title,
    required IconData iconData,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
    required double minHeight,
  }) {
    if (compact) {
      return _buildCollapsibleCard(
        title: title,
        iconData: iconData,
        isExpanded: isExpanded,
        onToggle: onToggle,
        child: child,
      );
    }

    return _buildEquipmentSlotBox(
      title: title,
      iconData: iconData,
      isExpanded: isExpanded,
      onToggle: onToggle,
      child: child,
      minHeight: minHeight,
    );
  }

  Widget _buildCharacterStatsSection({
    required bool compact,
    required double minHeight,
  }) {
    return _buildSectionFrame(
      compact: compact,
      title: 'Character Stats',
      iconData: Icons.person,
      isExpanded: _isCharacterStatsExpanded,
      onToggle: () {
        _setUiState(() {
          _isCharacterStatsExpanded = !_isCharacterStatsExpanded;
        });
      },
      child: CharacterStatsSelector(
        character: _character,
        level: _level,
        personalStatType: _personalStatType,
        personalStatValue: _personalStatValue,
        usedStatPoints: _usedStatPoints(),
        totalStatPoints: _totalStatPoints,
        onTotalStatPointsChanged: (int value) {
          _setStateAndRecalculate(() => _totalStatPoints = value);
        },
        onStatChanged: (String key, int value) {
          _setStateAndRecalculate(() => _character[key] = value);
        },
        onLevelChanged: (int level) {
          _setStateAndRecalculate(() => _level = level);
        },
        onPersonalStatTypeChanged: (String type) {
          _setStateAndRecalculate(() => _personalStatType = type);
        },
        onPersonalStatValueChanged: (int value) {
          _setStateAndRecalculate(() => _personalStatValue = value);
        },
        onRecalculate: () {
          _setUiState(_recalculateAll);
        },
      ),
      minHeight: minHeight,
    );
  }

  Widget _buildMainWeaponSection({
    required bool compact,
    required double minHeight,
  }) {
    return _buildSectionFrame(
      compact: compact,
      title: 'Main Weapon',
      iconData: Icons.sports_martial_arts,
      isExpanded: _isMainWeaponExpanded,
      onToggle: () {
        _setUiState(() {
          _isMainWeaponExpanded = !_isMainWeaponExpanded;
        });
      },
      child: MainWeaponEquipmentSelector(
        selectedId: _mainWeaponId,
        selectedDisplayName: _equipmentName(_mainWeaponId),
        selectedEquipmentItem: _findEquipmentByKey(_mainWeaponId),
        searchCandidates: _mainWeaponSearchCandidates(),
        allowedItemTypes: _allowedMainWeaponTypeNames(),
        statPreview: _equipmentStatPreview(_mainWeaponId),
        onEquipChanged: (id) {
          if (!_isMainWeaponSelectionAllowed(id)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Main weapon type is not allowed.'),
                duration: Duration(seconds: 2),
              ),
            );
            return;
          }
          _setStateAndRecalculate(() => _mainWeaponId = id);
        },
        enhance: _enhMain,
        onEnhChanged: (v) {
          _setStateAndRecalculate(() => _enhMain = v);
        },
        crystal1: _mainCrystal1,
        crystal2: _mainCrystal2,
        onCreateCustomItem: () {
          unawaited(_openCustomEquipmentCreator(category: 'weapon'));
        },
        onCrystal1Changed: (v) {
          _setStateAndRecalculate(() => _mainCrystal1 = v);
        },
        onCrystal2Changed: (v) {
          _setStateAndRecalculate(() => _mainCrystal2 = v);
        },
      ),
      minHeight: minHeight,
    );
  }

  List<EquipmentLibraryItem> _mainWeaponSearchCandidates() {
    final List<EquipmentLibraryItem> candidates =
        _equipmentSearchCandidatesByCategory('weapon');
    return candidates
        .where((EquipmentLibraryItem item) {
          return _isMainWeaponSelectionAllowed(item.key);
        })
        .toList(growable: false);
  }

  List<EquipmentLibraryItem> _subWeaponSearchCandidates() {
    final List<EquipmentLibraryItem> candidates =
        _equipmentSearchCandidatesByCategory('weapon');
    return candidates
        .where((EquipmentLibraryItem item) {
          return _isSubWeaponSelectionAllowed(item.key);
        })
        .toList(growable: false);
  }

  List<EquipmentLibraryItem> _armorSearchCandidates() {
    return _equipmentSearchCandidatesByCategory('armor');
  }

  List<EquipmentLibraryItem> _helmetSearchCandidates() {
    return _equipmentSearchCandidatesByCategory('additional');
  }

  List<EquipmentLibraryItem> _ringSearchCandidates() {
    return _equipmentSearchCandidatesByCategory('special');
  }

  List<EquipmentLibraryItem> _equipmentSearchCandidatesByCategory(
    String category,
  ) {
    final String normalizedCategory = category.trim().toLowerCase();
    final List<EquipmentLibraryItem> candidates = <EquipmentLibraryItem>[];
    for (final MapEntry<String, EquipmentLibraryItem> entry
        in _equipmentByKey.entries) {
      final String itemCategory = _equipmentCategoryByKey[entry.key] ?? '';
      if (itemCategory != normalizedCategory) {
        continue;
      }
      candidates.add(entry.value);
    }
    candidates.sort((EquipmentLibraryItem a, EquipmentLibraryItem b) {
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return candidates;
  }

  Widget _buildSubWeaponSection({
    required bool compact,
    required double minHeight,
  }) {
    return _buildSectionFrame(
      compact: compact,
      title: 'Sub Weapon',
      iconData: Icons.shield,
      isExpanded: _isSubWeaponExpanded,
      onToggle: () {
        _setUiState(() {
          _isSubWeaponExpanded = !_isSubWeaponExpanded;
        });
      },
      child: SubWeaponEquipmentSelector(
        selectedId: _subWeaponId,
        selectedEquipmentItem: _findEquipmentByKey(_subWeaponId),
        searchCandidates: _subWeaponSearchCandidates(),
        statPreview: _equipmentStatPreview(_subWeaponId),
        allowedItemTypes: _allowedSubWeaponTypeNames(),
        onEquipChanged: (id) {
          if (!_isSubWeaponSelectionAllowed(id)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Sub weapon type is not allowed for this main weapon.',
                ),
                duration: Duration(seconds: 2),
              ),
            );
            return;
          }
          _setStateAndRecalculate(() => _subWeaponId = id);
        },
        enhance: _enhSub,
        onEnhChanged: (v) {
          _setStateAndRecalculate(() => _enhSub = v);
        },
      ),
      minHeight: minHeight,
    );
  }

  Widget _buildArmorSection({
    required bool compact,
    required double minHeight,
  }) {
    return _buildSectionFrame(
      compact: compact,
      title: 'Armor',
      iconData: Icons.shield_outlined,
      isExpanded: _isArmorExpanded,
      onToggle: () {
        _setUiState(() {
          _isArmorExpanded = !_isArmorExpanded;
        });
      },
      child: ArmorEquipmentSelector(
        armorMode: _armorMode,
        onArmorModeChanged: (String mode) {
          _setStateAndRecalculate(() => _armorMode = mode);
        },
        selectedId: _armorId,
        selectedEquipmentItem: _findEquipmentByKey(_armorId),
        searchCandidates: _armorSearchCandidates(),
        statPreview: _equipmentStatPreview(_armorId),
        onCreateCustomItem: () {
          unawaited(_openCustomEquipmentCreator(category: 'armor'));
        },
        onEquipChanged: (id) {
          _setStateAndRecalculate(() => _armorId = id);
        },
        enhance: _enhArmor,
        onEnhChanged: (v) {
          _setStateAndRecalculate(() => _enhArmor = v);
        },
        crystal1: _armorCrystal1,
        crystal2: _armorCrystal2,
        onCrystal1Changed: (v) {
          _setStateAndRecalculate(() => _armorCrystal1 = v);
        },
        onCrystal2Changed: (v) {
          _setStateAndRecalculate(() => _armorCrystal2 = v);
        },
      ),
      minHeight: minHeight,
    );
  }

  Widget _buildHelmetSection({
    required bool compact,
    required double minHeight,
  }) {
    return _buildSectionFrame(
      compact: compact,
      title: 'Helmet',
      iconData: Icons.military_tech,
      isExpanded: _isHelmetExpanded,
      onToggle: () {
        _setUiState(() {
          _isHelmetExpanded = !_isHelmetExpanded;
        });
      },
      child: HelmetEquipmentSelector(
        selectedId: _helmetId,
        selectedEquipmentItem: _findEquipmentByKey(_helmetId),
        searchCandidates: _helmetSearchCandidates(),
        statPreview: _equipmentStatPreview(_helmetId),
        onEquipChanged: (id) {
          _setStateAndRecalculate(() => _helmetId = id);
        },
        enhance: _enhHelmet,
        onEnhChanged: (v) {
          _setStateAndRecalculate(() => _enhHelmet = v);
        },
        crystal1: _helmetCrystal1,
        crystal2: _helmetCrystal2,
        onCrystal1Changed: (v) {
          _setStateAndRecalculate(() => _helmetCrystal1 = v);
        },
        onCrystal2Changed: (v) {
          _setStateAndRecalculate(() => _helmetCrystal2 = v);
        },
      ),
      minHeight: minHeight,
    );
  }

  Widget _buildRingSection({required bool compact, required double minHeight}) {
    return _buildSectionFrame(
      compact: compact,
      title: 'Ring',
      iconData: Icons.diamond_outlined,
      isExpanded: _isRingExpanded,
      onToggle: () {
        _setUiState(() {
          _isRingExpanded = !_isRingExpanded;
        });
      },
      child: RingEquipmentSelector(
        selectedId: _ringId,
        selectedEquipmentItem: _findEquipmentByKey(_ringId),
        searchCandidates: _ringSearchCandidates(),
        statPreview: _equipmentStatPreview(_ringId),
        onEquipChanged: (id) {
          _setStateAndRecalculate(() => _ringId = id);
        },
        enhance: _enhRing,
        onEnhChanged: (v) {
          _setStateAndRecalculate(() => _enhRing = v);
        },
        crystal1: _ringCrystal1,
        crystal2: _ringCrystal2,
        onCrystal1Changed: (v) {
          _setStateAndRecalculate(() => _ringCrystal1 = v);
        },
        onCrystal2Changed: (v) {
          _setStateAndRecalculate(() => _ringCrystal2 = v);
        },
      ),
      minHeight: minHeight,
    );
  }

  Widget _buildGachaSection({
    required bool compact,
    required double minHeight,
  }) {
    return _buildSectionFrame(
      compact: compact,
      title: 'Gacha Equipment',
      iconData: Icons.casino,
      isExpanded: _isGachaExpanded,
      onToggle: () {
        _setUiState(() {
          _isGachaExpanded = !_isGachaExpanded;
        });
      },
      child: GachaCard(
        gacha1Stat1: _gacha1Stat1,
        gacha1Stat2: _gacha1Stat2,
        gacha1Stat3: _gacha1Stat3,
        gacha2Stat1: _gacha2Stat1,
        gacha2Stat2: _gacha2Stat2,
        gacha2Stat3: _gacha2Stat3,
        gacha3Stat1: _gacha3Stat1,
        gacha3Stat2: _gacha3Stat2,
        gacha3Stat3: _gacha3Stat3,
        onGacha1Stat1Changed: (v) {
          _setStateAndRecalculate(() => _gacha1Stat1 = v);
        },
        onGacha1Stat2Changed: (v) {
          _setStateAndRecalculate(() => _gacha1Stat2 = v);
        },
        onGacha1Stat3Changed: (v) {
          _setStateAndRecalculate(() => _gacha1Stat3 = v);
        },
        onGacha2Stat1Changed: (v) {
          _setStateAndRecalculate(() => _gacha2Stat1 = v);
        },
        onGacha2Stat2Changed: (v) {
          _setStateAndRecalculate(() => _gacha2Stat2 = v);
        },
        onGacha2Stat3Changed: (v) {
          _setStateAndRecalculate(() => _gacha2Stat3 = v);
        },
        onGacha3Stat1Changed: (v) {
          _setStateAndRecalculate(() => _gacha3Stat1 = v);
        },
        onGacha3Stat2Changed: (v) {
          _setStateAndRecalculate(() => _gacha3Stat2 = v);
        },
        onGacha3Stat3Changed: (v) {
          _setStateAndRecalculate(() => _gacha3Stat3 = v);
        },
      ),
      minHeight: minHeight,
    );
  }

  Widget _buildEquipmentPanelMobile() {
    return Column(
      children: [
        _buildCharacterStatsSection(compact: true, minHeight: 96),
        const SizedBox(height: 16),
        _buildMainWeaponSection(compact: true, minHeight: 96),
        const SizedBox(height: 16),
        _buildSubWeaponSection(compact: true, minHeight: 96),
        const SizedBox(height: 16),
        _buildArmorSection(compact: true, minHeight: 96),
        const SizedBox(height: 16),
        _buildHelmetSection(compact: true, minHeight: 96),
        const SizedBox(height: 16),
        _buildRingSection(compact: true, minHeight: 96),
        const SizedBox(height: 16),
        _buildGachaSection(compact: true, minHeight: 96),
      ],
    );
  }
}
