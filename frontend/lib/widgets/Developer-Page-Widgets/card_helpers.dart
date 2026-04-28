import 'package:flutter/material.dart';
import 'card_painters.dart';

class Blob extends StatelessWidget {
  final double width, height;
  final Color color;
  final BorderRadius borderRadius;

  const Blob({
    super.key,
    required this.width,
    required this.height,
    required this.color,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: color, borderRadius: borderRadius),
    );
  }
}

class CardStar extends StatelessWidget {
  final double size;
  final Color color;

  const CardStar({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: StarPainter(color: color),
    );
  }
}

class CardLeaf extends StatelessWidget {
  final Color color;

  const CardLeaf({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(44, 50),
      painter: LeafPainter(color: color),
    );
  }
}

class CardField extends StatelessWidget {
  final String label, value;
  final Color? valueColor;

  const CardField({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 7.5,
              letterSpacing: 0.07,
              color: Colors.white.withOpacity(0.28),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 8,
              color: valueColor ?? Colors.white.withOpacity(0.65),
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class CardBarcode extends StatelessWidget {
  final List<int> widths = const [
    1,
    2,
    1,
    3,
    1,
    2,
    2,
    1,
    3,
    1,
    2,
    1,
    1,
    3,
    2,
    1,
    1,
    2,
    1,
    2,
    1,
    3,
    1,
    1,
    2
  ];

  const CardBarcode({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widths
          .map((w) => Container(
                width: w * 2.0,
                height: 14,
                margin: const EdgeInsets.symmetric(horizontal: 0.75),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(1),
                ),
              ))
          .toList(),
    );
  }
}
