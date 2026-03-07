import 'package:flutter/material.dart';

import '../services/avatar_gacha_data_service.dart';

class GachaCard extends StatelessWidget {
  const GachaCard({
    required this.gacha1Stat1,
    required this.gacha1Stat2,
    required this.gacha1Stat3,
    required this.gacha2Stat1,
    required this.gacha2Stat2,
    required this.gacha2Stat3,
    required this.gacha3Stat1,
    required this.gacha3Stat2,
    required this.gacha3Stat3,
    required this.onGacha1Stat1Changed,
    required this.onGacha1Stat2Changed,
    required this.onGacha1Stat3Changed,
    required this.onGacha2Stat1Changed,
    required this.onGacha2Stat2Changed,
    required this.onGacha2Stat3Changed,
    required this.onGacha3Stat1Changed,
    required this.onGacha3Stat2Changed,
    required this.onGacha3Stat3Changed,
    super.key,
  });

  final String gacha1Stat1;
  final String gacha1Stat2;
  final String gacha1Stat3;
  final String gacha2Stat1;
  final String gacha2Stat2;
  final String gacha2Stat3;
  final String gacha3Stat1;
  final String gacha3Stat2;
  final String gacha3Stat3;
  final ValueChanged<String> onGacha1Stat1Changed;
  final ValueChanged<String> onGacha1Stat2Changed;
  final ValueChanged<String> onGacha1Stat3Changed;
  final ValueChanged<String> onGacha2Stat1Changed;
  final ValueChanged<String> onGacha2Stat2Changed;
  final ValueChanged<String> onGacha2Stat3Changed;
  final ValueChanged<String> onGacha3Stat1Changed;
  final ValueChanged<String> onGacha3Stat2Changed;
  final ValueChanged<String> onGacha3Stat3Changed;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AvatarGachaConfig>(
      future: AvatarGachaDataService.load(),
      builder: (BuildContext context, AsyncSnapshot<AvatarGachaConfig> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final AvatarGachaConfig? config = snapshot.data;
        if (config == null) {
          return const Text(
            'Avatar stat pool is unavailable.',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          );
        }

        final List<_GachaSectionData> sections = <_GachaSectionData>[
          _GachaSectionData(
            title: _sectionTitle(config.sections, 0, 'Top'),
            values: <String>[gacha1Stat1, gacha1Stat2, gacha1Stat3],
            callbacks: <ValueChanged<String>>[
              onGacha1Stat1Changed,
              onGacha1Stat2Changed,
              onGacha1Stat3Changed,
            ],
          ),
          _GachaSectionData(
            title: _sectionTitle(config.sections, 1, 'Bottom'),
            values: <String>[gacha2Stat1, gacha2Stat2, gacha2Stat3],
            callbacks: <ValueChanged<String>>[
              onGacha2Stat1Changed,
              onGacha2Stat2Changed,
              onGacha2Stat3Changed,
            ],
          ),
          _GachaSectionData(
            title: _sectionTitle(config.sections, 2, 'Accessory'),
            values: <String>[gacha3Stat1, gacha3Stat2, gacha3Stat3],
            callbacks: <ValueChanged<String>>[
              onGacha3Stat1Changed,
              onGacha3Stat2Changed,
              onGacha3Stat3Changed,
            ],
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Avatar stat pool is loaded from toram-data and applied to the build summary.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white70,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            _buildSectionsLayout(
              context: context,
              config: config,
              sections: sections,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionsLayout({
    required BuildContext context,
    required AvatarGachaConfig config,
    required List<_GachaSectionData> sections,
  }) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool useThreeColumns = constraints.maxWidth >= 1080;
        if (useThreeColumns) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List<Widget>.generate(sections.length, (int index) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == sections.length - 1 ? 0 : 10,
                  ),
                  child: _buildSection(
                    context: context,
                    config: config,
                    section: sections[index],
                  ),
                ),
              );
            }),
          );
        }

        return Column(
          children: List<Widget>.generate(sections.length, (int sectionIndex) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: sectionIndex == sections.length - 1 ? 0 : 12,
              ),
              child: _buildSection(
                context: context,
                config: config,
                section: sections[sectionIndex],
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required AvatarGachaConfig config,
    required _GachaSectionData section,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            section.title,
            style: const TextStyle(
              color: Color(0xFFFFE082),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          ...List<Widget>.generate(section.values.length, (int slotIndex) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: slotIndex == section.values.length - 1 ? 0 : 10,
              ),
              child: _buildSlotField(
                context: context,
                config: config,
                section: section,
                slotIndex: slotIndex,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSlotField({
    required BuildContext context,
    required AvatarGachaConfig config,
    required _GachaSectionData section,
    required int slotIndex,
  }) {
    final String currentValue = section.values[slotIndex];
    final bool isThirdSlot = slotIndex == 2;
    final bool requiresSecondSlot = config.slot3RequiresSlot2 && isThirdSlot;
    final bool isEnabled =
        !requiresSecondSlot ||
        section.values[1].trim().isNotEmpty ||
        currentValue.trim().isNotEmpty;

    final Set<String> blockedStatKeys = <String>{};
    if (config.noDuplicateStatInSameSection) {
      for (int i = 0; i < section.values.length; i++) {
        if (i == slotIndex) {
          continue;
        }
        final String? statKey = AvatarGachaDataService.decodeSelectionStatKey(
          section.values[i],
        );
        if (statKey == null || statKey.isEmpty) {
          continue;
        }
        blockedStatKeys.add(statKey);
      }
    }

    final List<AvatarStatOption> filteredOptions = config.options
        .where(
          (AvatarStatOption option) =>
              option.id == currentValue ||
              !blockedStatKeys.contains(option.statKey),
        )
        .toList(growable: false);
    String selectedLabel = 'None';
    if (currentValue.isNotEmpty) {
      for (final AvatarStatOption option in config.options) {
        if (option.id == currentValue) {
          selectedLabel = option.label;
          break;
        }
      }
      if (selectedLabel == 'None') {
        selectedLabel = currentValue;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Slot ${slotIndex + 1}',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: !isEnabled
              ? null
              : () async {
                  final String? nextValue = await _openOptionPicker(
                    context: context,
                    title: '${section.title} - Slot ${slotIndex + 1}',
                    currentValue: currentValue,
                    options: filteredOptions,
                  );
                  if (nextValue == null || !context.mounted) {
                    return;
                  }
                  section.callbacks[slotIndex](nextValue);
                  if (slotIndex == 1 &&
                      nextValue.isEmpty &&
                      section.values[2].isNotEmpty) {
                    section.callbacks[2]('');
                  }
                },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: isEnabled
                  ? const Color(0xFF0A0A0A)
                  : const Color(0xFF0A0A0A).withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isEnabled
                    ? const Color(0x33FFFFFF)
                    : const Color(0x22FFFFFF),
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    selectedLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: currentValue.isEmpty
                          ? Colors.white70
                          : Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_drop_down,
                  color: isEnabled ? Colors.white70 : Colors.white24,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (requiresSecondSlot && !isEnabled)
          const Padding(
            padding: EdgeInsets.only(top: 4, left: 2),
            child: Text(
              'Unlock by choosing Slot 2 first.',
              style: TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ),
      ],
    );
  }

  Future<String?> _openOptionPicker({
    required BuildContext context,
    required String title,
    required String currentValue,
    required List<AvatarStatOption> options,
  }) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String query = '';
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(VoidCallback fn) setState) {
                final String normalizedQuery = query.trim().toLowerCase();
                final bool showNone =
                    normalizedQuery.isEmpty ||
                    'none'.contains(normalizedQuery) ||
                    'clear'.contains(normalizedQuery);
                final List<AvatarStatOption> visibleOptions = options
                    .where((AvatarStatOption option) {
                      return _optionMatchesQuery(option, normalizedQuery);
                    })
                    .toList(growable: false);

                return Dialog(
                  backgroundColor: const Color(0xFF0D0D0D),
                  insetPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0x33FFFFFF)),
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 560,
                      maxHeight: 560,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 12, 8, 6),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white70,
                                ),
                                tooltip: 'Close',
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                          child: TextField(
                            autofocus: true,
                            onChanged: (String value) {
                              setState(() {
                                query = value;
                              });
                            },
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search gacha stat...',
                              hintStyle: const TextStyle(color: Colors.white54),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.white70,
                              ),
                              filled: true,
                              fillColor: const Color(0xFF131313),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0x33FFFFFF),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0x33FFFFFF),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0x66FFE082),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            children: <Widget>[
                              if (showNone)
                                _buildOptionTile(
                                  title: 'None',
                                  subtitle: 'Clear this slot',
                                  selected: currentValue.isEmpty,
                                  onTap: () => Navigator.of(context).pop(''),
                                ),
                              ...visibleOptions.map((AvatarStatOption option) {
                                return _buildOptionTile(
                                  title: option.label,
                                  subtitle: option.statKey,
                                  selected: option.id == currentValue,
                                  onTap: () =>
                                      Navigator.of(context).pop(option.id),
                                );
                              }),
                              if (!showNone && visibleOptions.isEmpty)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF151515),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0x33FFFFFF),
                                    ),
                                  ),
                                  child: const Text(
                                    'No results found.',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
        );
      },
    );
  }

  bool _optionMatchesQuery(AvatarStatOption option, String query) {
    if (query.isEmpty) {
      return true;
    }
    final String label = option.label.toLowerCase();
    final String statKey = option.statKey.toLowerCase();
    final String displayStat = option.displayStat.toLowerCase();
    final String id = option.id.toLowerCase();
    return label.contains(query) ||
        displayStat.contains(query) ||
        statKey.contains(query) ||
        id.contains(query);
  }

  Widget _buildOptionTile({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1F1F1F) : const Color(0xFF151515),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? const Color(0x66FFE082) : const Color(0x33FFFFFF),
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      color: selected ? const Color(0xFFFFE082) : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check, color: Color(0xFFFFE082), size: 16),
          ],
        ),
      ),
    );
  }

  static String _titleCase(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    return trimmed[0].toUpperCase() + trimmed.substring(1).toLowerCase();
  }

  static String _sectionTitle(
    List<String> sections,
    int index,
    String fallback,
  ) {
    if (index < 0 || index >= sections.length) {
      return fallback;
    }
    return _titleCase(sections[index]);
  }
}

class _GachaSectionData {
  const _GachaSectionData({
    required this.title,
    required this.values,
    required this.callbacks,
  });

  final String title;
  final List<String> values;
  final List<ValueChanged<String>> callbacks;
}
