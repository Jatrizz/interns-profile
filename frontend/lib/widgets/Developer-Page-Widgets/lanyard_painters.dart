import 'dart:math';
import 'package:flutter/material.dart';

class DRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFb0b0b0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final rect = Rect.fromLTWH(2, 0, size.width - 4, size.height - 2);
    canvas.drawArc(rect, pi, pi, false, paint);
    canvas.drawLine(
      Offset(2, size.height / 2),
      Offset(size.width - 2, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class ClipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFa0a0a0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      const Radius.circular(2),
    );
    canvas.drawRRect(rrect, paint);
    canvas.drawLine(
      Offset(size.width / 2, 3),
      Offset(size.width / 2, size.height - 3),
      paint
        ..color = const Color(0xFFbbbbbb)
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
