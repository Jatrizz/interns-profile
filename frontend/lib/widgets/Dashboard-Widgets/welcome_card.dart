import 'package:flutter/material.dart';
import '../../utils/responsive.dart';

class WelcomeCard extends StatelessWidget {
  final bool isDarkMode;
  final String firstName;
  final String currentTime;

  const WelcomeCard({
    super.key,
    required this.isDarkMode,
    required this.firstName,
    required this.currentTime,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2E2E2E) : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: isMobile
          // mobile: stack text above clock
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back, ${firstName.split(' ')[0]}!",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Welcome to your dashboard. Manage your interns efficiently.",
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                Center(child: _clock()),
              ],
            )
          // desktop: side by side
          : Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome back, ${firstName.split(' ')[0]}!",
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Welcome to your dashboard. Manage your interns efficiently.",
                        style: TextStyle(
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                _clock(),
              ],
            ),
    );
  }

  Widget _clock() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        currentTime,
        style: TextStyle(
          color: const Color(0xFF00BFFF),
          fontSize: 42,
          fontWeight: FontWeight.bold,
          fontFamily: 'RobotoMono',
          letterSpacing: 6,
          shadows: isDarkMode
              ? [
                  Shadow(
                    color: const Color(0xFF00BFFF).withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}
