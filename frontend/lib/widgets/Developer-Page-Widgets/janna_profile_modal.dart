import 'package:flutter/material.dart';

void showProfileModal(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.75),
    builder: (ctx) => Dialog(
      backgroundColor: const Color(0xFF0d1b2e),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: SizedBox(
        width: 680,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top accent bar
            Container(
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFF3b82f6),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 20, 18),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFF3b82f6).withOpacity(0.4),
                          width: 2),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/janna.png',
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF1e3a5f),
                          child: const Center(
                            child: Text(
                              'JA',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF93c5fd),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Janna Pujeda',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Full-stack Developer · Computer Science Student',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.45),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3b82f6).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFF3b82f6).withOpacity(0.3)),
                        ),
                        child: const Text(
                          '● Active',
                          style:
                              TextStyle(fontSize: 12, color: Color(0xFF7fff90)),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: Icon(Icons.close,
                        color: Colors.white.withOpacity(0.3), size: 22),
                  ),
                ],
              ),
            ),

            Divider(color: Colors.white.withOpacity(0.06), height: 0.5),

            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // About
                    _modalSection('About'),
                    _modalBody(
                      'Computer Science student with skills in programming, web and mobile development, and UI/UX design. '
                      'Driven to create user-centered, reliable digital solutions and eager to contribute to projects '
                      'that make technology accessible and impactful.',
                    ),

                    // Details grid
                    _modalSection('Details'),
                    _modalGrid(items: const {
                      'Email': 'pujedajannatricia@gmail.com',
                      'Member since': 'Feb 2026',
                      'ID': 'DEV-2026-179',
                      'Department': 'Development',
                    }),

                    // Education
                    _modalSection('Education'),
                    _modalBody(
                        'BS Computer Science\nLaguna State Polytechnic University'),

                    // Work
                    _modalSection('Work Experience'),
                    _modalWork(
                      'FDS ASYA PHILIPPINES INC. INTERN',
                      'Solutions Dev Intern — Full-stack Developer',
                      'Feb 2026 – May 2026',
                    ),

                    // Skills
                    _modalSection('Skills'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'Flutter',
                        'Dart',
                        'Go',
                        'PostgreSQL',
                        'Figma',
                        'Git',
                        'REST APIs',
                        'UI/UX',
                      ]
                          .map((s) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF3b82f6).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: const Color(0xFF3b82f6)
                                          .withOpacity(0.3)),
                                ),
                                child: Text(
                                  s,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF93c5fd),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _modalSection(String title) => Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          letterSpacing: 0.12,
          color: Colors.white.withOpacity(0.25),
          fontWeight: FontWeight.w500,
        ),
      ),
    );

Widget _modalBody(String text) => Text(
      text,
      style: TextStyle(
        fontSize: 15,
        color: Colors.white.withOpacity(0.6),
        height: 1.7,
      ),
    );

Widget _modalGrid({required Map<String, String> items}) => GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 3.5,
      children: items.entries
          .map(
            (e) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.07)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    e.key,
                    style: TextStyle(
                        fontSize: 11, color: Colors.white.withOpacity(0.3)),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    e.value,
                    style: TextStyle(
                      fontSize: 13,
                      color: e.key == 'Status'
                          ? const Color(0xFF7fff90)
                          : Colors.white.withOpacity(0.75),
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );

Widget _modalWork(String company, String position, String period) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            company,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            position,
            style:
                TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.45)),
          ),
          const SizedBox(height: 6),
          Text(
            period,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.25),
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
