part of 'build_simulator_page.dart';

extension _BuildSimulatorScreenSectionsUI on BuildSimulatorScreenState {
  BoxDecoration _panelDecoration() {
    return BoxDecoration(
      color: const Color(0xFF0D0D0D).withValues(alpha: 0.86),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.16),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.18),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  Widget _sectionTitle(IconData iconData, String title) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.9),
          ),
          child: Icon(iconData, color: const Color(0xFFFFFFFF), size: 17),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
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
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.9),
          ),
          child: const Icon(Icons.assessment, color: Colors.white, size: 17),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Stats Summary',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryModeSwitch() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x44FFFFFF)),
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
            color: isActive ? const Color(0xFF2B2B2B) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive
                  ? const Color(0x66FFFFFF)
                  : const Color(0x22FFFFFF),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : Colors.white70,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF121212).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildEquipmentSlotStatsSection(
            slotLabel: 'Main Weapon',
            item: _findEquipmentByKey(_mainWeaponId),
          ),
          const SizedBox(height: 12),
          _buildEquipmentSlotStatsSection(
            slotLabel: 'Sub Weapon',
            item: _findEquipmentByKey(_subWeaponId),
          ),
          const SizedBox(height: 12),
          _buildEquipmentSlotStatsSection(
            slotLabel: 'Armor',
            item: _findEquipmentByKey(_armorId),
          ),
          const SizedBox(height: 12),
          _buildEquipmentSlotStatsSection(
            slotLabel: 'Additional',
            item: _findEquipmentByKey(_helmetId),
          ),
          const SizedBox(height: 12),
          _buildEquipmentSlotStatsSection(
            slotLabel: 'Special',
            item: _findEquipmentByKey(_ringId),
          ),
          const SizedBox(height: 12),
          _buildGachaStatsSection(),
        ],
      ),
    );
  }

  Widget _buildGachaStatsSection() {
    final List<Map<String, String>> gachaStats = _buildGachaStatsRows();
    final bool hasStats = gachaStats.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Avatar Gacha:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFFE0E0E0),
          ),
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(
            hasStats ? 'Top / Bottom / Accessory' : '-',
            style: TextStyle(
              fontSize: 13,
              color: hasStats ? const Color(0xFF9BC9FF) : Colors.white54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (!hasStats) ...<Widget>[
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.only(left: 14),
            child: Text(
              'No gacha selected',
              style: TextStyle(fontSize: 12, color: Colors.white54),
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
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      color: isNegative
                          ? const Color(0xFFA84B4B)
                          : Colors.white,
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
    required EquipmentLibraryItem? item,
  }) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '$slotLabel:',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFFE0E0E0),
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
                  ? Colors.white54
                  : const Color(0xFF9BC9FF),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (item == null) ...<Widget>[
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.only(left: 14),
            child: Text(
              'No item selected',
              style: TextStyle(fontSize: 12, color: Colors.white54),
            ),
          ),
        ] else ...<Widget>[
          const SizedBox(height: 5),
          if (orderedStats.isEmpty)
            const Padding(
              padding: EdgeInsets.only(left: 14),
              child: Text(
                'No stat data',
                style: TextStyle(fontSize: 12, color: Colors.white54),
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
    final String label = _equipmentStatLabel(stat);
    final String value = _equipmentStatValue(stat);
    final bool isPositive = stat.value >= 0;
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: isPositive ? Colors.white : const Color(0xFFA84B4B),
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
              Icon(iconData, color: const Color(0xFFFFFFFF), size: 16),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0x44FFFFFF), width: 1),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x22FFFFFF), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFFFFFFFF)),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFFFFFFF),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    final bool hasRemoteAi = _isRemoteAiSource(_aiRecommendationSource);
    final bool canGenerateAi = _canUseAiGeneration;
    final children = <Widget>[];
    for (int i = 0; i < _recommendations.length; i++) {
      children.add(
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF151515).withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(10),
            border: const Border(
              left: BorderSide(color: Color(0xFFFFFFFF), width: 3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${i + 1}.',
                style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _recommendations[i],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: _panelDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.lightbulb, 'AI Recommendations'),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                _isAiRecommendationLoading
                    ? Icons.sync
                    : hasRemoteAi
                    ? Icons.psychology
                    : Icons.rule,
                size: 14,
                color: _isAiRecommendationLoading
                    ? const Color(0xFFFFE082)
                    : hasRemoteAi
                    ? const Color(0xFFB7FFC6)
                    : const Color(0xFFFFCCBC),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _aiRecommendationMessage,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: _isAiRecommendationLoading
                        ? const Color(0xFFFFF8E1)
                        : Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.center,
            child: OutlinedButton.icon(
              onPressed: !canGenerateAi || _isAiRecommendationLoading
                  ? null
                  : _generateAiRecommendationsNow,
              icon: Icon(
                !canGenerateAi
                    ? Icons.lock_outline
                    : _isAiRecommendationLoading
                    ? Icons.sync
                    : Icons.auto_awesome,
                size: 14,
              ),
              label: Text(
                !canGenerateAi
                    ? 'Login for AI'
                    : _isAiRecommendationLoading
                    ? 'Generating...'
                    : 'Generate',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0x66FFFFFF)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
              ),
            ),
          ),
          if (!canGenerateAi) ...<Widget>[
            const SizedBox(height: 6),
            const Center(
              child: Text(
                'Login is required for AI Generate.',
                style: TextStyle(fontSize: 11, color: Colors.white54),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Column(children: children),
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
    final int? maxSavedBuilds = _maxSavedBuilds;
    final bool hasSaveLimit = maxSavedBuilds != null;
    final bool canSaveBuild = !hasSaveLimit || !_isSavedBuildLimitReached;
    const int maxVisibleSavedBuilds = 5;
    final int visibleSavedBuildCount =
        _savedBuilds.length > maxVisibleSavedBuilds
        ? maxVisibleSavedBuilds
        : _savedBuilds.length;
    final savedWidgets = <Widget>[];
    for (int i = 0; i < visibleSavedBuildCount; i++) {
      final Map<String, dynamic> build = _savedBuilds[i];
      final String name = _savedBuildDisplayName(build, i);
      savedWidgets.add(
        InkWell(
          onTap: () => _onLoadBuild(i),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF121212).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFFFFF).withValues(alpha: 0.18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFFFFFFF),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  runAlignment: WrapAlignment.center,
                  children: <Widget>[
                    _buildDesktopSavedBuildActionChip(
                      label: 'Load',
                      color: Colors.white,
                      onTap: () => _onLoadBuild(i),
                    ),
                    _buildDesktopSavedBuildActionChip(
                      label: 'Export Code',
                      color: Colors.white70,
                      onTap: () => _onCopyBuildShareCode(i),
                    ),
                    _buildDesktopSavedBuildActionChip(
                      label: 'X',
                      color: Colors.white70,
                      onTap: () => _onDeleteBuild(i),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B0B0B),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0x22FFFFFF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _savedBuildCodePreview(build),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white60,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _savedBuildSavedAtPreview(build),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: <Widget>[
              const Icon(Icons.save_outlined, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Save / Load Build',
                  style: TextStyle(
                    color: Colors.white,
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
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFFFFFFF).withValues(alpha: 0.24),
                    ),
                  ),
                  child: const Icon(
                    Icons.cleaning_services,
                    size: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (hasSaveLimit) ...<Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                BuildSimulatorScreenState._guestSaveLimitMessage,
                style: TextStyle(
                  color: canSaveBuild
                      ? Colors.white70
                      : const Color(0xFFFFB3B3),
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          TextField(
            controller: _buildNameController,
            onSubmitted: (_) => _onSaveBuild(),
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Enter build name...',
              hintStyle: const TextStyle(color: Colors.white54),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              filled: true,
              fillColor: const Color(0xFF0A0A0A),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0x44FFFFFF)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0x77FFFFFF)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: canSaveBuild ? _onSaveBuild : null,
                  icon: const Icon(Icons.save, size: 16),
                  label: const Text('Save Build'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0x66FFFFFF)),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _onRequestImportBuildShareCode,
                  icon: const Icon(Icons.download_for_offline, size: 16),
                  label: const Text('Import Code'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Color(0x44FFFFFF)),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_savedBuilds.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF101010),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0x33FFFFFF)),
              ),
              child: const Text(
                'No saved builds yet.',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            )
          else
            Column(children: savedWidgets),
          if (_savedBuilds.length > visibleSavedBuildCount)
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Text(
                'Showing first 5 builds.',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDesktopSavedBuildActionChip({
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    final bool isEnabled = onTap != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          constraints: const BoxConstraints(minHeight: 36),
          decoration: BoxDecoration(
            color: isEnabled
                ? const Color(0xFF141414)
                : const Color(0xFF111111),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: isEnabled
                  ? const Color(0x66FFFFFF)
                  : const Color(0x22FFFFFF),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isEnabled ? color : Colors.white24,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
