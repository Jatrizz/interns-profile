import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'lanyard.dart';

class LesterCard extends StatefulWidget {
  const LesterCard({super.key});

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const LanyardWidget(
          color: Color.fromARGB(185, 158, 158, 158),
          height: 90,
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: _openWebsite,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const _ProfessionalCard(),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: _isHovered ? 1 : 0,
                  child: Container(
                    width: 260,
                    height: 390,
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey, width: 0.5)),
                    child: const Center(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 16,
                          ),
                          Text(
                            'VIEW PROFILE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ])),
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
            color: Colors.white.withOpacity(0.25),
          ),
        ),
      ],
    );
  }
}

class _ProfessionalCard extends StatelessWidget {
  const _ProfessionalCard();

  final String portfolioUrl = 'https://eldyey.github.io/Personal-Portfolio/';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 390,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color.fromARGB(120, 193, 193, 193)),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.08),
            blurRadius: 18,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
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
                color: const Color.fromARGB(255, 69, 69, 69),
                shape: BoxShape.circle,
                border:
                    Border.all(color: const Color.fromARGB(144, 54, 54, 54)),
              ),
              child: Image.asset(
                'assets/images/lester.png',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'LESTER MANZANERO',
              style: TextStyle(
                color: Colors.white,
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
                  color: Colors.grey,
                  width: 1,
                ),
              ),
              child: Text(
                'FRONT-END DEVELOPER',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white.withOpacity(0.7),
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Divider(color: Colors.white.withOpacity(0.08)),
            const SizedBox(height: 8),
            _infoRow('School', 'PLSP'),
            _infoRow('Program', 'Computer Engineering'),
            _infoRow('Since', 'Aug 2022'),
            Row(
              children: [
                Text(
                  'STATUS',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.35),
                  ),
                ),
                const Spacer(),
                const Text(
                  '●',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
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
            Divider(color: Colors.white.withOpacity(0.08)),
            Center(
              child: BarcodeWidget(
                barcode: Barcode.qrCode(),
                data: portfolioUrl,
                width: 50,
                height: 50,
                color: Colors.white,
                backgroundColor: Colors.transparent,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              'DEV-2026-182',
              style: TextStyle(
                fontSize: 8,
                color: Colors.white.withOpacity(0.35),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.35),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              color: Color.fromARGB(181, 255, 255, 255),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
