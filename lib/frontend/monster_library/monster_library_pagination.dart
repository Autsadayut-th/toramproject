part of 'monster_library_page.dart';

extension _MonsterLibraryPagination on _MonsterLibraryDataViewState {
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
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'หน้า',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildPaginationControl(
                        label: '<',
                        enabled: currentPage > 1,
                        onTap: () {
                          _setLibraryState(() {
                            _currentPage = currentPage - 1;
                          });
                        },
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
                          onTap: () {
                            _setLibraryState(() {
                              _currentPage = page;
                            });
                          },
                        ),
                        const SizedBox(width: 6),
                      ],
                      _buildPaginationControl(
                        label: '>',
                        enabled: currentPage < totalPages,
                        onTap: () {
                          _setLibraryState(() {
                            _currentPage = currentPage + 1;
                          });
                        },
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
        ? const Color(0xFF888888)
        : const Color(0xFF666666);
    final Color textColor = enabled || isSelected
        ? Colors.white
        : Colors.white54;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minWidth: 34),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [const Color(0xFF4A4A4A), const Color(0xFF3A3A3A)]
                : [const Color(0xFF2A2A2A), const Color(0xFF1A1A1A)],
          ),
          borderRadius: BorderRadius.circular(8),
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
