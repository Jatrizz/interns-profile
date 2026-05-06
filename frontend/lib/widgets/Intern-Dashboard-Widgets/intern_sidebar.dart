import 'package:flutter/material.dart';

class InternSidebar extends StatelessWidget {
  final bool isDarkMode;
  final int selectedIndex;
  final VoidCallback onLogout;
  final ValueChanged<int> onItemSelected;
  final String firstName;

  const InternSidebar({
    super.key,
    required this.isDarkMode,
    required this.selectedIndex,
    required this.onLogout,
    required this.onItemSelected,
    required this.firstName,
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
            isDarkMode
                ? 'assets/images/logo_dark.png'
                : 'assets/images/logo_light.png',
            width: 60,
            height: 60,
            errorBuilder: (c, e, s) => Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFF00BFFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.circle, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(height: 15),
          _buildIcon(
            icon: Icons.grid_view,
            index: 0,
            tooltip: 'Dashboard',
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 10),
          _buildIcon(
            icon: Icons.person_outline,
            index: 1,
            tooltip: 'My Profile',
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 10),
          _buildIcon(
            icon: Icons.access_time_outlined,
            index: 2,
            tooltip: 'Time Logs',
            isDarkMode: isDarkMode,
            // removed Navigator.push — InternMainPage handles this now
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
            icon: Icons.groups_outlined,
            index: 3,
            tooltip: 'Developers Team',
            isDarkMode: isDarkMode,
          ),
          const Spacer(),
          _buildIcon(
            icon: Icons.logout,
            index: -1,
            tooltip: 'Logout',
            isDarkMode: isDarkMode,
            onTap: onLogout,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildIcon({
    required IconData icon,
    required int index,
    required String tooltip,
    required bool isDarkMode,
    VoidCallback? onTap,
  }) {
    final isActive = selectedIndex == index && index != -1;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap ?? () => onItemSelected(index),
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
    );
  }
}
