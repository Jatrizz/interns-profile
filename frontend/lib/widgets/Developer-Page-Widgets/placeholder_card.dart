import 'package:flutter/material.dart';
import 'lanyard.dart';

class PlaceholderCard extends StatelessWidget {
  const PlaceholderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const LanyardWidget(color: Color(0xFF334155), height: 90),
        Container(
          width: 260,
          height: 390,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.07),
              width: 1,
            ),
            color: Colors.white.withOpacity(0.02),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.person_outline,
                  color: Colors.white.withOpacity(0.12),
                  size: 28,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                "Groupmate",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.12),
                  letterSpacing: 0.05,
                  height: 1.7,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'COMING SOON',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 0.12,
            color: Colors.white.withOpacity(0.1),
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
