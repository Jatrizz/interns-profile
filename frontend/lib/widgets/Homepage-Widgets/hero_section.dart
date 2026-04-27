import 'package:flutter/material.dart';
import 'package:interfaces/pages/about_page.dart';
import 'package:interfaces/pages/register_page.dart';

class HeroSection extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  const HeroSection(
      {super.key, required this.isDarkMode, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Logo ─────────────────────────────────────────────────────────
        Expanded(
          child: SizedBox(
            height: 700,
            // In light mode the logo (assumed white-on-transparent) would be
            // invisible against the light background, so we invert it.
            child: isDarkMode
                ? Image.asset('assets/images/logo.png', fit: BoxFit.contain)
                : ColorFiltered(
                    colorFilter: const ColorFilter.matrix(<double>[
                      -1, 0, 0, 0, 255,
                       0,-1, 0, 0, 255,
                       0, 0,-1, 0, 255,
                       0, 0, 0, 1,   0,
                    ]),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
          ),
        ),

        // ── Copy + CTA ───────────────────────────────────────────────────
        Expanded(
          child: SizedBox(
            height: 500,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Orbis - Intern Profile\nManagement System',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'Stay on top of your internship journey by easily tracking your daily\nhours, monitoring your remaining OJT hours, and keeping your\nprofile up to date. All in one simple and organized platform.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color:
                            isDarkMode ? Colors.white : Colors.black87,
                        fontSize: 15),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 300,
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Get Started button
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 65, 142, 204),
                              Color.fromARGB(255, 0, 4, 250),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, a1, a2) =>
                                      RegisterPage(
                                          isDarkMode: isDarkMode,
                                          onToggleTheme: onToggleTheme),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsetsGeometry.symmetric(
                                  horizontal: 15, vertical: 10),
                              child: const Center(
                                child: Text(
                                  'Get Started',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w100,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),

                      // Learn More button
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, a1, a2) => AboutPage(
                                  isDarkMode: isDarkMode,
                                  onToggleTheme: onToggleTheme),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Text(
                              'Learn More',
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.grey
                                    : Colors.black54,
                                fontSize: 15,
                              ),
                            ),
                            Icon(Icons.arrow_forward,
                                color: isDarkMode
                                    ? Colors.grey
                                    : Colors.black54),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}