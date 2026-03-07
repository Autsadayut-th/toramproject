import 'package:flutter/material.dart';

import '../shared/app_mobile_bottom_navigation_bar.dart';
import '../shared/app_navigation_drawer.dart';
import 'models/equipment_library_item.dart';
import 'models/equipment_library_page_slice.dart';
import 'repository/equipment_library_repository.dart';
import 'services/equipment_library_query_service.dart';

part 'equipment_library_data_view.dart';
part 'equipment_library_details_sheet.dart';
part 'equipment_library_grid.dart';
part 'equipment_library_pagination.dart';
part 'equipment_library_formatters.dart';

const Color _libraryWarmAccent = Color(0xFFD8B36A);
const Color _libraryCoolAccent = Color(0xFF5D7283);

class EquipmentLibraryScreen extends StatelessWidget {
  const EquipmentLibraryScreen({
    super.key,
    this.pickMode = false,
    this.initialCategory,
    this.allowedCategories,
    this.allowedTypes,
    this.title = 'Equipment Library',
    this.onNavigate,
  });

  final bool pickMode;
  final String? initialCategory;
  final List<String>? allowedCategories;
  final List<String>? allowedTypes;
  final String title;
  final ValueChanged<AppNavigationPage>? onNavigate;

  static Future<String?> pickItemKey(
    BuildContext context, {
    required String initialCategory,
    required String title,
    List<String>? allowedCategories,
    List<String>? allowedTypes,
  }) async {
    final EquipmentLibraryItem? selected = await Navigator.of(context)
        .push<EquipmentLibraryItem>(
          MaterialPageRoute<EquipmentLibraryItem>(
            builder: (_) => EquipmentLibraryScreen(
              pickMode: true,
              initialCategory: initialCategory,
              allowedCategories: allowedCategories,
              allowedTypes: allowedTypes,
              title: title,
            ),
          ),
        );
    return selected?.key;
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 1024;
    final bool isEmbeddedInShell = !pickMode && onNavigate != null;
    final bool showMobileNav = !pickMode && !isEmbeddedInShell && isMobile;
    final bool showGlobalMenu = !pickMode && !isEmbeddedInShell && !isMobile;

    void onSelectMobileNav(AppNavigationPage page) {
      if (page == AppNavigationPage.equipment) {
        return;
      }
      onNavigate?.call(page);
    }

    void onSelectDrawerPage(AppNavigationPage page) {
      Navigator.of(context).pop();
      if (page != AppNavigationPage.equipment) {
        onNavigate?.call(page);
      }
    }

    final Widget content = _EquipmentLibraryDataView(
      pickMode: pickMode,
      initialCategory: initialCategory,
      allowedCategories: allowedCategories,
      allowedTypes: allowedTypes,
    );

    if (isEmbeddedInShell) {
      return content;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      drawer: showGlobalMenu
          ? AppNavigationDrawer(
              currentPage: AppNavigationPage.equipment,
              onOpenBuild: () => onSelectDrawerPage(AppNavigationPage.build),
              onOpenEquipment: () =>
                  onSelectDrawerPage(AppNavigationPage.equipment),
              onOpenSkill: () => onSelectDrawerPage(AppNavigationPage.skill),
              onOpenSaved: () => onSelectDrawerPage(AppNavigationPage.saved),
              onOpenCompare: () =>
                  onSelectDrawerPage(AppNavigationPage.compare),
              onOpenSettings: () =>
                  onSelectDrawerPage(AppNavigationPage.settings),
            )
          : null,
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: !showGlobalMenu && !showMobileNav,
        leading: showGlobalMenu
            ? Builder(
                builder: (BuildContext context) => TextButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  child: const Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: content,
      bottomNavigationBar: showMobileNav
          ? AppMobileBottomNavigationBar(
              currentPage: AppNavigationPage.equipment,
              onSelect: onSelectMobileNav,
            )
          : null,
    );
  }
}
