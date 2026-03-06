part of 'equipment_library_page.dart';

extension _EquipmentLibraryFormatters on _EquipmentLibraryDataViewState {
  Color _equipmentTypeAccentColor(String type) {
    final String normalized = _normalizeEquipmentTypeKey(type);
    switch (normalized) {
      case '1h_sword':
      case '2h_sword':
      case 'katana':
      case 'dagger':
      case 'halberd':
        return const Color(0xFFFFCC80);
      case 'bow':
      case 'bowgun':
      case 'arrow':
        return const Color(0xFF90CAF9);
      case 'staff':
      case 'magic_device':
      case 'ninjutsu_scroll':
        return const Color(0xFFB39DDB);
      case 'shield':
      case 'armor':
        return const Color(0xFFA5D6A7);
      case 'additional':
        return const Color(0xFFFFAB91);
      case 'special':
        return const Color(0xFFFFE082);
      default:
        return const Color(0xFFB0BEC5);
    }
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
  }) {
    final String assetPath = _resolveEquipmentImageAssetPath(item);
    final Color accentColor = _equipmentTypeAccentColor(item.type);

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
  }) {
    final Color accentColor = _equipmentTypeAccentColor(item.type);
    final String typeLabel = _titleCase(item.type);

    return Container(
      width: double.infinity,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF202020), Color(0xFF121212)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF666666)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: height >= 120 ? 56 : 44,
              height: height >= 120 ? 56 : 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.14),
                border: Border.all(color: accentColor.withValues(alpha: 0.42)),
              ),
              child: _buildEquipmentVisual(
                item,
                iconSize: height >= 120 ? 28 : 22,
                imagePadding: height >= 120 ? 10 : 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              typeLabel,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: accentColor,
                fontSize: height >= 120 ? 12 : 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
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
