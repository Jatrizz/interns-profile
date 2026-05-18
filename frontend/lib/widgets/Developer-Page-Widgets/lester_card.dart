import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:barcode_widget/barcode_widget.dart';

class LesterCard extends StatefulWidget {
  final bool isDarkMode;

  const LesterCard({super.key, required this.isDarkMode});

  @override
  State<LesterCard> createState() => _LesterCardState();
}

class _LesterCardState extends State<LesterCard> {
  bool _isHovered = false;

  final String portfolioUrl = 'https://eldyey.github.io/Personal-Portfolio/';

  Future<void> _openWebsite() async {
    await launchUrl(
      Uri.parse(portfolioUrl),
      webOnlyWindowName: '_blank',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RealisticIDLace(isDarkMode: isDark),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: _openWebsite,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _ProfessionalCard(isDarkMode: isDark),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: _isHovered ? 1 : 0,
                  child: Container(
                    width: 260,
                    height: 390,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withOpacity(0.65)
                          : Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? Colors.grey : Colors.black26,
                        width: 0.5,
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person,
                            color: isDark ? Colors.white : Colors.black,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'VIEW PROFILE',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 12,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'TAP TO VIEW PROFILE',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 1.5,
            color: isDark
                ? Colors.white.withOpacity(0.25)
                : Colors.black.withOpacity(0.35),
          ),
        ),
      ],
    );
  }
}

class RealisticIDLace extends StatelessWidget {
  final bool isDarkMode;

  const RealisticIDLace({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkMode;

    return SizedBox(
      width: 260,
      height: 95,
      child: Column(
        children: [
          Container(
            width: 26,
            height: 85,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(7),
                  bottom: Radius.circular(7),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [
                          const Color.fromARGB(217, 119, 58, 58),
                          Colors.white,
                        ]
                      : [
                          Colors.white,
                          const Color.fromARGB(217, 119, 58, 58),
                        ],
                ),
                border: Border.all(
                    color: isDark ? Colors.grey : Colors.black, width: 0.5)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? Colors.white : const Color(0xFF7A0019),
                  ),
                  child: Image.asset(
                    '../../assets/images/fdsap-logo.png',
                    color: isDark ? const Color(0xFF7A0019) : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Column(
                  children: const [
                    Text('F',
                        style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7A0019))),
                    Text('D',
                        style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7A0019))),
                    Text('S',
                        style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7A0019))),
                    Text('A',
                        style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7A0019))),
                    Text('P',
                        style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7A0019))),
                  ],
                )
              ],
            ),
          ),
          Container(
            height: 10,
            width: 8,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey : Colors.grey.shade400,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(2),
                bottomRight: Radius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfessionalCard extends StatelessWidget {
  final bool isDarkMode;

  const _ProfessionalCard({required this.isDarkMode});

  final String portfolioUrl = 'https://eldyey.github.io/Personal-Portfolio/';

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkMode;

    return Container(
      width: 260,
      height: 390,
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.black12,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.08),
            blurRadius: 18,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.8)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            Container(
              width: 85,
              height: 85,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color.fromARGB(255, 68, 68, 68)
                    : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.white24 : Colors.black12,
                ),
              ),
              child: Image.asset(
                'assets/images/Lester.png',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'LESTER MANZANERO',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.white24 : Colors.black26,
                ),
              ),
              child: Text(
                'FRONT-END DEVELOPER',
                style: TextStyle(
                  fontSize: 9,
                  color: isDark
                      ? Colors.white.withOpacity(0.7)
                      : Colors.black.withOpacity(0.7),
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Divider(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.08),
            ),
            const SizedBox(height: 8),
            _infoRow(context, 'School', 'PLSP'),
            _infoRow(context, 'Program', 'Computer Engineering'),
            _infoRow(context, 'Since', 'Aug 2022'),
            Row(
              children: const [
                Text(
                  'STATUS',
                  style: TextStyle(
                      fontSize: 10, color: Color.fromARGB(147, 158, 158, 158)),
                ),
                Spacer(),
                Text('●', style: TextStyle(fontSize: 10, color: Colors.green)),
                SizedBox(width: 4),
                Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Divider(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.08),
            ),
            Center(
              child: BarcodeWidget(
                barcode: Barcode.qrCode(),
                data: portfolioUrl,
                width: 50,
                height: 50,
                color: isDark ? Colors.white : Colors.black,
                backgroundColor: Colors.transparent,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'DEV-2026-182',
              style: TextStyle(
                fontSize: 8,
                color: isDark
                    ? Colors.white.withOpacity(0.35)
                    : Colors.black.withOpacity(0.35),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    final isDark = isDarkMode;

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              color: isDark
                  ? Colors.white.withOpacity(0.35)
                  : Colors.black.withOpacity(0.5),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? Colors.white.withOpacity(0.7)
                  : Colors.black.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
