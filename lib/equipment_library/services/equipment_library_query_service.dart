import '../models/equipment_library_item.dart';
import '../models/equipment_library_page_slice.dart';

class EquipmentLibraryQueryService {
  const EquipmentLibraryQueryService._();

  static const Set<String> _nameSearchModes = <String>{'name', 'n'};
  static const Set<String> _keySearchModes = <String>{'key', 'k'};
  static const Set<String> _typeSearchModes = <String>{'type', 't'};
  static const Set<String> _colorSearchModes = <String>{'color', 'c'};
  static const Set<String> _statSearchModes = <String>{
    'stat',
    'stats',
    'stat_key',
    'statkey',
    's',
  };

  static String normalizeTypeKey(String value) {
    String normalized = value
        .trim()
        .toLowerCase()
        .replaceAll('&', ' and ')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    switch (normalized) {
      case 'one_handed_sword':
      case '1h':
        return '1h_sword';
      case 'two_handed_sword':
      case '2h':
        return '2h_sword';
      case 'magicdevice':
        return 'magic_device';
      case 'ninjut_suscroll':
      case 'ninjutsu_suscroll':
        return 'ninjutsu_scroll';
      default:
        return normalized;
    }
  }

  static List<String> availableCategories({
    required List<String> repositoryCategories,
    required Map<String, List<EquipmentLibraryItem>> allCategories,
    Set<String>? allowedCategories,
  }) {
    return repositoryCategories
        .where((String category) {
          if (!allCategories.containsKey(category)) {
            return false;
          }
          return allowedCategories == null ||
              allowedCategories.contains(category);
        })
        .toList(growable: false);
  }

  static String resolveActiveCategory({
    required String? selectedCategory,
    required List<String> categories,
  }) {
    if (selectedCategory != null && categories.contains(selectedCategory)) {
      return selectedCategory;
    }
    return categories.isNotEmpty ? categories.first : '';
  }

  static List<EquipmentLibraryItem> filterItems({
    required List<EquipmentLibraryItem> items,
    required String query,
    Set<String>? allowedTypes,
    String Function(EquipmentLibraryItem item)? typeKeyResolver,
  }) {
    final Set<String>? normalizedAllowedTypes = allowedTypes
        ?.map(normalizeTypeKey)
        .where((String value) => value.isNotEmpty)
        .toSet();

    final ({String mode, String term}) parsedQuery = _parseQuery(query);
    final String normalizedQuery = parsedQuery.term;
    if (normalizedQuery.isEmpty &&
        (normalizedAllowedTypes == null || normalizedAllowedTypes.isEmpty)) {
      return items;
    }

    return items
        .where((EquipmentLibraryItem item) {
          final String typeKey = typeKeyResolver?.call(item) ?? item.type;
          final String normalizedItemType = normalizeTypeKey(typeKey);
          if (normalizedAllowedTypes != null &&
              normalizedAllowedTypes.isNotEmpty &&
              !normalizedAllowedTypes.contains(normalizedItemType)) {
            return false;
          }
          if (normalizedQuery.isEmpty) {
            return true;
          }
          switch (parsedQuery.mode) {
            case 'name':
              return item.name.toLowerCase().contains(normalizedQuery);
            case 'key':
              return item.key.toLowerCase().contains(normalizedQuery);
            case 'type':
              return item.type.toLowerCase().contains(normalizedQuery);
            case 'color':
              return item.color.toLowerCase().contains(normalizedQuery);
            case 'stat':
              return _containsStatKey(item: item, normalizedQuery: normalizedQuery);
            default:
              if (item.name.toLowerCase().contains(normalizedQuery) ||
                  item.key.toLowerCase().contains(normalizedQuery) ||
                  item.type.toLowerCase().contains(normalizedQuery) ||
                  item.color.toLowerCase().contains(normalizedQuery)) {
                return true;
              }
              // Let the main search match stat_key too (ex: "atk", "critical_rate").
              return _containsStatKey(item: item, normalizedQuery: normalizedQuery);
          }
        })
        .toList(growable: false);
  }

