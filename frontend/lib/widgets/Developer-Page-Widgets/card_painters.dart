import 'dart:math';
import 'package:flutter/material.dart';

class StarPainter extends CustomPainter {
  final Color color;
  const StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    const points = 5;
    final outerR = size.width / 2;
    final innerR = outerR * 0.4;
    for (int i = 0; i < points * 2; i++) {
      final angle = (pi / points) * i - pi / 2;
      final r = i.isEven ? outerR : innerR;
      final x = cx + r * cos(angle);
      final y = cy + r * sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class LeafPainter extends CustomPainter {
  final Color color;
  const LeafPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width * 0.5, 2)
      ..cubicTo(size.width * 0.85, size.height * 0.15, size.width * 0.95,
          size.height * 0.45, size.width * 0.82, size.height * 0.83)
      ..cubicTo(size.width * 0.68, size.height * 1.0, size.width * 0.25,
          size.height * 0.95, size.width * 0.14, size.height * 0.67)
      ..cubicTo(size.width * 0.04, size.height * 0.38, size.width * 0.15,
          size.height * 0.12, size.width * 0.5, 2)
      ..close();
    canvas.drawPath(path, paint);
    final veinPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(size.width * 0.5, 4),
      Offset(size.width * 0.48, size.height * 0.9),
      veinPaint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
