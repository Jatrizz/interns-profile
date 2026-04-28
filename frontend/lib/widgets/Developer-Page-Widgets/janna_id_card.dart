import 'package:flutter/material.dart';
import 'lanyard.dart';
import 'card_helpers.dart';
import 'janna_profile_modal.dart';

class JannaIDCard extends StatefulWidget {
  const JannaIDCard({super.key});

  @override
  State<JannaIDCard> createState() => _JannaIDCardState();
}

class _JannaIDCardState extends State<JannaIDCard> {
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

  void _onExit() {
    setState(() {
      _rotateX = 0;
      _rotateY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const LanyardWidget(color: Color(0xFF3b82f6), height: 90),
        MouseRegion(
          onHover: _onHover,
          onExit: (_) => _onExit(),
          child: GestureDetector(
            onTap: () => showProfileModal(context),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              curve: Curves.easeOut,
              transformAlignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(_rotateX)
                ..rotateY(_rotateY),
              child: const _JannaCardFace(),
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

class _JannaCardFace extends StatelessWidget {
  const _JannaCardFace();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 390, // back to original — image no longer affects this
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3b82f6).withOpacity(0.25),
            offset: const Offset(0, 20),
            blurRadius: 50,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          clipBehavior:
              Clip.none, // allows image to overflow card edges if needed
          children: [
            // Orange circle accent top right
            Positioned(
              top: -14,
              right: -18,
              child: Container(
                width: 130,
                height: 130,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFe85d20),
                ),
              ),
            ),
            // Bottom blobs
            Positioned(
              bottom: 65,
              left: -14,
              child: Blob(
                width: 70,
                height: 56,
                color: const Color(0xFFe85d20),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(44),
                ),
              ),
            ),
            Positioned(
              bottom: 52,
              right: -12,
              child: Blob(
                width: 60,
                height: 46,
                color: const Color(0xFF00bcd4),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(40),
                  bottomLeft: Radius.circular(44),
                  bottomRight: Radius.circular(24),
                ),
              ),
            ),
            Positioned(
              bottom: 90,
              left: 36,
              child: Blob(
                width: 38,
                height: 30,
                color: const Color(0xFFf06292),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            Positioned(
              bottom: 86,
              right: 34,
              child: Blob(
                width: 28,
                height: 22,
                color: const Color(0xFFffca28),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            // Leaf
            Positioned(
              top: -4,
              right: 4,
              child: const CardLeaf(color: Color(0xFF4caf50)),
            ),
            // Pink blob top left
            Positioned(
              top: 8,
              left: 6,
              child: Blob(
                width: 24,
                height: 24,
                color: const Color(0xFFf06292),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(14),
                ),
              ),
            ),
            // Stars
            const Positioned(
                top: 62,
                right: 16,
                child: CardStar(size: 20, color: Color(0xFFffca28))),
            const Positioned(
                top: 50,
                left: 20,
                child: CardStar(size: 14, color: Colors.white)),
            const Positioned(
                bottom: 82,
                right: 24,
                child: CardStar(size: 16, color: Color(0xFF00bcd4))),
            const Positioned(
                bottom: 70,
                left: 16,
                child: CardStar(size: 22, color: Color(0xFFffca28))),
            const Positioned(
                bottom: 96,
                right: 52,
                child: CardStar(size: 11, color: Color(0xFFf06292))),
            const Positioned(
                top: 130,
                right: 10,
                child: CardStar(size: 10, color: Colors.white)),

            // Card content (text + info fields) — no image here anymore
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DEV TEAM · COMPUTER SCIENCE',
                    style: TextStyle(
                      fontSize: 8,
                      letterSpacing: 0.13,
                      color: Colors.white.withOpacity(0.35),
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Janna\nPujeda',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Full-stack Developer',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ),
                  // Spacer pushes info fields to the bottom
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.only(top: 8),
                    decoration: const BoxDecoration(
                      border: Border(
                          top: BorderSide(color: Colors.white12, width: 0.5)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CardField(
                            label: 'Dept', value: 'Computer Science'),
                        const CardField(label: 'Since', value: 'Jan 2022'),
                        const CardField(
                          label: 'Status',
                          value: '● Active',
                          valueColor: Color(0xFF7fff90),
                        ),
                        const SizedBox(height: 6),
                        const CardBarcode(),
                        const SizedBox(height: 4),
                        Text(
                          'DEV-2026-007 · JANNA PUJEDA',
                          style: TextStyle(
                            fontSize: 7,
                            fontFamily: 'monospace',
                            color: Colors.white.withOpacity(0.18),
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // IMAGE AS OVERLAY — change size freely, nothing else moves
            // Adjust `top` to reposition vertically on the card
            Positioned(
              top: -450, // move image up/down by changing this
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/images/janna.png',
                  width: 1300, // change freely — no overflow risk ever
                  height: 1300, // change freely — no overflow risk ever
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    width: 1300,
                    height: 1300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1e3a5f),
                      border: Border.all(
                          color: const Color(0xFF3b82f6).withOpacity(0.3),
                          width: 2),
                    ),
                    child: const Center(
                      child: Text(
                        'JA',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF93c5fd),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
