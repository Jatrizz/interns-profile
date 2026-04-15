import 'package:flutter/material.dart';

class InternTopBar extends StatelessWidget {
  final bool isDarkMode;
  final String firstName;
  final VoidCallback onToggleDarkMode;

  const InternTopBar({
    super.key,
    required this.isDarkMode,
    required this.firstName,
    required this.onToggleDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: isDarkMode ? const Color(0xFF242424) : const Color(0xFFF0F0F0),
      child: Row(
        children: [
          const Spacer(),
          Text(
            "Hi, $firstName",
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 15),
          GestureDetector(
            onTap: onToggleDarkMode,
            child: Icon(
              isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
