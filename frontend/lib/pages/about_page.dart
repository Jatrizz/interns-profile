import 'package:flutter/material.dart';
import 'package:interfaces/widgets/Aboutpage-Widgets/about_intro.dart';
// import 'package:interfaces/widgets/Aboutpage-Widgets/getready_about.dart';
import 'package:interfaces/widgets/Aboutpage-Widgets/herosection_about.dart';
import 'package:interfaces/widgets/Aboutpage-Widgets/team_section.dart';
import '../widgets/Homepage-Widgets/navbar.dart';
import '../widgets/Homepage-Widgets/footer.dart';

class AboutPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  const AboutPage({super.key, required this.isDarkMode, required this.onToggleTheme});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  late bool isDarkMode;

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode;
  }

  void _toggle() => setState(() => isDarkMode = !isDarkMode);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFFF5F6FA),
      appBar: NavBar(isDarkMode: isDarkMode, onToggleTheme: _toggle),
      body: ListView(
        children: [
          HerosectionAbout(isDarkMode: isDarkMode),
          const SizedBox(height: 50),
          AboutIntro(isDarkMode: isDarkMode),
          TeamSection(isDarkMode: isDarkMode),
          const SizedBox(height: 30),
          Footer(isDarkMode: isDarkMode),
        ],
      ),
    );
  }
}
