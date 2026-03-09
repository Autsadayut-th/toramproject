part of 'equipment_slot_selector.dart';

class _InlineSearchModeOption {
  const _InlineSearchModeOption({required this.token, required this.label});

  final String token;
  final String label;
}

class _CrystalPickerDialog extends StatefulWidget {
  const _CrystalPickerDialog({
    required this.title,
    required this.entries,
    required this.selectedKey,
  });

  final String title;
  final List<CrystalLibraryEntry> entries;
  final String? selectedKey;

  @override
  State<_CrystalPickerDialog> createState() => _CrystalPickerDialogState();
}

class _CrystalPickerDialogState extends State<_CrystalPickerDialog> {
  String _query = '';
  String? _categoryFilter;

  List<String> get _categories {
    final Set<String> values = widget.entries
        .map((CrystalLibraryEntry entry) => entry.category.trim().toLowerCase())
        .where((String value) => value.isNotEmpty)
        .toSet();
    final List<String> categories = values.toList(growable: false)..sort();
    return categories;
  }

  List<CrystalLibraryEntry> get _filteredEntries {
    final String normalizedQuery = _query.trim().toLowerCase();
    return widget.entries
        .where((CrystalLibraryEntry entry) {
          if (_categoryFilter != null && entry.category != _categoryFilter) {
            return false;
          }
          return _crystalEntryMatchesQuery(entry, normalizedQuery);
        })
        .toList(growable: false);
  }

  String _categoryLabel(String category) {
    if (category.isEmpty) {
      return '-';
    }
    return category[0].toUpperCase() + category.substring(1).toLowerCase();
  }

  Color _categoryAccentColor(String category) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    switch (category.trim().toLowerCase()) {
      case 'weapon':
        return colorScheme.error;
      case 'armor':
        return colorScheme.tertiary;
      case 'additional':
        return colorScheme.primary;
      case 'special':
        return colorScheme.secondary;
      case 'normal':
        return colorScheme.primary;
      default:
        return colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final String selectedKey = widget.selectedKey?.trim().toLowerCase() ?? '';
    final List<String> categories = _categories;
    final List<CrystalLibraryEntry> filtered = _filteredEntries;
    final MediaQueryData media = MediaQuery.of(context);
    final double topInset = (media.padding.top + 12).toDouble();
    final double availableHeight = media.size.height - topInset - 20;
    final double maxDialogHeight = availableHeight
        .clamp(360.0, 760.0)
        .toDouble();

    return Dialog(
      backgroundColor: colorScheme.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      insetPadding: EdgeInsets.fromLTRB(20, topInset, 20, 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 760, maxHeight: maxDialogHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: colorScheme.onSurface.withValues(alpha: 0.75),
                    ),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TextField(
                style: TextStyle(color: colorScheme.onSurface),
                cursorColor: colorScheme.primary,
                decoration: InputDecoration(
                  hintText: 'Search crystal name, stat...',
                  hintStyle: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.54),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: colorScheme.onSurface.withValues(
                        alpha: isLight ? 0.3 : 0.2,
                      ),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: colorScheme.onSurface.withValues(
                        alpha: isLight ? 0.3 : 0.2,
                      ),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: colorScheme.onSurface.withValues(
                        alpha: isLight ? 0.5 : 0.4,
                      ),
                    ),
                  ),
                ),
                onChanged: (String value) {
                  setState(() {
                    _query = value;
                  });
                },
              ),
              if (categories.length > 1) ...<Widget>[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _categoryFilter == null,
                      onSelected: (_) {
                        setState(() {
                          _categoryFilter = null;
                        });
                      },
                    ),
                    ...categories.map((String category) {
                      final Color accentColor = _categoryAccentColor(category);
                      return ChoiceChip(
                        label: Text(_categoryLabel(category)),
                        selected: _categoryFilter == category,
                        selectedColor: accentColor.withValues(alpha: 0.28),
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        side: BorderSide(
                          color: _categoryFilter == category
                              ? accentColor.withValues(alpha: 0.72)
                              : accentColor.withValues(alpha: 0.36),
                        ),
                        labelStyle: TextStyle(color: colorScheme.onSurface),
                        onSelected: (_) {
                          setState(() {
                            _categoryFilter = category;
                          });
                        },
                      );
                    }),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No crystal found.',
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.75,
                            ),
                          ),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints box) {
                          final int crossAxisCount = box.maxWidth >= 660
                              ? 3
                              : box.maxWidth >= 430
                              ? 2
                              : 1;
                          final double childAspectRatio = crossAxisCount == 3
                              ? 2.9
                              : crossAxisCount == 2
                              ? 2.6
                              : 4.8;
                          return GridView.builder(
                            itemCount: filtered.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                  childAspectRatio: childAspectRatio,
                                ),
                            itemBuilder: (BuildContext context, int index) {
                              final CrystalLibraryEntry entry = filtered[index];
                              final bool isSelected =
                                  entry.normalizedKey == selectedKey;
                              final Color accentColor = _crystalAccentColor(
                                entry,
                              );
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () => Navigator.of(context).pop(entry),
                                  child: Ink(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? accentColor.withValues(
                                              alpha: isLight ? 0.18 : 0.14,
                                            )
                                          : colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected
                                            ? accentColor.withValues(
                                                alpha: 0.75,
                                              )
                                            : colorScheme.onSurface.withValues(
                                                alpha: isLight ? 0.26 : 0.18,
                                              ),
                                      ),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: accentColor.withValues(
                                              alpha: 0.12,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: accentColor.withValues(
                                                alpha: 0.42,
                                              ),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Image.asset(
                                              _crystalIconPath(entry),
                                              fit: BoxFit.contain,
                                              errorBuilder: (_, __, ___) {
                                                return Icon(
                                                  Icons.diamond_outlined,
                                                  size: 14,
                                                  color: accentColor,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                entry.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: colorScheme.onSurface,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                '${entry.key} - ${_categoryLabel(entry.category)}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: colorScheme.onSurface
                                                      .withValues(alpha: 0.72),
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected)
                                          Icon(
                                            Icons.check_circle,
                                            color: accentColor,
                                            size: 18,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
