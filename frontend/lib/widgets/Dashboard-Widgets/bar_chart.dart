import 'package:flutter/material.dart';

class BarChart extends StatefulWidget {
  final bool isDarkMode;
  final List<Map<String, dynamic>> yearlyStats;

  const BarChart({
    super.key,
    required this.isDarkMode,
    required this.yearlyStats,
  });

  @override
  State<BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<BarChart> {
  OverlayEntry? _overlayEntry;

  void _showTooltip({
    required Offset barGlobalCenter,
    required String school,
    required Color color,
    required int count,
  }) {
    _removeTooltip();

    // Position tooltip centred above the bar, locked on enter
    _overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        left: barGlobalCenter.dx - 60,
        top:  barGlobalCenter.dy - 72,
        child: Material(
          color: Colors.transparent,
          child: _TooltipCard(
            isDarkMode: widget.isDarkMode,
            school:     school,
            color:      color,
            count:      count,
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeTooltip();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final schools      = ['PLSP', 'CMDI', 'LSPU', 'OTHERS'];
    final schoolColors = [
      const Color(0xFF00BFFF),
      const Color(0xFF7B61FF),
      const Color(0xFF00D084),
      const Color(0xFFFF6B6B),
    ];

    if (widget.yearlyStats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.isDarkMode
              ? const Color(0xFF2E2E2E)
              : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    int maxCount = 0;
    for (var year in widget.yearlyStats) {
      for (var school in schools) {
        final val = (year[school] as int?) ?? 0;
        if (val > maxCount) maxCount = val;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? const Color(0xFF2E2E2E)
            : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title ────────────────────────────────────────────────────
          Text(
            "Interns per Year by School",
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 5),

          // ── Legend ───────────────────────────────────────────────────
          Wrap(
            spacing: 15,
            children: List.generate(schools.length, (i) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: schoolColors[i],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    schools[i],
                    style: TextStyle(
                      color: widget.isDarkMode
                          ? Colors.grey[400]
                          : Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 15),

          // ── Chart ────────────────────────────────────────────────────
          SizedBox(
            height: 220,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Y-axis labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    6,
                    (i) => Text(
                      "${((maxCount / 5) * (5 - i)).round()}",
                      style: TextStyle(
                        color: widget.isDarkMode
                            ? Colors.grey
                            : Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Bars
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(widget.yearlyStats.length, (yi) {
                      final yearData = widget.yearlyStats[yi];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(schools.length, (si) {
                              final count =
                                  (yearData[schools[si]] as int?) ?? 0;
                              final barHeight = maxCount > 0
                                  ? (count / maxCount) * 170.0
                                  : 0.0;

                              // Each bar gets its own key to find its position
                              final barKey = GlobalKey();

                              return _HoverBar(
                                barKey:    barKey,
                                count:     count,
                                barHeight: barHeight,
                                color:     schoolColors[si],
                                onEnter: () {
                                  if (count > 0) {
                                    // Get the bar's global position
                                    final box = barKey.currentContext
                                        ?.findRenderObject() as RenderBox?;
                                    if (box == null) return;
                                    final barGlobal =
                                        box.localToGlobal(Offset.zero);
                                    // Centre of bar top
                                    final centre = Offset(
                                      barGlobal.dx + box.size.width / 2,
                                      barGlobal.dy,
                                    );
                                    _showTooltip(
                                      barGlobalCenter: centre,
                                      school:          schools[si],
                                      color:           schoolColors[si],
                                      count:           count,
                                    );
                                  }
                                },
                                onExit: _removeTooltip,
                              );
                            }),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            yearData['year'] as String,
                            style: TextStyle(
                              color: widget.isDarkMode
                                  ? Colors.grey
                                  : Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Individual hoverable bar ──────────────────────────────────────────────────

class _HoverBar extends StatefulWidget {
  final GlobalKey barKey;
  final int       count;
  final double    barHeight;
  final Color     color;
  final VoidCallback onEnter;
  final VoidCallback onExit;

  const _HoverBar({
    required this.barKey,
    required this.count,
    required this.barHeight,
    required this.color,
    required this.onEnter,
    required this.onExit,
  });

  @override
  State<_HoverBar> createState() => _HoverBarState();
}

class _HoverBarState extends State<_HoverBar> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final h = widget.barHeight < 1 ? 1.0 : widget.barHeight;

    return MouseRegion(
      cursor: widget.count > 0
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      onEnter: (_) {
        setState(() => _hovered = true);
        widget.onEnter();
      },
      onExit: (_) {
        setState(() => _hovered = false);
        widget.onExit();
      },
      child: AnimatedContainer(
        key:      widget.barKey,
        duration: const Duration(milliseconds: 120),
        width:    _hovered ? 16 : 12,
        height:   _hovered ? h * 1.12 : h,
        margin:   const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: _hovered
              ? widget.color
              : widget.color.withOpacity(0.85),
          borderRadius: const BorderRadius.only(
            topLeft:  Radius.circular(3),
            topRight: Radius.circular(3),
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color:        widget.color.withOpacity(0.6),
                    blurRadius:   10,
                    spreadRadius: 2,
                    offset:       const Offset(0, -2),
                  ),
                ]
              : [],
        ),
      ),
    );
  }
}

// ── Tooltip card ──────────────────────────────────────────────────────────────

class _TooltipCard extends StatelessWidget {
  final bool   isDarkMode;
  final String school;
  final Color  color;
  final int    count;

  const _TooltipCard({
    required this.isDarkMode,
    required this.school,
    required this.color,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.18),
            blurRadius: 8,
            offset:     const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width:  10,
            height: 10,
            decoration: BoxDecoration(
              color:        color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$school: ',
            style: TextStyle(
              color:    isDarkMode ? Colors.grey[400] : Colors.grey[600],
              fontSize: 12,
            ),
          ),
          Text(
            '$count ${count == 1 ? 'intern' : 'interns'}',
            style: TextStyle(
              color:      isDarkMode ? Colors.white : Colors.black87,
              fontSize:   12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}