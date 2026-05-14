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
        activePage: 'Login',
        scaffoldKey: _scaffoldKey,
      ),
      endDrawer: NavDrawer(
        isDarkMode: widget.isDarkMode,
        onToggleTheme: widget.onToggleTheme,
        activePage: 'Login',
      ),
      body: ListView(
        children: [
          Login(
            isDarkMode: widget.isDarkMode,
            onToggleTheme: widget.onToggleTheme,
          ),
        ],
      ),
    );
  }
}
