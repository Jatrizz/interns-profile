import 'package:flutter/material.dart';
import 'package:interfaces/widgets/Homepage-Widgets/stats_section.dart';
import '../widgets/Homepage-Widgets/navbar.dart';
import '../widgets/Homepage-Widgets/hero_section.dart';
import '../widgets/Homepage-Widgets/features_section.dart';
import '../widgets/Homepage-Widgets/footer.dart';
import '../widgets/Homepage-Widgets/prefooter.dart';

class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  const HomePage(
      {super.key, required this.isDarkMode, required this.onToggleTheme});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor:
          widget.isDarkMode ? Colors.black : const Color(0xFFF5F6FA),
      appBar: NavBar(
        isDarkMode: widget.isDarkMode,
        onToggleTheme: widget.onToggleTheme,
        activePage: 'Home',
        scaffoldKey: _scaffoldKey,
      ),
      endDrawer: NavDrawer(
        isDarkMode: widget.isDarkMode,
        onToggleTheme: widget.onToggleTheme,
        activePage: 'Home',
      ),
      body: ListView(
        children: [
          HeroSection(
            isDarkMode: widget.isDarkMode,
            onToggleTheme: widget.onToggleTheme,
          ),
          FeaturesSection(isDarkMode: widget.isDarkMode),
          StatsSection(isDarkMode: widget.isDarkMode),
          PreFooter(isDarkMode: widget.isDarkMode),
          Footer(isDarkMode: widget.isDarkMode),
        ],
      ),
    );
  }
}
