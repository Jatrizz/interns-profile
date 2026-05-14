import 'package:flutter/material.dart';
import '../widgets/Intern-Dashboard-Widgets/intern_sidebar.dart';
import '../widgets/Intern-Dashboard-Widgets/intern_topbar.dart';
import 'intern_dashboard.dart';
import 'intern_time_logs.dart';
import 'intern_my_profile.dart';
import 'developer_team_page.dart';
import 'package:go_router/go_router.dart';
import '../utils/session_storage.dart';

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
  int selectedIndex = 0;

  Future<void> handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            widget.isDarkMode ? const Color(0xFF242424) : Colors.white,
        title: Text(
          'Logout',
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
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
    clearSession();
    if (!mounted) return;
    context.go('/');
  }

  Widget _buildPage() {
    switch (selectedIndex) {
      case 0:
        return InternDashboardPage(
          firstName: widget.firstName,
          userId: widget.userId,
          isDarkMode: widget.isDarkMode,
        );
      case 1:
        return InternMyProfilePage(
          isDarkMode: widget.isDarkMode,
          firstName: widget.firstName,
          userId: widget.userId,
        );
      case 2:
        return InternTimeLogsPage(
          firstName: widget.firstName,
          userId: widget.userId,
          isDarkMode: widget.isDarkMode,
        );
      case 3:
        return DeveloperTeamPage(isDarkMode: widget.isDarkMode);
      default:
        return InternDashboardPage(
          firstName: widget.firstName,
          userId: widget.userId,
          isDarkMode: widget.isDarkMode,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          widget.isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      body: Row(
        children: [
          InternSidebar(
            isDarkMode: widget.isDarkMode,
            selectedIndex: selectedIndex,
            onLogout: handleLogout,
            firstName: widget.firstName,
            onItemSelected: (index) => setState(() => selectedIndex = index),
          ),
          Expanded(
            child: Column(
              children: [
                InternTopBar(
                  isDarkMode: widget.isDarkMode,
                  firstName: widget.firstName,
                  onToggleDarkMode: widget.onToggleTheme,
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
