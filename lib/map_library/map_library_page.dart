import 'package:flutter/material.dart';

import 'models/map_library_item.dart';
import 'repository/map_library_repository.dart';

part 'map_library_data_view.dart';
part 'map_library_details_sheet.dart';
part 'map_library_grid.dart';
part 'map_library_pagination.dart';

class MapLibraryPage extends StatelessWidget {
  const MapLibraryPage({super.key, this.title = 'Map Library'});

  final String title;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        title: Text(title),
      ),
      body: const _MapLibraryDataView(),
    );
  }
}
