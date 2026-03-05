import 'equipment_library_item.dart';

class EquipmentLibraryPageSlice {
  const EquipmentLibraryPageSlice({
    required this.currentPage,
    required this.totalPages,
    required this.items,
  });

  final int currentPage;
  final int totalPages;
  final List<EquipmentLibraryItem> items;
}
