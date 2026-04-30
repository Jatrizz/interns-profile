import 'package:flutter/material.dart';
import 'lanyard.dart';
import 'card_helpers.dart';

class NathanielIDCard extends StatefulWidget {
  const NathanielIDCard({super.key});

  @override
  State<NathanielIDCard> createState() => _NathanielIDCardState();
}

class _NathanielIDCardState extends State<NathanielIDCard> {
  double _rotateX = 0;
  double _rotateY = 0;

  void _onHover(PointerEvent event) {
    const w = 260.0;
    const h = 390.0;
    final dx = (event.localPosition.dx - w / 2) / (w / 2);
    final dy = (event.localPosition.dy - h / 2) / (h / 2);
    setState(() {
      _rotateY = dx * 0.28;
      _rotateX = -dy * 0.22;
    });
  }

  void _onExit() => setState(() { _rotateX = 0; _rotateY = 0; });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const LanyardWidget(color: Color(0xFFb8960c), height: 90),
        MouseRegion(
          onHover: _onHover,
          onExit: (_) => _onExit(),
          child: GestureDetector(
            onTap: () => showNathanielProfileModal(context),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              curve: Curves.easeOut,
              transformAlignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(_rotateX)
                ..rotateY(_rotateY),
              child: const _NathanielCardFace(),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'TAP TO VIEW PROFILE',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 0.12,
            color: Colors.white.withOpacity(0.18),
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

  static const _gold = Color(0xFFc8a01e);
  static const _goldDim = Color(0xFFb8960c);
  static const _navy = Color.fromARGB(255, 58, 5, 5);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 390,
      decoration: BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _gold.withOpacity(0.18), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: _goldDim.withOpacity(0.18),
            offset: const Offset(0, 18),
            blurRadius: 44,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            offset: const Offset(0, 6),
            blurRadius: 18,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Ghost circle watermarks
            Positioned(
              bottom: -50, right: -50,
              child: Container(
                width: 180, height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _gold.withOpacity(0.07), width: 0.5),
                ),
              ),
            ),
            Positioned(
              bottom: -20, right: -20,
              child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _gold.withOpacity(0.04), width: 0.5),
                ),
              ),
            ),

            // Gold top stripe
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                height: 3,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6b4e00), Color(0xFFf0c040), Color(0xFF6b4e00)],
                  ),
                ),
              ),
            ),

            // Org strip
            Positioned(
              top: 14, left: 14, right: 14,
              child: Row(
                children: [
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: _gold.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: _gold.withOpacity(0.45), width: 0.5),
                    ),
                    child: const Center(
                      child: Text(
                        'FDS',
                        style: TextStyle(
                          fontSize: 5.5, fontWeight: FontWeight.w700,
                          color: Color(0xFFe8be38), letterSpacing: 0.4,
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
                          fontSize: 8, letterSpacing: 0.08,
                          color: Colors.white.withOpacity(0.45),
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        'INTERN · DEVELOPMENT UNIT',
                        style: TextStyle(
                          fontSize: 5.5, letterSpacing: 0.06,
                          color: _gold.withOpacity(0.6),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Floating photo — oversized, upper half, no background ────
            // Adjust `top` to reposition, `width`/`height` to resize freely.
            Positioned(
              top: 60,
              left: 0, right: 0,
              child: Center(
                child: SizedBox(
                  width: 220,
                  height: 120,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      'assets/images/nathan.png',
                      width: 220,
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                      errorBuilder: (_, __, ___) => Container(
                        width: 110,
                        height: 200,
                        decoration: BoxDecoration(
                          color: _gold.withOpacity(0.08),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(60),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'NR',
                            style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.w500,
                              color: _gold.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Thin rule under photo zone
            Positioned(
              bottom: 135, left: 14, right: 14,
              child: Row(
                children: [
                  Expanded(child: Container(height: 0.5, color: _gold.withOpacity(0.18))),
                  Container(
                    width: 4, height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: _gold),
                  ),
                  Expanded(child: Container(height: 0.5, color: _gold.withOpacity(0.18))),
                ],
              ),
            ),

            // Name + role
            Positioned(
              bottom: 155, left: 0, right: 0,
              child: Column(
                children: [
                  const Text(
                    'Nathaniel Velasco',
                    style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500,
                      color: Colors.white, letterSpacing: 0.15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8a6a00), Color(0xFFc8961a)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Backend Developer',
                      style: TextStyle(
                        fontSize: 8, fontWeight: FontWeight.w600,
                        color: Color(0xFF08101e), letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info rows
            Positioned(
              bottom: 80, left: 16, right: 16,
              child: Column(
                children: const [
                  _InfoRow(label: 'DEPARTMENT', value: 'Information Technology'),
                  SizedBox(height: 5),
                  _InfoRow(label: 'MEMBER SINCE', value: 'February 2026'),
                  SizedBox(height: 5),
                  _InfoRow(label: 'STATUS', value: '● ACTIVE', valueColor: Color(0xFF7fff90)),
                ],
              ),
            ),

            // Bottom ID strip
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: _gold.withOpacity(0.05),
                  border: Border(
                    top: BorderSide(color: _gold.withOpacity(0.15), width: 0.5),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'DEV-2026-180',
                      style: TextStyle(
                        fontSize: 7, fontFamily: 'monospace',
                        color: _gold.withOpacity(0.5), letterSpacing: 0.09,
                      ),
                    ),
                    const CardBarcode(),
                    Text(
                      'N. VELASCO',
                      style: TextStyle(
                        fontSize: 7, fontFamily: 'monospace',
                        color: _gold.withOpacity(0.5), letterSpacing: 0.09,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info row ──────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 6.5, letterSpacing: 0.09, color: Colors.white.withOpacity(0.25), fontFamily: 'monospace')),
        Text(value, style: TextStyle(fontSize: 7.5, fontFamily: 'monospace', fontWeight: FontWeight.w500, color: valueColor ?? Colors.white.withOpacity(0.65))),
      ],
    );
  }
}

// ── Profile modal ─────────────────────────────────────────────────────────────
void showNathanielProfileModal(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.75),
    builder: (ctx) => Dialog(
      backgroundColor: const Color.fromARGB(255, 61, 13, 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: SizedBox(
        width: 680,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF6b4e00), Color(0xFFf0c040), Color(0xFF6b4e00)]),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 22, 20, 18),
              child: Row(
                children: [
                  Container(
                    width: 68, height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFb8960c).withOpacity(0.45), width: 1),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/nathaniel.webp',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF0e1e38),
                          child: const Center(child: Text('NV', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Color(0xFFf0c040)))),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nathaniel Velasco', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white)),
                      const SizedBox(height: 3),
                      Text('Backend Developer · Information Technology', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.38))),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFb8960c).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFb8960c).withOpacity(0.3), width: 0.5),
                        ),
                        child: const Text('● Active', style: TextStyle(fontSize: 12, color: Color(0xFF7fff90))),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: Icon(Icons.close, color: Colors.white.withOpacity(0.25), size: 20),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.white.withOpacity(0.05), height: 0.5),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 18, 28, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _nSec('About'),
                    _nBody('Backend developer focused on scalable backend systems and clean, maintainable code. Structured engineering mindset, values precision and well-tested software.'),
                    _nSec('Details'),
                    _nGrid({'Email': 'nathanielvelasco0915@gmail.com', 'Member since': 'February 2026', 'ID': 'DEV-2026-180', 'Department': 'Development'}),
                    _nSec('Education'),
                    _nBody('BS Information Technology\nPamantasan ng Lungsod ng San Pablo'),
                    _nSec('Work Experience'),
                    _nWork('FDS ASYA PHILIPPINES INC.', 'Solutions Dev Intern — Backend Developer', 'Jan 2026 – Present'),
                    _nSec('Skills'),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: ['Flutter', 'Dart', 'Go', 'PostgreSQL', 'Docker', 'Git', 'REST APIs', 'System Design']
                          .map((s) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFb8960c).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFb8960c).withOpacity(0.25), width: 0.5),
                                ),
                                child: Text(s, style: const TextStyle(fontSize: 12, color: Color(0xFFe8be38))),
                              )).toList(),
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

