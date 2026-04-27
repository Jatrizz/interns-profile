import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const InternsProfile());
}

class InternsProfile extends StatefulWidget {
  const InternsProfile({super.key});

  @override
  State<InternsProfile> createState() => _InternsProfileState();
}

class _InternsProfileState extends State<InternsProfile> {
  bool isDarkMode = true;

  void _toggleTheme() => setState(() => isDarkMode = !isDarkMode);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: isDarkMode 
          ? Colors.black : const Color(0xFFF7F9FC),
      ),
      title: 'Intern\'s Profile',
      home: HomePage(isDarkMode: isDarkMode, onToggleTheme: _toggleTheme),
    );
  }
}