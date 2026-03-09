part of 'equipment_library_page.dart';

extension _EquipmentLibraryPagination on _EquipmentLibraryDataViewState {
  Widget _buildPaginationBar({
    required int currentPage,
    required int totalPages,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    const int maxVisiblePages = 10;
    int startPage = 1;
    if (totalPages > maxVisiblePages) {
      startPage = currentPage - (maxVisiblePages ~/ 2);
      if (startPage < 1) {
        startPage = 1;
      }
      if (startPage + maxVisiblePages - 1 > totalPages) {
        startPage = totalPages - maxVisiblePages + 1;
      }
    }
    final int endPage = totalPages < maxVisiblePages
        ? totalPages
        : startPage + maxVisiblePages - 1;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                colorScheme.surfaceContainerHigh,
                colorScheme.surfaceContainerHighest,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.onSurface.withValues(
                alpha: isLight ? 0.24 : 0.14,
              ),
            ),
          ),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _buildPaginationControl(
                        label: '<',
                        enabled: currentPage > 1,
                        onTap: () => _setCurrentPage(currentPage - 1),
                      ),
                      const SizedBox(width: 6),
                      for (
                        int page = startPage;
                        page <= endPage;
                        page++
                      ) ...<Widget>[
                        _buildPaginationControl(
                          label: '$page',
                          enabled: page != currentPage,
                          isSelected: page == currentPage,
                          onTap: () => _setCurrentPage(page),
                        ),
                        const SizedBox(width: 6),
                      ],
                      _buildPaginationControl(
                        label: '>',
                        enabled: currentPage < totalPages,
                        onTap: () => _setCurrentPage(currentPage + 1),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControl({
    required String label,
    required bool enabled,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final Color borderColor = isSelected
        ? colorScheme.primary
        : colorScheme.onSurface.withValues(alpha: isLight ? 0.42 : 0.32);
    final Color textColor = enabled || isSelected
        ? colorScheme.onSurface
        : colorScheme.onSurface.withValues(alpha: 0.38);

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minWidth: 38),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? <Color>[
                    colorScheme.primary.withValues(alpha: 0.28),
                    colorScheme.secondary.withValues(alpha: 0.2),
                  ]
                : <Color>[
                    colorScheme.surfaceContainerHighest,
                    colorScheme.surfaceContainerHigh,
                  ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