Widget _nSec(String t) => Padding(
  padding: const EdgeInsets.only(top: 18, bottom: 9),
  child: Text(t.toUpperCase(), style: TextStyle(fontSize: 10, letterSpacing: 0.12, fontWeight: FontWeight.w600, color: const Color(0xFFb8960c).withOpacity(0.55))),
);

Widget _nBody(String t) => Text(t, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.55), height: 1.7));

Widget _nGrid(Map<String, String> items) => GridView.count(
  crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
  crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 3.5,
  children: items.entries.map((e) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
      color: const Color(0xFFb8960c).withOpacity(0.04),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFFb8960c).withOpacity(0.12), width: 0.5),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(e.key, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.28))),
      const SizedBox(height: 2),
      Text(e.value, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7), fontFamily: 'monospace')),
    ]),
  )).toList(),
);

Widget _nWork(String co, String pos, String period) => Container(
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: const Color(0xFFb8960c).withOpacity(0.04),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: const Color(0xFFb8960c).withOpacity(0.12), width: 0.5),
  ),
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(co, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
    const SizedBox(height: 3),
    Text(pos, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.42))),
    const SizedBox(height: 5),
    Text(period, style: TextStyle(fontSize: 11, fontFamily: 'monospace', color: const Color(0xFFb8960c).withOpacity(0.5))),
  ]),
);