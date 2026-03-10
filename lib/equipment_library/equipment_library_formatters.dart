part of 'equipment_library_page.dart';

extension _EquipmentLibraryFormatters on _EquipmentLibraryDataViewState {
  Color _equipmentTypeAccentColor(String type) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String normalized = _normalizeEquipmentTypeKey(type);
    switch (normalized) {
      case '1h_sword':
      case '2h_sword':
      case 'katana':
      case 'dagger':
      case 'halberd':
        return colorScheme.tertiary;
      case 'bow':
      case 'bowgun':
      case 'arrow':
        return colorScheme.primary;
      case 'staff':
      case 'magic_device':
      case 'ninjutsu_scroll':
        return colorScheme.secondary;
      case 'shield':
      case 'armor':
        return colorScheme.primaryContainer;
      case 'additional':
        return colorScheme.tertiaryContainer;
      case 'special':
        return colorScheme.secondaryContainer;
      default:
        return colorScheme.onSurface.withValues(alpha: 0.75);
    }
  }

  Color _crystalAccentColor(String colorKey) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    switch (colorKey) {
      case 'red':
        return colorScheme.error;
      case 'green':
        return colorScheme.tertiary;
      case 'yellow':
        return colorScheme.primary;
      case 'purple':
        return colorScheme.secondary;
      case 'blue':
      default:
        return colorScheme.primary;
    }
  }

  String _crystalColorKey(EquipmentLibraryItem item) {
    final String normalized = item.color.trim().toLowerCase();
    switch (normalized) {
      case 'red':
      case 'green':
      case 'blue':
      case 'yellow':
      case 'purple':
        return normalized;
      default:
        return 'blue';
    }
  }

  Color _itemAccentColor({
    required EquipmentLibraryItem item,
    required String activeCategory,
  }) {
    if (activeCategory.trim().toLowerCase() == 'crystal') {
      return _crystalAccentColor(_crystalColorKey(item));
    }
    return _equipmentTypeAccentColor(item.type);
  }

  String _itemVisualAssetPath({
    required EquipmentLibraryItem item,
    required String activeCategory,
  }) {
    if (activeCategory.trim().toLowerCase() == 'crystal') {
      return 'assets/data/icon/${_crystalColorKey(item)}_crysta.png';
    }
    return _resolveEquipmentImageAssetPath(item);
  }

  String _itemTypeDisplayLabel({
    required EquipmentLibraryItem item,
    required String activeCategory,
  }) {
    if (activeCategory.trim().toLowerCase() != 'crystal') {
      return _titleCase(item.type);
    }
    final String colorLabel = _titleCase(_crystalColorKey(item));
    final String slotLabel = _titleCase(item.type);
    if (slotLabel.isEmpty) {
      return '$colorLabel Crystal';
    }
    return '$colorLabel Crystal - $slotLabel';
  }

  String _equipmentTypeAssetPath(EquipmentLibraryItem item) {
    String normalized = _normalizeEquipmentTypeKey(item.type);
    if (normalized == 'armor') {
      final String key = item.key.trim().toLowerCase();
      if (key.contains('_special_')) {
        normalized = 'special';
      } else if (key.contains('_additional_')) {
        normalized = 'additional';
      }
    }

    return _equipmentTypeAssetPathForTypeKey(normalized);
  }

  String _equipmentTypeAssetPathForTypeKey(String typeKey) {
    switch (typeKey) {
      case '1h_sword':
        return 'assets/data/icon/1h_sword_icon.png';
      case '2h_sword':
        return 'assets/data/icon/2h_sword_icon.png';
      case 'katana':
        return 'assets/data/icon/katana_icon.png';
      case 'dagger':
        return 'assets/data/icon/dagger_icon.png';
      case 'bow':
        return 'assets/data/icon/bow_icon.png';
      case 'bowgun':
        return 'assets/data/icon/bowgun_icon.png';
      case 'halberd':
        return 'assets/data/icon/halberd_icon.png';
      case 'knuckles':
        return 'assets/data/icon/knuckles_icon.png';
      case 'staff':
        return 'assets/data/icon/staff_icon.png';
      case 'magic_device':
        return 'assets/data/icon/magic_device_icon.png';
      case 'arrow':
        return 'assets/data/icon/arrow_icon.png';
      case 'shield':
        return 'assets/data/icon/shield_icon.png';
      case 'ninjutsu_scroll':
        return 'assets/data/icon/ninjut_suscroll_icon.png';
      case 'armor':
        return 'assets/data/icon/armor_icon.png';
      case 'additional':
        return 'assets/data/icon/add_icon.png';
      case 'special':
        return 'assets/data/icon/special_ring_icon.png';
      default:
        return '';
    }
  }

  String _normalizeEquipmentTypeKey(String type) {
    return EquipmentLibraryQueryService.normalizeTypeKey(type);
  }

  String _normalizeAssetPath(String raw) {
    String path = raw.trim().replaceAll('\\', '/');
    if (path.startsWith('./')) {
      path = path.substring(2);
    }
    if (path.startsWith('/assets/')) {
      path = path.substring(1);
    }
    if (path.startsWith('assets/assets/')) {
      path = path.replaceFirst('assets/', '');
    }
    if (path.startsWith('data/')) {
      return 'assets/$path';
    }
    return path;
  }

  String _resolveEquipmentImageAssetPath(EquipmentLibraryItem item) {
    final String imageAssetPath = _normalizeAssetPath(item.imageAssetPath);
    if (imageAssetPath.isNotEmpty) {
      if (imageAssetPath.startsWith('assets/')) {
        return imageAssetPath;
      }
      if (imageAssetPath.startsWith('data/')) {
        return 'assets/$imageAssetPath';
      }
      return imageAssetPath;
    }
    return _equipmentTypeAssetPath(item);
  }

  Widget _buildEquipmentVisual(
    EquipmentLibraryItem item, {
    required double iconSize,
    double imagePadding = 6,
    String? overrideAssetPath,
    Color? accentColorOverride,
  }) {
    final String assetPath =
        overrideAssetPath ?? _resolveEquipmentImageAssetPath(item);
    final Color accentColor =
        accentColorOverride ?? _equipmentTypeAccentColor(item.type);

    if (assetPath.isEmpty) {
      return _buildEquipmentTextFallback(
        item,
        accentColor: accentColor,
        fontSize: iconSize * 0.42,
      );
    }

    return Padding(
      padding: EdgeInsets.all(imagePadding),
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return _buildEquipmentTextFallback(
            item,
            accentColor: accentColor,
            fontSize: iconSize * 0.42,
          );
        },
      ),
    );
  }

  Widget _buildEquipmentTextFallback(
    EquipmentLibraryItem item, {
    required Color accentColor,
    required double fontSize,
  }) {
    final String label = _equipmentTypeFallbackLabel(item.type);
    return Center(
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: accentColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  String _equipmentTypeFallbackLabel(String type) {
    switch (_normalizeEquipmentTypeKey(type)) {
      case '1h_sword':
        return '1H';
      case '2h_sword':
        return '2H';
      case 'magic_device':
        return 'MD';
      case 'ninjutsu_scroll':
        return 'NS';
      default:
        final String title = _titleCase(type);
        if (title.isEmpty) {
          return '?';
        }
        return title
            .split(' ')
            .where((String part) => part.isNotEmpty)
            .take(2)
            .map((String part) => part[0].toUpperCase())
            .join();
    }
  }

  Widget _buildEquipmentImageBox(
    EquipmentLibraryItem item, {
    required double height,
    required String activeCategory,
  }) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color accentColor = _itemAccentColor(
      item: item,
      activeCategory: activeCategory,
    );
    final double accentLuminance = accentColor.computeLuminance();
    final Color contrastAccent = isLight && accentLuminance > 0.62
        ? (Color.lerp(accentColor, colorScheme.primary, 0.62) ??
              colorScheme.primary)
        : accentColor;
    final Color outerFrameBorderColor =
        Color.lerp(
          colorScheme.outline.withValues(alpha: isLight ? 0.74 : 0.55),
          contrastAccent,
          isLight ? 0.44 : 0.58,
        ) ??
        contrastAccent.withValues(alpha: isLight ? 0.66 : 0.56);
    final Color innerFrameBorderColor =
        Color.lerp(
          colorScheme.outline.withValues(alpha: isLight ? 0.8 : 0.62),
          contrastAccent,
          isLight ? 0.68 : 0.78,
        ) ??
        contrastAccent.withValues(alpha: isLight ? 0.76 : 0.64);
    final Color innerFrameFillColor = contrastAccent.withValues(
      alpha: isLight ? 0.26 : 0.18,
    );
    final String typeLabel = _itemTypeDisplayLabel(
      item: item,
      activeCategory: activeCategory,
    );

    return Container(
      width: double.infinity,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colorScheme.surfaceContainerHigh,
            colorScheme.surfaceContainerHighest,
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: height >= 120 ? 60 : 48,
              height: height >= 120 ? 60 : 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surfaceContainerHighest,
                border: Border.all(color: outerFrameBorderColor, width: 1.45),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: colorScheme.onSurface.withValues(
                      alpha: isLight ? 0.10 : 0.14,
                    ),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: innerFrameFillColor,
                    border: Border.all(
                      color: innerFrameBorderColor,
                      width: 1.2,
                    ),
                  ),
                  child: _buildEquipmentVisual(
                    item,
                    iconSize: height >= 120 ? 28 : 22,
                    imagePadding: height >= 120 ? 10 : 8,
                    overrideAssetPath: _itemVisualAssetPath(
                      item: item,
                      activeCategory: activeCategory,
                    ),
                    accentColorOverride: contrastAccent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              typeLabel,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: contrastAccent,
                fontSize: height >= 120 ? 12 : 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _elementLabelsFromStats(List<EquipmentStat> stats) {
    const List<String> elementOrder = <String>[
      'fire',
      'water',
      'wind',
      'earth',
      'light',
      'dark',
      'neutral',
    ];
    final Set<String> seen = <String>{};
    final List<String> keys = <String>[];

    for (final EquipmentStat stat in stats) {
      if (stat.value <= 0) {
        continue;
      }
      final String key = stat.statKey.trim().toLowerCase();
      if (!key.endsWith('_element')) {
        continue;
      }
      final String elementKey = key.substring(
        0,
        key.length - '_element'.length,
      );
      if (elementKey.isEmpty) {
        continue;
      }
      if (seen.add(elementKey)) {
        keys.add(elementKey);
      }
    }

    keys.sort((String a, String b) {
      final int ia = elementOrder.indexOf(a);
      final int ib = elementOrder.indexOf(b);
      if (ia == -1 && ib == -1) {
        return a.compareTo(b);
      }
      if (ia == -1) {
        return 1;
      }
      if (ib == -1) {
        return -1;
      }
      return ia.compareTo(ib);
    });

    return keys.map(_titleCase).toList(growable: false);
  }

  String _formatStatValue(EquipmentStat stat) {
    final String sign = stat.value > 0 ? '+' : '';
    final String suffix = stat.valueType == 'percent' ? '%' : '';
    return '$sign${_formatNumber(stat.value)}$suffix';
  }

  String _formatNumber(num value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    final String fixed = value.toStringAsFixed(2);
    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  String _titleCase(String input) {
    return input
        .split('_')
        .where((String part) => part.isNotEmpty)
        .map(
          (String part) =>
              part[0].toUpperCase() + part.substring(1).toLowerCase(),
        )
        .join(' ');
  }
}
