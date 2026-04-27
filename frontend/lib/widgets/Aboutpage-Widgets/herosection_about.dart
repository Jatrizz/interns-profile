import 'package:flutter/material.dart';

class HerosectionAbout extends StatelessWidget {
  final bool isDarkMode;
  const HerosectionAbout({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Logo ─────────────────────────────────────────────────────────
        Expanded(
          child: SizedBox(
            height: 700,
            child: isDarkMode
                ? Image.asset(
                    '../../../assets/images/logo.png',
                    fit: BoxFit.contain,
                  )
                : ColorFiltered(
                    colorFilter: const ColorFilter.matrix(<double>[
                      -1, 0, 0, 0, 255,
                       0,-1, 0, 0, 255,
                       0, 0,-1, 0, 255,
                       0, 0, 0, 1,   0,
                    ]),
                    child: Image.asset(
                      '../../../assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
          ),
        ),

        // ── Heading ───────────────────────────────────────────────────────
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'About Us',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Learn more about our intern profile\nmanagement system and the team behind it.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}