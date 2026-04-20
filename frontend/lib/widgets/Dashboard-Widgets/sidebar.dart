import 'package:flutter/material.dart';
import 'package:interfaces/pages/dashboard.dart';
import 'package:interfaces/pages/interns_list.dart';
import 'package:interfaces/pages/dashboard.dart';

class Sidebar extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onLogout;

  const Sidebar({
    super.key,
    required this.isDarkMode,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 65,
      color: isDarkMode ? const Color(0xFF242424) : const Color(0xFFF0F0F0),
      child: Column(
        children: [
          const SizedBox(height: 5),
          Image.asset(
            'assets/images/logo.png',
            width: 65,
            height: 65,
            errorBuilder: (c, e, s) => Container(
              width: 65,
              height: 65,
              decoration: const BoxDecoration(
                color: Color(0xFF00BFFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.circle,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(height: 15),
          _buildIcon(
            context,
            Icons.grid_view,
            false,
            'Dashboard',
            () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      DashboardOverviewPage(
                    firstName: '',
                  ),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
            isDarkMode,
          ),
          const SizedBox(height: 10),
          _buildIcon(
            context,
            Icons.person_outline,
            false,
            'Interns',
            () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      InternsList(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
            isDarkMode,
          ),
          const SizedBox(height: 10),
          _buildIcon(
            context,
            Icons.access_time_outlined,
            false,
            'Time Logs',
            () {},
            isDarkMode,
          ),
          const SizedBox(height: 10),
          Divider(
            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            thickness: 1,
            indent: 10,
            endIndent: 10,
          ),
          const SizedBox(height: 10),
          _buildIcon(
            context,
            Icons.groups_outlined,
            false,
            'Developers Team',
            () {},
            isDarkMode,
          ),
          const Spacer(),
          _buildIcon(
            context,
            Icons.logout,
            false,
            'Logout',
            onLogout,
            isDarkMode,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildIcon(
    BuildContext context,
    IconData icon,
    bool isActive,
    String tooltip,
    VoidCallback? onTap,
    bool isDarkMode,
  ) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive
                  ? (isDarkMode ? Colors.grey[700] : Colors.grey[300])
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isDarkMode ? Colors.white : Colors.black54,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
