import 'package:flutter/material.dart';
import 'package:interfaces/widgets/Homepage-Widgets/stats_section.dart';
import '../widgets/Homepage-Widgets/navbar.dart';
import '../widgets/Homepage-Widgets/hero_section.dart';
import '../widgets/Homepage-Widgets/features_section.dart';
// import '../widgets/Homepage-Widgets/stats_section.dart';
import '../widgets/Homepage-Widgets/footer.dart';
import '../widgets/Homepage-Widgets/prefooter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: NavBar(),
      body: ListView(
        children: [
          HeroSection(),
          FeaturesSection(),
          StatsSection(
            interns: 5,
            schools: 4,
            programs: 5,
          ),
          PreFooter(),
          Footer(),
        ],
      ),
    );
  }
}