  static bool _containsStatKey({
    required EquipmentLibraryItem item,
    required String normalizedQuery,
  }) {
    final List<String> queryTokens = _tokenizeStatSearch(normalizedQuery);
    if (queryTokens.isEmpty) {
      return false;
    }

    return item.stats.any((EquipmentStat stat) {
      final String statKey = _normalizeStatSearchText(stat.statKey);
      if (statKey.isEmpty) {
        return false;
      }

      final List<String> statTokens = statKey
          .split('_')
          .where((String token) => token.isNotEmpty)
          .toList(growable: false);
      if (statTokens.isEmpty) {
        return false;
      }

      // Token-based match prevents false positives like "agi" matching "magic".
      final bool tokenMatch = queryTokens.every((String queryToken) {
        return statTokens.any((String statToken) {
          return statToken == queryToken || statToken.startsWith(queryToken);
        });
      });
      if (tokenMatch) {
        return true;
      }

      if (queryTokens.length > 1) {
        final String compactQuery = queryTokens.join('_');
        return statKey.contains(compactQuery);
      }
      return false;
    });
  }

  static List<String> _tokenizeStatSearch(String value) {
    final String normalized = _normalizeStatSearchText(value);
    if (normalized.isEmpty) {
      return const <String>[];
    }
    return normalized
        .split('_')
        .where((String token) => token.isNotEmpty)
        .toList(growable: false);
  }

  static String _normalizeStatSearchText(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  static ({String mode, String term}) _parseQuery(String query) {
    final String trimmedQuery = query.trim().toLowerCase();
    if (trimmedQuery.isEmpty || !trimmedQuery.startsWith('@')) {
      return (mode: 'all', term: trimmedQuery);
    }

    final RegExpMatch? match = RegExp(r'^@([a-z_]+)\s*(.*)$').firstMatch(
      trimmedQuery,
    );
    if (match == null) {
      return (mode: 'all', term: trimmedQuery.substring(1).trim());
    }

    final String rawMode = (match.group(1) ?? '').trim();
    final String normalizedTerm = (match.group(2) ?? '').trim();
    if (rawMode.isEmpty) {
      return (mode: 'all', term: normalizedTerm);
    }
    if (_nameSearchModes.contains(rawMode)) {
      return (mode: 'name', term: normalizedTerm);
    }
    if (_keySearchModes.contains(rawMode)) {
      return (mode: 'key', term: normalizedTerm);
    }
    if (_typeSearchModes.contains(rawMode)) {
      return (mode: 'type', term: normalizedTerm);
    }
    if (_colorSearchModes.contains(rawMode)) {
      return (mode: 'color', term: normalizedTerm);
    }
    if (_statSearchModes.contains(rawMode)) {
      return (mode: 'stat', term: normalizedTerm);
    }
    return (mode: 'all', term: normalizedTerm);
  }

  static EquipmentLibraryPageSlice paginateItems({
    required List<EquipmentLibraryItem> filteredItems,
    required int currentPage,
    required int itemsPerPage,
  }) {
    final int totalPages = filteredItems.isEmpty
        ? 1
        : ((filteredItems.length + itemsPerPage - 1) / itemsPerPage).floor();
    final int safeCurrentPage = currentPage.clamp(1, totalPages).toInt();

    if (filteredItems.isEmpty) {
      return const EquipmentLibraryPageSlice(
        currentPage: 1,
        totalPages: 1,
        items: <EquipmentLibraryItem>[],
      );
    }

    final int startIndex = (safeCurrentPage - 1) * itemsPerPage;
    final int endIndex = (startIndex + itemsPerPage)
        .clamp(0, filteredItems.length)
        .toInt();
    return EquipmentLibraryPageSlice(
      currentPage: safeCurrentPage,
      totalPages: totalPages,
      items: filteredItems.sublist(startIndex, endIndex),
    );
  }
}
