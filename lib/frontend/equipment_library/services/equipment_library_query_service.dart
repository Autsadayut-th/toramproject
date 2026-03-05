import '../models/equipment_library_item.dart';
import '../models/equipment_library_page_slice.dart';

class EquipmentLibraryQueryService {
  const EquipmentLibraryQueryService._();

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
  }) {
    final String normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return items;
    }

    return items
        .where((EquipmentLibraryItem item) {
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
