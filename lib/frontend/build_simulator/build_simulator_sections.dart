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
        ],
      ),
    );
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
              onPressed: _isAiRecommendationLoading
                  ? null
                  : _generateAiRecommendationsNow,
              icon: Icon(
                _isAiRecommendationLoading ? Icons.sync : Icons.auto_awesome,
                size: 14,
              ),
              label: Text(
                _isAiRecommendationLoading ? 'Generating...' : 'Generate',
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

  String _savedSlotLabel(dynamic rawKey) {
    final String key = rawKey?.toString().trim() ?? '';
    if (key.isEmpty) {
      return '-';
    }
    final EquipmentLibraryItem? item = _findEquipmentByKey(key);
    if (item == null) {
      return key;
    }
    return item.name;
  }

  int _savedSummaryValue(Map<String, dynamic> build, String key) {
    final dynamic rawSummary = build['summary'];
    if (rawSummary is! Map) {
      return 0;
    }
    return BuildPersistenceService.readIntValue(rawSummary[key]);
  }

  String _savedBuildEquipmentPreview(Map<String, dynamic> build) {
    return 'Main: ${_savedSlotLabel(build['mainWeaponId'])} | '
        'Sub: ${_savedSlotLabel(build['subWeaponId'])} | '
        'Armor: ${_savedSlotLabel(build['armorId'])} | '
        'Helmet: ${_savedSlotLabel(build['helmetId'])} | '
        'Ring: ${_savedSlotLabel(build['ringId'])}';
  }

  String _savedBuildStatsPreview(Map<String, dynamic> build) {
    return 'ATK ${_savedSummaryValue(build, 'ATK')}  '
        'DEF ${_savedSummaryValue(build, 'DEF')}  '
        'MDEF ${_savedSummaryValue(build, 'MDEF')}  '
        'HP ${_savedSummaryValue(build, 'HP')}  '
        'MP ${_savedSummaryValue(build, 'MP')}';
  }

  Widget _buildSaveLoadSection() {
    final savedWidgets = <Widget>[];
    for (int i = 0; i < _savedBuilds.length; i++) {
      final Map<String, dynamic> build = _savedBuilds[i];
      final String name = _savedBuildDisplayName(build, i);
      savedWidgets.add(
        InkWell(
          onTap: () => _onLoadBuild(i),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF121212).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFFFFFFF).withValues(alpha: 0.18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFFFFFFF),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _onLoadBuild(i),
                      child: const Text('Load', style: TextStyle(fontSize: 11)),
                    ),
                    TextButton(
                      onPressed: () => _onDeleteBuild(i),
                      child: const Text(
                        'X',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  _savedBuildEquipmentPreview(build),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  _savedBuildStatsPreview(build),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFB7FFC6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
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
          _sectionTitle(Icons.save, 'Save / Load Build'),
          const SizedBox(height: 16),
          TextField(
            controller: _buildNameController,
            style: const TextStyle(fontSize: 13, color: Color(0xFFFFFFFF)),
            decoration: InputDecoration(
              hintText: 'Enter build name...',
              hintStyle: const TextStyle(
                fontSize: 12,
                color: Color(0x88FFFFFF),
              ),
              filled: true,
              fillColor: const Color(0xFF000000).withValues(alpha: 0.95),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: const Color(0xFFFFFFFF).withValues(alpha: 0.28),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFFFFFFF)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _gradientButton(
                  label: 'Save Build',
                  onTap: _onSaveBuild,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _gradientButton(
                  label: 'Clear All',
                  isSecondary: true,
                  onTap: _onClearAll,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: SingleChildScrollView(child: Column(children: savedWidgets)),
          ),
        ],
      ),
    );
  }

  Widget _gradientButton({
    required String label,
    required VoidCallback onTap,
    bool isSecondary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: isSecondary
              ? const LinearGradient(
                  colors: [Color(0xFF222222), Color(0xFF111111)],
                )
              : const LinearGradient(
                  colors: [Color(0xFF2A2A2A), Color(0xFF111111)],
                ),
        ),
        child: Center(
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isSecondary ? Colors.white : const Color(0xFFFFFFFF),
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}
