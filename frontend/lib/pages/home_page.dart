import 'package:flutter/material.dart';
import '../widgets/Homepage-Widgets/navbar.dart';
import '../widgets/Homepage-Widgets/hero_section.dart';
import '../widgets/Homepage-Widgets/features_section.dart';
import '../widgets/Homepage-Widgets/stats_section.dart';
import '../widgets/Homepage-Widgets/footer.dart';
import '../widgets/Homepage-Widgets/prefooter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView(
        children: [
          NavBar(),
          HeroSection(),
          FeaturesSection(),
          StatsSection(),
          PreFooter(),
          Footer(),
        ],
      ),
    );
  }
}