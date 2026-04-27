import 'package:flutter/material.dart';

class PreFooter extends StatelessWidget {
  final bool isDarkMode;
  const PreFooter({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 150),
      child: SizedBox(
        height: 180,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Brand blurb ───────────────────────────────────────────────
            SizedBox(
              width: 200,
              height: 150,
              child: Column(
                children: [
                  Row(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Logo: no color tint — just let it render naturally.
                          Image.asset(
                            'assets/images/logo.png',
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                          ),
                          Text(
                            'Orbis',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.only(left: 50, right: 2),
                    child: Text(
                      'A simple and efficient management system built for organizations to track and manage their interns.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode
                            ? const Color.fromRGBO(255, 255, 255, 0.815)
                            : Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Social links ──────────────────────────────────────────────
            SizedBox(
              height: 150,
              width: 200,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsetsGeometry.only(top: 15, bottom: 14),
                    child: Text(
                      'Follow Us',
                      style: TextStyle(
                        fontSize: 15,
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 25,
                        height: 85,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.facebook,
                              size: 20,
                              // Social icons: keep the grey tint in both modes
                              color: isDarkMode ? Colors.grey : Colors.black54,
                            ),
                            Image.asset(
                              'assets/images/instagram.png',
                              width: 18,
                              height: 18,
                              // Social icon images: tint is fine here
                              color: isDarkMode ? Colors.grey : Colors.black54,
                            ),
                            Image.asset(
                              'assets/images/linkedin.png',
                              width: 18,
                              height: 18,
                              color: isDarkMode ? Colors.grey : Colors.black54,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 85,
                        width: 60,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Orbis',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            Text(
                              'Orbis',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            Text(
                              'Orbis',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Contact info ──────────────────────────────────────────────
            SizedBox(
              height: 150,
              width: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 17),
                  Text(
                    'Contact',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 80,
                    width: 150,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Email@company.com',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          '09123456789',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          'San Pablo City, Laguna',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}