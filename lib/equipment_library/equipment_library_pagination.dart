part of 'equipment_library_page.dart';

extension _EquipmentLibraryPagination on _EquipmentLibraryDataViewState {
  Widget _buildPaginationBar({
    required int currentPage,
    required int totalPages,
  }) {
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
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF171311), Color(0xFF0D1115)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x22FFFFFF)),
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
    final Color borderColor = isSelected
        ? _libraryWarmAccent
        : _libraryCoolAccent.withValues(alpha: 0.32);
    final Color textColor = enabled || isSelected
        ? Colors.white
        : Colors.white38;

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
                    _libraryWarmAccent.withValues(alpha: 0.28),
                    _libraryCoolAccent.withValues(alpha: 0.2),
                  ]
                : <Color>[const Color(0xFF10161A), const Color(0xFF0D1115)],
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
