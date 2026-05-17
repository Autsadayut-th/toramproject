part of 'build_simulator_page.dart';

extension _BuildSimulatorScreenSectionsUI on BuildSimulatorScreenState {
  BoxDecoration _panelDecoration() {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isLight = theme.brightness == Brightness.light;
    return BoxDecoration(
      color: colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: colorScheme.onSurface.withValues(alpha: isLight ? 0.24 : 0.16),
      ),
      boxShadow: [
        BoxShadow(
          color: colorScheme.onSurface.withValues(alpha: 0.12),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  Widget _buildStatsSummary() {
    return Container(
      decoration: _panelDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsSummaryHeader(),
          const SizedBox(height: 14),
          _buildSummaryModeSwitch(),
          const SizedBox(height: 14),
          if (_summaryViewMode == _SummaryViewMode.metricList)
            _buildStatsValueView()
          else
            _buildSelectedItemDetailsView(),
        ],
      ),
    );
  }

  Widget _buildStatsSummaryHeader() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.surfaceContainerHighest,
          ),
          child: Icon(Icons.assessment, color: colorScheme.onSurface, size: 17),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Stats Summary',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryModeSwitch() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        children: [
          _buildSummaryModeButton(
            label: 'Values',
            mode: _SummaryViewMode.metricList,
          ),
          const SizedBox(width: 6),
          _buildSummaryModeButton(
            label: 'Item Details',
            mode: _SummaryViewMode.itemDetails,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryModeButton({
    required String label,
    required _SummaryViewMode mode,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isActive = _summaryViewMode == mode;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          if (isActive) {
            return;
          }
          _setUiState(() {
            _summaryViewMode = mode;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isActive
                ? colorScheme.surfaceContainerHigh
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive
                  ? colorScheme.onSurface.withValues(alpha: 0.35)
                  : colorScheme.onSurface.withValues(alpha: 0.15),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? colorScheme.onSurface
                  : colorScheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsValueView() {
    return Column(
      children: [
        _statsCategory(Icons.gavel, 'Attack', <MapEntry<String, String>>[
          MapEntry('ATK', 'ATK'),
          MapEntry('MATK', 'MATK'),
        ]),
        _statsCategory(Icons.shield, 'Defense', <MapEntry<String, String>>[
          MapEntry('DEF', 'DEF'),
          MapEntry('MDEF', 'MDEF'),
        ]),
        _statsCategory(
          Icons.fitness_center,
          'Main Stats',
          <MapEntry<String, String>>[
            MapEntry('STR', 'STR'),
            MapEntry('DEX', 'DEX'),
            MapEntry('INT', 'INT'),
            MapEntry('AGI', 'AGI'),
            MapEntry('VIT', 'VIT'),
          ],
        ),
        _statsCategory(Icons.bolt, 'Special Stats', <MapEntry<String, String>>[
          MapEntry('ASPD', 'ASPD'),
          MapEntry('CSPD', 'CSPD'),
          MapEntry('FLEE', 'FLEE'),
          MapEntry('CritRate', 'Critical Rate'),
          MapEntry('PhysicalPierce', 'Piercing (Physical)'),
          MapEntry('MagicPierce', 'Piercing (Magic)'),
          MapEntry('Accuracy', 'HIT'),
          MapEntry('Stability', 'Stability'),
          MapEntry('HP', 'HP'),
          MapEntry('MP', 'MP'),
        ]),
      ],
    );
  }

  Widget _buildSelectedItemDetailsView() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildEquipmentSlotStatsSection(
            slotLabel: 'Main Weapon',
            equipmentKey: _mainWeaponId,
            item: _findEquipmentByKey(_mainWeaponId),
          ),
          const SizedBox(height: 12),
          _buildEquipmentSlotStatsSection(
            slotLabel: 'Sub Weapon',
            equipmentKey: _subWeaponId,
            item: _findEquipmentByKey(_subWeaponId),
          ),
          const SizedBox(height: 12),
          _buildEquipmentSlotStatsSection(
            slotLabel: 'Armor',
            equipmentKey: _armorId,
            item: _findEquipmentByKey(_armorId),
          ),
          const SizedBox(height: 12),
          _buildEquipmentSlotStatsSection(
            slotLabel: 'Additional',
            equipmentKey: _helmetId,
            item: _findEquipmentByKey(_helmetId),
          ),
          const SizedBox(height: 12),
          _buildEquipmentSlotStatsSection(
            slotLabel: 'Special',
            equipmentKey: _ringId,
            item: _findEquipmentByKey(_ringId),
          ),
          const SizedBox(height: 12),
          _buildGachaStatsSection(),
        ],
      ),
    );
  }

  Widget _buildGachaStatsSection() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final List<Map<String, String>> gachaStats = _buildGachaStatsRows();
    final bool hasStats = gachaStats.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Avatar Gacha:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(
            hasStats ? 'Top / Bottom / Accessory' : '-',
            style: TextStyle(
              fontSize: 13,
              color: hasStats
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.54),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (!hasStats) ...<Widget>[
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(left: 14),
            child: Text(
              'No gacha selected',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.54),
              ),
            ),
          ),
        ] else ...<Widget>[
          const SizedBox(height: 5),
          ...List<Widget>.generate(gachaStats.length, (int index) {
            final Map<String, String> row = gachaStats[index];
            final String label = row['label'] ?? '-';
            final String value = row['value'] ?? '0';
            final bool isNegative = value.startsWith('-');
            return Padding(
              padding: EdgeInsets.only(
                left: 14,
                bottom: index == gachaStats.length - 1 ? 0 : 3,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      color: isNegative
                          ? colorScheme.error
                          : colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  List<Map<String, String>> _buildGachaStatsRows() {
    final List<Map<String, String>> rows = <Map<String, String>>[];
    _appendGachaStatsRow(
      rows: rows,
      sectionLabel: 'Top',
      slotIndex: 1,
      rawSelection: _gacha1Stat1,
    );
    _appendGachaStatsRow(
      rows: rows,
      sectionLabel: 'Top',
      slotIndex: 2,
      rawSelection: _gacha1Stat2,
    );
    _appendGachaStatsRow(
      rows: rows,
      sectionLabel: 'Top',
      slotIndex: 3,
      rawSelection: _gacha1Stat3,
    );
    _appendGachaStatsRow(
      rows: rows,
      sectionLabel: 'Bottom',
      slotIndex: 1,
      rawSelection: _gacha2Stat1,
    );
    _appendGachaStatsRow(
      rows: rows,
      sectionLabel: 'Bottom',
      slotIndex: 2,
      rawSelection: _gacha2Stat2,
    );
    _appendGachaStatsRow(
      rows: rows,
      sectionLabel: 'Bottom',
      slotIndex: 3,
      rawSelection: _gacha2Stat3,
    );
    _appendGachaStatsRow(
      rows: rows,
      sectionLabel: 'Accessory',
      slotIndex: 1,
      rawSelection: _gacha3Stat1,
    );
    _appendGachaStatsRow(
      rows: rows,
      sectionLabel: 'Accessory',
      slotIndex: 2,
      rawSelection: _gacha3Stat2,
    );
    _appendGachaStatsRow(
      rows: rows,
      sectionLabel: 'Accessory',
      slotIndex: 3,
      rawSelection: _gacha3Stat3,
    );
    return rows;
  }

  void _appendGachaStatsRow({
    required List<Map<String, String>> rows,
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
      rows.add(<String, String>{
        'label': '$sectionLabel Slot $slotIndex',
        'value': selection,
      });
      return;
    }

    rows.add(<String, String>{
      'label':
          '$sectionLabel Slot $slotIndex - ${_equipmentStatLabel(decoded)}',
      'value': _equipmentStatValue(decoded),
    });
  }

  Widget _buildEquipmentSlotStatsSection({
    required String slotLabel,
    required String? equipmentKey,
    required EquipmentLibraryItem? item,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String itemName = item?.name.trim() ?? '';
    final List<EquipmentStat> baseStats = item == null
        ? const <EquipmentStat>[]
        : item.stats
              .where((EquipmentStat stat) {
                return stat.valueType.trim().toLowerCase() == 'base';
              })
              .toList(growable: false);
    final List<EquipmentStat> regularStats = item == null
        ? const <EquipmentStat>[]
        : item.stats
              .where((EquipmentStat stat) {
                return stat.valueType.trim().toLowerCase() != 'base';
              })
              .toList(growable: false);
    final List<EquipmentStat> orderedStats = <EquipmentStat>[
      ...baseStats,
      ...regularStats,
    ];
    final CustomEquipmentItem? customItem = _findCustomEquipmentItemByKey(
      equipmentKey,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '$slotLabel:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(
            itemName.isEmpty ? '-' : itemName,
            style: TextStyle(
              fontSize: 13,
              color: itemName.isEmpty
                  ? colorScheme.onSurface.withValues(alpha: 0.54)
                  : colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (customItem != null)
          Padding(
            padding: const EdgeInsets.only(left: 14, top: 6),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: () {
                    unawaited(_openCustomEquipmentEditorByKey(equipmentKey));
                  },
                  icon: const Icon(Icons.edit, size: 14),
                  label: const Text('Edit'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    unawaited(_confirmDeleteCustomEquipmentByKey(equipmentKey));
                  },
                  icon: const Icon(Icons.delete_outline, size: 14),
                  label: const Text('Delete'),
                ),
              ],
            ),
          ),
        if (item == null) ...<Widget>[
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(left: 14),
            child: Text(
              'No item selected',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.54),
              ),
            ),
          ),
        ] else ...<Widget>[
          const SizedBox(height: 5),
          if (orderedStats.isEmpty)
            Padding(
              padding: EdgeInsets.only(left: 14),
              child: Text(
                'No stat data',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.54),
                ),
              ),
            )
          else
            ...List<Widget>.generate(orderedStats.length, (int index) {
              return Padding(
                padding: EdgeInsets.only(
                  left: 14,
                  bottom: index == orderedStats.length - 1 ? 0 : 3,
                ),
                child: _buildEquipmentStatLine(orderedStats[index]),
              );
            }),
        ],
      ],
    );
  }

  Widget _buildEquipmentStatLine(EquipmentStat stat) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String label = _equipmentStatLabel(stat);
    final String value = _equipmentStatValue(stat);
    final bool isPositive = stat.value >= 0;
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: isPositive ? colorScheme.onSurface : colorScheme.error,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _equipmentStatLabel(EquipmentStat stat) {
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
          return 'Base ${_humanizeStatKey(normalizedKey)}';
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
        return _humanizeStatKey(normalizedKey);
    }
  }

  String _humanizeStatKey(String key) {
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

  String _equipmentStatValue(EquipmentStat stat) {
    final String valueText = _formatCompactNumber(stat.value);
    final bool isPercent = stat.valueType.trim().toLowerCase() == 'percent';
    final String sign = stat.value >= 0 ? '+' : '';
    return '$sign$valueText${isPercent ? '%' : ''}';
  }

  String _formatCompactNumber(num value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    final String fixed = value.toStringAsFixed(2);
    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  Widget _statsCategory(
    IconData iconData,
    String title,
    List<MapEntry<String, String>> rows,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final children = <Widget>[];
    for (int i = 0; i < rows.length; i++) {
      final key = rows[i].key;
      final label = rows[i].value;
      num value = _summary[key] ?? 0;
      String display;
      if (BuildCalculatorService.percentDisplaySummaryKeys.contains(key)) {
        display = '${value.toInt()}%';
      } else {
        display = value.toInt().toString();
      }
      children.add(_statRow(label, display));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(iconData, color: colorScheme.onSurface, size: 16),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.onSurface.withValues(alpha: 0.24),
                  width: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Column(children: children),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.onSurface.withValues(alpha: 0.14),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 420;
    final bool canGenerateAi = _canUseAiGeneration;
    final bool canSendFeedback = _activeUserId != null;
    IconData statusIcon;
    Color statusColor;
    String statusLabel;
    switch (_aiRecommendationUiState) {
      case _AiRecommendationUiState.loading:
        statusIcon = Icons.sync;
        statusColor = colorScheme.tertiary;
        statusLabel = 'Loading';
        break;
      case _AiRecommendationUiState.success:
        statusIcon = Icons.check_circle_outline;
        statusColor = colorScheme.secondary;
        statusLabel = 'Success';
        break;
      case _AiRecommendationUiState.fallback:
        statusIcon = Icons.rule;
        statusColor = colorScheme.primary;
        statusLabel = 'Fallback';
        break;
      case _AiRecommendationUiState.error:
        statusIcon = Icons.error_outline;
        statusColor = colorScheme.error;
        statusLabel = 'Error';
        break;
    }
    final String sourceLabel = _sourceLabelForAi(_aiRecommendationSource);
    final List<AiRecommendationItem> recommendationItems =
        _effectiveRecommendationItems();
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: <Widget>[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  size: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'AI Recommendations',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              IconButton(
                onPressed: _isAiRecommendationLoading
                    ? null
                    : _generateAiRecommendationsNow,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                visualDensity: VisualDensity.compact,
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 10),
          AiRecommendationsContent(
            aiMessage: _aiRecommendationMessage,
            statusIcon: statusIcon,
            statusColor: statusColor,
            statusLabel: statusLabel,
            sourceLabel: sourceLabel,
            canGenerateAi: canGenerateAi,
            canSendFeedback: canSendFeedback,
            isLoading: _isAiRecommendationLoading,
            onGenerate: _generateAiRecommendationsNow,
            recommendationItems: recommendationItems,
            feedbackByRecommendationId: _feedbackByRecommendationId,
            showAllRecommendations: _showAllRecommendations,
            onToggleShowAll: () {
              _setUiState(() {
                _showAllRecommendations = !_showAllRecommendations;
              });
            },
            onFeedback: (AiRecommendationItem recommendation, String reaction) {
              _onRecommendationFeedback(
                recommendation: recommendation,
                reaction: reaction,
              );
            },
            isSmallScreen: isSmallScreen,
            useCardShadow: true,
            showLoginGenerateHint: !canGenerateAi,
            showLoginFeedbackHint: !canSendFeedback,
          ),
        ],
      ),
    );
  }

  String _savedBuildDisplayName(Map<String, dynamic> build, int index) {
    final String rawName = build['name']?.toString().trim() ?? '';
    if (rawName.isEmpty) {
      return 'Build ${index + 1}';
    }
    return rawName;
  }

  String _sourceLabelForAi(String source) {
    final String normalized = source.trim().toLowerCase();
    switch (normalized) {
      case 'gemini':
        return 'Source: Gemini';
      case 'openai':
        return 'Source: OpenAI';
      case 'groq':
        return 'Source: Groq';
      case 'huggingface':
        return 'Source: HuggingFace';
      case 'fallback':
      case 'rule':
        return 'Source: Fallback rule';
      default:
        return 'Source: Local rule';
    }
  }

  String _savedBuildCodePreview(Map<String, dynamic> build) {
    final String code = BuildPersistenceService.encodeBuildShareCode(build);
    if (code.isEmpty) {
      return 'TB...';
    }
    const int maxVisibleChars = 28;
    if (code.length <= maxVisibleChars) {
      return code;
    }
    return '${code.substring(0, maxVisibleChars)}...';
  }

  String _savedBuildSavedAtPreview(Map<String, dynamic> build) {
    final String savedAtRaw = BuildPersistenceService.readStringValue(
      build['savedAt'],
    ).trim();
    final DateTime? savedAt = savedAtRaw.isEmpty
        ? null
        : DateTime.tryParse(savedAtRaw);
    if (savedAt == null) {
      return 'Saved: -';
    }
    final DateTime localSavedAt = savedAt.toLocal();
    final String day = localSavedAt.day.toString().padLeft(2, '0');
    final String month = localSavedAt.month.toString().padLeft(2, '0');
    final String year = localSavedAt.year.toString();
    final String hour = localSavedAt.hour.toString().padLeft(2, '0');
    final String minute = localSavedAt.minute.toString().padLeft(2, '0');
    return 'Saved: $day/$month/$year $hour:$minute';
  }

  Widget _buildSaveLoadSection() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final int? maxSavedBuilds = _maxSavedBuilds;
    final bool hasSaveLimit = maxSavedBuilds != null;
    final bool canSaveBuild = !hasSaveLimit || !_isSavedBuildLimitReached;
    final List<SaveBuildEntry> savedBuildEntries = _savedBuilds
        .asMap()
        .entries
        .map((MapEntry<int, Map<String, dynamic>> entry) {
          final int index = entry.key;
          final Map<String, dynamic> build = entry.value;
          return SaveBuildEntry(
            name: _savedBuildDisplayName(build, index),
            codeLine: _savedBuildCodePreview(build),
            savedAtLine: _savedBuildSavedAtPreview(build),
            onTap: () => _onLoadBuild(index),
            onLoad: () => _onLoadBuild(index),
            onDelete: () => _onDeleteBuild(index),
            onShare: () => _onCopyBuildShareCode(index),
          );
        })
        .toList(growable: false);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: <Widget>[
              Icon(
                Icons.save_outlined,
                color: colorScheme.onSurface.withValues(alpha: 0.75),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Save / Load Build',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _onRequestClearAll,
                borderRadius: BorderRadius.circular(8),
                child: Ink(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.onSurface.withValues(alpha: 0.24),
                    ),
                  ),
                  child: Icon(
                    Icons.cleaning_services,
                    size: 15,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SaveLoadBuildContent(
            hasSaveLimit: hasSaveLimit,
            canSaveBuild: canSaveBuild,
            saveLimitMessage: BuildSimulatorScreenState._guestSaveLimitMessage,
            buildNameController: _buildNameController,
            onSaveBuild: _onSaveBuild,
            onImportCode: _onRequestImportBuildShareCode,
            savedBuilds: savedBuildEntries,
          ),
        ],
      ),
    );
  }
}


