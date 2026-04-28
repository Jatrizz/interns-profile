import 'package:flutter/material.dart';
import 'lanyard_painters.dart';

class LanyardWidget extends StatelessWidget {
  final Color color;
  final double height;

  const LanyardWidget({super.key, required this.color, required this.height});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 20,
          height: height - 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.6),
                color,
                color.withOpacity(0.6),
              ],
            ),
          ),
        ),
        CustomPaint(
          size: const Size(24, 22),
          painter: DRingPainter(),
        ),
        CustomPaint(
          size: const Size(14, 16),
          painter: ClipPainter(),
        ),
      ],
    );
  }
}
