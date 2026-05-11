import 'package:flutter/material.dart';
import '../widgets/Dashboard-Widgets/sidebar.dart';
import '../widgets/Dashboard-Widgets/top_bar.dart';
import 'dashboard.dart';
import 'time_logs.dart';
import 'interns_list.dart';
import 'intern_profile_page.dart';
import 'developer_team_page.dart';
import 'package:go_router/go_router.dart';
import '../utils/session_storage.dart';

class AdminMainPage extends StatefulWidget {
  final String firstName;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const AdminMainPage({
    super.key,
    required this.firstName,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  late bool isDarkMode;
  int selectedIndex = 0;
  dynamic selectedIntern;

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode;
  }

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

    clearSession();

    if (!mounted) return;
    context.go('/');
  }

  Widget _buildPage() {
    if (selectedIntern != null) {
      return InternProfileBody(
        intern: selectedIntern,
        isDarkMode: isDarkMode,
        onBack: () {
          setState(() {
            selectedIntern = null;
          });
        },
      );
    }

    switch (selectedIndex) {
      case 0:
        return DashboardOverviewPage(
          firstName: widget.firstName,
          isDarkMode: isDarkMode,
        );
      case 1:
        return InternsList(
          isDarkMode: isDarkMode,
          onViewProfile: (intern) {
            setState(() {
              selectedIntern = intern;
            });
          },
        );
      case 2:
        return TimeLogsPage(
          firstName: widget.firstName,
          isDarkMode: isDarkMode,
        );
      case 3:
        return DeveloperTeamPage(isDarkMode: isDarkMode);
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
            onItemSelected: (index) => setState(() {
              selectedIndex = index;
              selectedIntern = null;
            }),
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