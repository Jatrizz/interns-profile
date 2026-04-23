import 'package:flutter/material.dart';

class TimeLogsInternDropdown extends StatefulWidget {
  final bool isDarkMode;
  final List<String> internNames;
  final String? selectedIntern;
  final ValueChanged<String?> onChanged;

  const TimeLogsInternDropdown({
    super.key,
    required this.isDarkMode,
    required this.internNames,
    required this.selectedIntern,
    required this.onChanged,
  });

  @override
  State<TimeLogsInternDropdown> createState() => _TimeLogsInternDropdownState();
}

class _TimeLogsInternDropdownState extends State<TimeLogsInternDropdown> {
  final _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _isOpen = false);
  }

  void _showOverlay() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final width = renderBox.size.width;

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _removeOverlay,
        child: Stack(
          children: [
            Positioned(
              width: width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: const Offset(0, 48),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 250),
                    decoration: BoxDecoration(
                      color: widget.isDarkMode
                          ? const Color(0xFF2C2C2C)
                          : Colors.white,
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
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: widget.internNames.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: widget.isDarkMode
                            ? const Color(0xFF3A3A3A)
                            : const Color(0xFFEEEEEE),
                      ),
                      itemBuilder: (context, index) {
                        final name = widget.internNames[index];
                        final isSelected = name == widget.selectedIntern;
                        return InkWell(
                          onTap: () {
                            widget.onChanged(name);
                            _removeOverlay();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      color: widget.isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check,
                                    size: 16,
                                    color: widget.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _toggleOverlay() {
    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleOverlay,
        child: Container(
          width: double.infinity,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
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
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.selectedIntern ?? 'Select an intern',
                  style: TextStyle(
                    color: widget.selectedIntern == null
                        ? (widget.isDarkMode
                            ? Colors.grey[500]
                            : Colors.grey[400])
                        : (widget.isDarkMode ? Colors.white : Colors.black),
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(
                _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
