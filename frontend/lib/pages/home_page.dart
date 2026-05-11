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
  late bool isDarkMode;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode;
  }

  void _toggle() => setState(() => isDarkMode = !isDarkMode);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFFF5F6FA),
      appBar: NavBar(
          isDarkMode: isDarkMode,
          onToggleTheme: _toggle,
          activePage: 'Home',
          scaffoldKey: _scaffoldKey),
      endDrawer: NavDrawer(
          isDarkMode: isDarkMode, onToggleTheme: _toggle, activePage: 'Home'),
      body: ListView(
        children: [
          HeroSection(isDarkMode: isDarkMode, onToggleTheme: _toggle),
          FeaturesSection(isDarkMode: isDarkMode),
          StatsSection(isDarkMode: isDarkMode),
          PreFooter(isDarkMode: isDarkMode),
          Footer(isDarkMode: isDarkMode),
        ],
      ),
    );
  }
}
