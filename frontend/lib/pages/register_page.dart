import 'package:flutter/material.dart';
import 'package:interfaces/widgets/Homepage-Widgets/navbar.dart';
import 'package:interfaces/widgets/Register-Widgets/hero_section.dart';

class RegisterPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  const RegisterPage(
      {super.key, required this.isDarkMode, required this.onToggleTheme});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
        activePage: 'Register',
        scaffoldKey: _scaffoldKey,
      ),
      endDrawer: NavDrawer(
        isDarkMode: widget.isDarkMode,
        onToggleTheme: widget.onToggleTheme,
        activePage: 'Register',
      ),
      body: ListView(
        children: [
          HeroSection(
            isDarkMode: widget.isDarkMode,
            onToggleTheme: widget.onToggleTheme,
          ),
        ],
      ),
    );
  }
}
