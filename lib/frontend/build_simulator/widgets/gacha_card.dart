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
            ...List<Widget>.generate(sections.length, (int sectionIndex) {
              final _GachaSectionData section = sections[sectionIndex];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: sectionIndex == sections.length - 1 ? 0 : 12,
                ),
                child: _buildSection(
                  config: config,
                  section: section,
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildSection({
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
              option.id == currentValue || !blockedStatKeys.contains(option.statKey),
        )
        .toList(growable: false);

    return DropdownButtonFormField<String>(
      initialValue: currentValue.isEmpty ? '' : currentValue,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Slot ${slotIndex + 1}',
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
        helperText: requiresSecondSlot && !isEnabled
            ? 'Unlock by choosing Slot 2 first.'
            : null,
        helperStyle: const TextStyle(color: Colors.white54, fontSize: 10),
        filled: true,
        fillColor: const Color(0xFF0A0A0A),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0x33FFFFFF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0x66FFE082)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0x22FFFFFF)),
        ),
      ),
      dropdownColor: const Color(0xFF111111),
      style: const TextStyle(color: Colors.white, fontSize: 12),
      items: <DropdownMenuItem<String>>[
        const DropdownMenuItem<String>(
          value: '',
          child: Text(
            'None',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white70),
          ),
        ),
        ...filteredOptions.map(
          (AvatarStatOption option) => DropdownMenuItem<String>(
            value: option.id,
            child: Text(
              option.label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
      onChanged: isEnabled
          ? (String? value) {
              final String nextValue = value ?? '';
              section.callbacks[slotIndex](nextValue);
              if (slotIndex == 1 && nextValue.isEmpty && section.values[2].isNotEmpty) {
                section.callbacks[2]('');
              }
            }
          : null,
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
