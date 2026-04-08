import 'package:flutter/material.dart';

class HeroSectionAbout extends StatelessWidget {
  const HeroSectionAbout({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      color: Colors.blueGrey,
      child: const Center(
        child: Text(
          'About Us',
          style: TextStyle(fontSize: 32, color: Colors.white),
        ),
      ),
    );
  }
}
