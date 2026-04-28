import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:interfaces/pages/login_page.dart';
import '../widgets/Intern-Dashboard-Widgets/intern_sidebar.dart';
import '../widgets/Intern-Dashboard-Widgets/intern_topbar.dart';
import 'intern_dashboard.dart';
import 'intern_time_logs.dart';
import 'intern_my_profile.dart';
import 'developer_team_page.dart';

class InternMainPage extends StatefulWidget {
  final String firstName;
  final String userId;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  const InternMainPage({
    super.key,
    required this.firstName,
    required this.userId,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<InternMainPage> createState() => _InternMainPageState();
}

class _InternMainPageState extends State<InternMainPage> {
  late bool isDarkMode;

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode;
  }

  int selectedIndex = 0;

  Future<void> handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF242424) : Colors.white,
        title: Text(
          'Logout',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => LoginPage(
          isDarkMode: isDarkMode,
          onToggleTheme: () => setState(() => isDarkMode = !isDarkMode),
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  // Swap page content based on selectedIndex
  Widget _buildPage() {
    switch (selectedIndex) {
      case 0:
        return InternDashboardPage(
          firstName: widget.firstName,
          userId: widget.userId, // add this
          isDarkMode: isDarkMode, // pass dark mode state
        );
      case 1:
        return InternMyProfilePage(
          isDarkMode: isDarkMode,
          firstName: widget.firstName,
          userId: widget.userId,
        );
      case 2:
        return InternTimeLogsPage(
          firstName: widget.firstName,
          userId: widget.userId,
          isDarkMode: isDarkMode,
        );
      case 3:
        return const DeveloperTeamPage();
      default:
        return InternDashboardPage(
          firstName: widget.firstName,
          userId: widget.userId, // add this
          isDarkMode: isDarkMode, // pass dark mode state
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      body: Row(
        children: [
          InternSidebar(
            isDarkMode: isDarkMode,
            selectedIndex: selectedIndex,
            onLogout: handleLogout,
            firstName: widget.firstName,
            onItemSelected: (index) => setState(() => selectedIndex = index),
          ),
          Expanded(
            child: Column(
              children: [
                InternTopBar(
                  isDarkMode: isDarkMode,
                  firstName: widget.firstName,
                  onToggleDarkMode: () =>
                      setState(() => isDarkMode = !isDarkMode),
                ),
                Expanded(child: _buildPage()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
