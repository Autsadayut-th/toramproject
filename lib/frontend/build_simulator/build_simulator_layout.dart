part of 'build_simulator_page.dart';

extension _BuildSimulatorScreenUI on BuildSimulatorScreenState {
  Widget _buildScreenUI(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= 1024;
        final Widget body;
        if (isWide) {
          body = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildEquipmentPanel(),
                ),
              ),
              SizedBox(
                width: 320,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(0, 24, 20, 24),
                  child: Column(
                    children: [
                      _buildStatsSummary(),
                      if (_shouldShowRecommendationsPanel) ...<Widget>[
                        const SizedBox(height: 24),
                        _buildRecommendationsSection(),
                      ],
                      const SizedBox(height: 24),
                      _buildSaveLoadSection(),
                    ],
                  ),
                ),
              ),
            ],
          );
        } else {
          body = SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: <Widget>[_buildEquipmentPanel()]),
          );
        }

        return Stack(
          children: <Widget>[
            Positioned.fill(child: _buildAmbientBackground()),
            body,
          ],
        );
      },
    );
  }

  Widget _buildAmbientBackground() {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF000000), Color(0xFF050505), Color(0xFF0A0A0A)],
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: const Alignment(-0.9, -0.95),
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFFFFF).withValues(alpha: 0.05),
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0.95, -0.85),
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFFFFF).withValues(alpha: 0.04),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsibleCard({
    required String title,
    required IconData iconData,
    Color iconColor = Colors.white,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
    double? height,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D).withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFFFFF).withValues(alpha: 0.22),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF111111).withValues(alpha: 0.78),
                    const Color(0xFF080808).withValues(alpha: 0.76),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(iconData, color: iconColor, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: height != null
                  ? SizedBox(
                      height: height,
                      child: SingleChildScrollView(child: child),
                    )
                  : child,
            ),
        ],
      ),
    );
  }
}
