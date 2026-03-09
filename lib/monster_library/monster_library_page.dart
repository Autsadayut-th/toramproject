import 'package:flutter/material.dart';

import 'models/monster_library_item.dart';
import 'repository/monster_library_repository.dart';

part 'monster_library_data_view.dart';
part 'monster_library_details_sheet.dart';
part 'monster_library_grid.dart';
part 'monster_library_pagination.dart';

class MonsterLibraryPage extends StatelessWidget {
  const MonsterLibraryPage({super.key, this.title = 'Monster Library'});

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
      body: const _MonsterLibraryDataView(),
    );
  }
}
