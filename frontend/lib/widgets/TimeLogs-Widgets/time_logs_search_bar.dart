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
  bool _showSuggestions = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
              setState(() => _showSuggestions = val.isNotEmpty);
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
                        setState(() => _showSuggestions = false);
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),

        // Suggestions dropdown
        if (_showSuggestions && widget.suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: widget.isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: widget.isDarkMode
                    ? const Color(0xFF3A3A3A)
                    : const Color(0xFFDDDDDD),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: widget.suggestions.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: widget.isDarkMode
                    ? const Color(0xFF3A3A3A)
                    : const Color(0xFFEEEEEE),
              ),
              itemBuilder: (context, index) {
                final name = widget.suggestions[index];
                return InkWell(
                  onTap: () {
                    _controller.text = name;
                    widget.onSuggestionSelected(name);
                    setState(() => _showSuggestions = false);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Text(
                      name,
                      style: TextStyle(
                        color: widget.isDarkMode ? Colors.white : Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
