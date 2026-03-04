part of 'equipment_library_page.dart';

extension _EquipmentLibraryFormatters on _EquipmentLibraryDataViewState {
  Widget _buildEquipmentImagePlaceholderContent() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.image_outlined, color: Colors.white38, size: 24),
        SizedBox(height: 4),
        Text('Image', style: TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }

  Widget _buildEquipmentImageBox(
    EquipmentLibraryItem item, {
    required double height,
  }) {
    final String imageAssetPath = item.imageAssetPath;
    return Container(
      width: double.infinity,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF666666)),
      ),
      child: imageAssetPath.isEmpty
          ? _buildEquipmentImagePlaceholderContent()
          : Image.asset(
              imageAssetPath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  _buildEquipmentImagePlaceholderContent(),
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
