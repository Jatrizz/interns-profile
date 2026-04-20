import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:interfaces/pages/login_page.dart';
import '../widgets/Dashboard-Widgets/sidebar.dart';
import '../widgets/Dashboard-Widgets/top_bar.dart';
import 'dashboard.dart';
import 'time_logs.dart';
import 'interns_list.dart';

class AdminMainPage extends StatefulWidget {
  final String firstName;

  const AdminMainPage({super.key, required this.firstName});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  bool isDarkMode = true;
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
        pageBuilder: (_, __, ___) => const LoginPage(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  Widget _buildPage() {
    switch (selectedIndex) {
      case 0:
        return DashboardOverviewPage(
          firstName: widget.firstName,
          isDarkMode: isDarkMode,
        );
      case 1:
        return InternsList(
          isDarkMode: isDarkMode,
        );
      case 2:
        return TimeLogsPage(
          firstName: widget.firstName,
          isDarkMode: isDarkMode,
        );
      case 3:
        return const Center(
            child:
                Text('Developers Team', style: TextStyle(color: Colors.white)));
      default:
        return DashboardOverviewPage(
          firstName: widget.firstName,
          isDarkMode: isDarkMode,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      body: Row(
        children: [
          Sidebar(
            isDarkMode: isDarkMode,
            selectedIndex: selectedIndex,
            onLogout: handleLogout,
            onItemSelected: (index) => setState(() => selectedIndex = index),
          ),
          Expanded(
            child: Column(
              children: [
                TopBar(
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
