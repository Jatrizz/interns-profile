import 'package:flutter/material.dart';

class TimeLogsSearchBar extends StatefulWidget {
  final bool isDarkMode;
  final String searchQuery;
  final ValueChanged<String> onChanged;
  final List<String> suggestions;
  final ValueChanged<String> onSuggestionSelected;

  const TimeLogsSearchBar({
    super.key,
    required this.isDarkMode,
    required this.searchQuery,
    required this.onChanged,
    required this.suggestions,
    required this.onSuggestionSelected,
  });

  @override
  State<TimeLogsSearchBar> createState() => _TimeLogsSearchBarState();
}

class _TimeLogsSearchBarState extends State<TimeLogsSearchBar> {
  final _controller = TextEditingController();
  final _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    _removeOverlay();

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final width = renderBox.size.width;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 48),
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color:
                    widget.isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: widget.isDarkMode
                      ? const Color(0xFF3A3A3A)
                      : const Color(0xFFDDDDDD),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // ← sizes to content
                children: widget.suggestions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final name = entry.value;
                  final isLast = index == widget.suggestions.length - 1;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          _controller.text = name;
                          widget.onSuggestionSelected(name);
                          _removeOverlay();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              name,
                              style: TextStyle(
                                color: widget.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (!isLast)
                        Divider(
                          height: 1,
                          color: widget.isDarkMode
                              ? const Color(0xFF3A3A3A)
                              : const Color(0xFFEEEEEE),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: widget.isDarkMode
              ? const Color(0xFF2C2C2C)
              : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: widget.isDarkMode
                ? const Color(0xFF3A3A3A)
                : const Color(0xFFDDDDDD),
          ),
        ),
        child: TextField(
          controller: _controller,
          onChanged: (val) {
            widget.onChanged(val);
            if (val.isNotEmpty && widget.suggestions.isNotEmpty) {
              _showOverlay();
            } else {
              _removeOverlay();
            }
          },
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.black,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: 'Search intern name...',
            hintStyle: TextStyle(
              color: widget.isDarkMode ? Colors.grey[500] : Colors.grey[400],
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: widget.isDarkMode ? Colors.grey[500] : Colors.grey[400],
              size: 20,
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close,
                        size: 18,
                        color: widget.isDarkMode
                            ? Colors.grey[400]
                            : Colors.grey[600]),
                    onPressed: () {
                      _controller.clear();
                      widget.onChanged('');
                      _removeOverlay();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }
}
