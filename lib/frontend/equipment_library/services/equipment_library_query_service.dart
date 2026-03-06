import '../models/equipment_library_item.dart';
import '../models/equipment_library_page_slice.dart';

class EquipmentLibraryQueryService {
  const EquipmentLibraryQueryService._();

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
  }) {
    final Set<String>? normalizedAllowedTypes = allowedTypes
        ?.map(normalizeTypeKey)
        .where((String value) => value.isNotEmpty)
        .toSet();

    final String normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty &&
        (normalizedAllowedTypes == null || normalizedAllowedTypes.isEmpty)) {
      return items;
    }

    return items
        .where((EquipmentLibraryItem item) {
          final String normalizedItemType = normalizeTypeKey(item.type);
          if (normalizedAllowedTypes != null &&
              normalizedAllowedTypes.isNotEmpty &&
              !normalizedAllowedTypes.contains(normalizedItemType)) {
            return false;
          }
          if (normalizedQuery.isEmpty) {
            return true;
          }
          return item.name.toLowerCase().contains(normalizedQuery) ||
              item.key.toLowerCase().contains(normalizedQuery) ||
              item.type.toLowerCase().contains(normalizedQuery);
        })
        .toList(growable: false);
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
