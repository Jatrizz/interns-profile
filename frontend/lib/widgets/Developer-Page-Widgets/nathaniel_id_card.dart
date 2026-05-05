import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'lanyard.dart';

class NathanielIDCard extends StatefulWidget {
  const NathanielIDCard({super.key});

  @override
  State<NathanielIDCard> createState() => _NathanielIDCardState();
}

class _NathanielIDCardState extends State<NathanielIDCard> {
  bool _isHovered = false;

  final String portfolioUrl = 'https://neyytann.github.io/portfolio/';

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
          color: Color(0xFF64FFDA),
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
                const _NathanielCardFace(),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: _isHovered ? 1 : 0,
                  child: Container(
                    width: 260,
                    height: 390,
                    decoration: BoxDecoration(
                      color: const Color(0xFF64FFDA).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF64FFDA).withOpacity(0.5),
                        width: 0.5,
                      ),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.open_in_new,
                              color: Color(0xFF64FFDA), size: 14),
                          SizedBox(width: 6),
                          Text(
                            'VIEW PORTFOLIO',
                            style: TextStyle(
                              color: Color(0xFF64FFDA),
                              fontSize: 11,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'monospace',
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
          'TAP TO VIEW PORTFOLIO',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 1.5,
            color: Colors.white.withOpacity(0.20),
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

// ── Card face ─────────────────────────────────────────────────────────────────

class _NathanielCardFace extends StatelessWidget {
  const _NathanielCardFace();

  // Portfolio palette
  static const _bgCard    = Color(0xFF112240); // card navy
  static const _accent    = Color(0xFF64FFDA); // cyan-green
  static const _accentDim = Color(0xFF1A3A3A); // dark cyan tint
  static const _textLight = Color(0xFFE6F1FF);
  static const _textMuted = Color(0xFF8892B0);
  static const _border    = Color(0xFF1E3A5F);

  final String portfolioUrl = 'https://neyytann.github.io/portfolio/';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 390,
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.08),
            blurRadius: 32,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Subtle grid texture overlay
            Positioned.fill(
              child: CustomPaint(painter: _GridPainter()),
            ),

            // Ghost circle watermarks
            Positioned(
              bottom: -50, right: -50,
              child: Container(
                width: 180, height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: _accent.withOpacity(0.05), width: 0.5),
                ),
              ),
            ),
            Positioned(
              bottom: -20, right: -20,
              child: Container(
                width: 110, height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: _accent.withOpacity(0.03), width: 0.5),
                ),
              ),
            ),

            // Cyan top stripe
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                height: 2,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      _accent,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Org row
                  Row(
                    children: [
                      Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(
                          color: _accentDim,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                              color: _accent.withOpacity(0.4), width: 0.5),
                        ),
                        child: const Center(
                          child: Text(
                            'FDS',
                            style: TextStyle(
                              fontSize: 5.5,
                              fontWeight: FontWeight.w700,
                              color: _accent,
                              letterSpacing: 0.4,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FDS ASYA PHILIPPINES INC.',
                            style: TextStyle(
                              fontSize: 7.5,
                              letterSpacing: 0.08,
                              color: _textMuted.withOpacity(0.7),
                              fontFamily: 'monospace',
                            ),
                          ),
                          Text(
                            'INTERN · BACKEND DEVELOPER',
                            style: TextStyle(
                              fontSize: 5.5,
                              letterSpacing: 0.06,
                              color: _accent.withOpacity(0.6),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Avatar
                  Center(
                    child: Container(
                      width: 85,
                      height: 85,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: _accentDim,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: _accent.withOpacity(0.35), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: _accent.withOpacity(0.12),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/nathan.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(
                            'NV',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: _accent.withOpacity(0.7),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Name
                  Center(
                    child: Text(
                      'NATHANIEL VELASCO',
                      style: const TextStyle(
                        color: _textLight,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Role chip
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 12),
                      decoration: BoxDecoration(
                        color: _accentDim,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _accent.withOpacity(0.4), width: 0.5),
                      ),
                      child: Text(
                        'BACKEND DEVELOPER',
                        style: TextStyle(
                          fontSize: 8.5,
                          color: _accent,
                          letterSpacing: 1.2,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Divider(color: _border, height: 0.5),
                  const SizedBox(height: 10),

                  // Info rows
                  _infoRow('School', 'PLSP', _textMuted, _textLight),
                  _infoRow('Program', 'Information Technology', _textMuted, _textLight),
                  _infoRow('Since', 'Sep 2022', _textMuted, _textLight),
                  _statusRow(),

                  const Spacer(),
                  Divider(color: _border, height: 0.5),
                  const SizedBox(height: 8),

                  // QR + ID
                  Center(
                    child: BarcodeWidget(
                      barcode: Barcode.qrCode(),
                      data: 'https://neyytann.github.io/portfolio/',
                      width: 48,
                      height: 48,
                      color: _accent,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Center(
                    child: Text(
                      'DEV-2026-180',
                      style: TextStyle(
                        fontSize: 8,
                        color: _textMuted.withOpacity(0.45),
                        letterSpacing: 1.2,
                        fontFamily: 'monospace',
                      ),
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

  Widget _infoRow(String label, String value, Color labelColor, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              color: labelColor.withOpacity(0.5),
              fontFamily: 'monospace',
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              color: valueColor.withOpacity(0.75),
              fontWeight: FontWeight.w500,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Text(
            'STATUS',
            style: TextStyle(
              fontSize: 9,
              color: const Color.fromARGB(255, 136, 176, 147).withOpacity(0.5),
              fontFamily: 'monospace',
            ),
          ),
          const Spacer(),
          const Text(
            '●',
            style: TextStyle(fontSize: 8, color: Color.fromARGB(255, 0, 255, 21)),
          ),
          const SizedBox(width: 4),
          const Text(
            'Active',
            style: TextStyle(
              fontSize: 10,
              color: Color.fromARGB(255, 0, 255, 21),
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

// ── Subtle grid texture painter ───────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF64FFDA).withOpacity(0.025)
      ..strokeWidth = 0.5;

    const step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}