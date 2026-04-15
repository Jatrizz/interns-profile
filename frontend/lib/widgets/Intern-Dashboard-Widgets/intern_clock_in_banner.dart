import 'package:flutter/material.dart';

class ClockInBanner extends StatelessWidget {
  final bool isDarkMode;
  final bool isClockedIn;
  final String clockInTime;
  final String elapsedTime;
  final VoidCallback onClockToggle;

  const ClockInBanner({
    super.key,
    required this.isDarkMode,
    required this.isClockedIn,
    required this.clockInTime,
    required this.elapsedTime,
    required this.onClockToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E3448) : const Color(0xFFDDEEFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isClockedIn ? 'You are clocked in!' : 'You are clocked out.',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isClockedIn
                    ? 'Since $clockInTime – $elapsedTime elapsed'
                    : 'Clock in to start tracking your hours.',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 13,
                ),
              ),
            ],
          ),
          OutlinedButton(
            onPressed: onClockToggle,
            style: OutlinedButton.styleFrom(
              foregroundColor: isDarkMode ? Colors.white : Colors.black87,
              side: BorderSide(
                color: isDarkMode ? Colors.white54 : Colors.black38,
                width: 1.5,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: Text(isClockedIn ? 'Clock out' : 'Clock in'),
          ),
        ],
      ),
    );
  }
}
