part of '../compare_builds_page.dart';

extension _CompareBuildsStatsTableSection on _CompareBuildsPageState {
  Widget _buildCenteredCompareTable({
    required Map<String, dynamic>? firstBuild,
    required Map<String, dynamic>? secondBuild,
  }) {
    final Widget table = DataTable(
      columns: const [
        DataColumn(label: Text('Stat')),
        DataColumn(label: Text('Build A')),
        DataColumn(label: Text('Build B')),
        DataColumn(label: Text('Delta')),
      ],
      rows: _CompareBuildsPageState._compareKeys
          .map((String key) {
            final int leftValue = _summaryValue(firstBuild, key);
            final int rightValue = _summaryValue(secondBuild, key);
            final int delta = rightValue - leftValue;

            final String deltaText = delta > 0
                ? '+${_formatStatValue(key, delta)}'
                : _formatStatValue(key, delta);

            final Color deltaColor = delta > 0
                ? const Color(0xFF888888)
                : delta < 0
                ? const Color(0xFF666666)
                : Colors.white70;

            return DataRow(
              cells: [
                DataCell(
                  Text(
                    key,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                DataCell(
                  Text(
                    _formatStatValue(key, leftValue),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                DataCell(
                  Text(
                    _formatStatValue(key, rightValue),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                DataCell(
                  Text(
                    deltaText,
                    style: TextStyle(
                      color: deltaColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            );
          })
          .toList(growable: false),
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Center(child: table),
          ),
        );
      },
    );
  }
}
