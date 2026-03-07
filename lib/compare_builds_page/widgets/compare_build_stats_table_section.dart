part of '../compare_builds_page.dart';

extension _CompareBuildsStatsTableSection on _CompareBuildsPageState {
  Widget _buildCenteredCompareTable({
    required Map<String, dynamic>? firstBuild,
    required Map<String, dynamic>? secondBuild,
    required bool showOnlyDifferences,
    required bool sortByDifference,
  }) {
    final List<({String key, int left, int right, int delta})> rows =
        _CompareBuildsPageState._compareKeys.map((String key) {
          final int leftValue = _summaryValue(firstBuild, key);
          final int rightValue = _summaryValue(secondBuild, key);
          final int delta = rightValue - leftValue;
          return (key: key, left: leftValue, right: rightValue, delta: delta);
        }).toList(growable: false);

    final List<({String key, int left, int right, int delta})> filtered = rows
        .where((({String key, int left, int right, int delta}) row) {
          if (!showOnlyDifferences) {
            return true;
          }
          return row.delta != 0;
        })
        .toList(growable: false);

    if (sortByDifference) {
      filtered.sort((a, b) {
        final int byDelta = b.delta.abs().compareTo(a.delta.abs());
        if (byDelta != 0) {
          return byDelta;
        }
        return a.key.compareTo(b.key);
      });
    }

    if (filtered.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: const Text(
          'No differences found in current filter.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final Widget table = DataTable(
      headingRowColor: WidgetStatePropertyAll(
        const Color(0xFF151515),
      ),
      dataRowMinHeight: 44,
      dataRowMaxHeight: 52,
      columns: const <DataColumn>[
        DataColumn(label: Text('Stat')),
        DataColumn(label: Text('Build A')),
        DataColumn(label: Text('Build B')),
        DataColumn(label: Text('Delta')),
      ],
      rows: filtered.map((({String key, int left, int right, int delta}) row) {
        final String deltaText = row.delta > 0
            ? '+${_formatStatValue(row.key, row.delta)}'
            : _formatStatValue(row.key, row.delta);
        final Color deltaColor = row.delta > 0
            ? const Color(0xFF78E08F)
            : row.delta < 0
            ? const Color(0xFFFF9A9A)
            : Colors.white70;
        final Color rowBorderColor = row.delta == 0
            ? Colors.white.withValues(alpha: 0.04)
            : deltaColor.withValues(alpha: 0.30);
        return DataRow(
          color: WidgetStatePropertyAll(
            row.delta == 0
                ? Colors.transparent
                : deltaColor.withValues(alpha: 0.06),
          ),
          cells: <DataCell>[
            DataCell(
              Text(
                row.key,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            DataCell(
              Text(
                _formatStatValue(row.key, row.left),
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            DataCell(
              Text(
                _formatStatValue(row.key, row.right),
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: rowBorderColor),
                ),
                child: Text(
                  deltaText,
                  style: TextStyle(
                    color: deltaColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        );
      }).toList(growable: false),
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Center(child: table),
            ),
          ),
        );
      },
    );
  }
}
