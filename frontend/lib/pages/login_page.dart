import 'package:flutter/material.dart';
import 'package:interfaces/widgets/Homepage-Widgets/navbar.dart';
import 'package:interfaces/widgets/Login-Widgets/login.dart';

class LoginPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  const LoginPage(
      {super.key, required this.isDarkMode, required this.onToggleTheme});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
          activePage: 'Login',
          scaffoldKey: _scaffoldKey),
      endDrawer: NavDrawer(
          isDarkMode: isDarkMode, onToggleTheme: _toggle, activePage: 'Login'),
      body: ListView(
          children: [Login(isDarkMode: isDarkMode, onToggleTheme: _toggle)]),
    );
  }
}
