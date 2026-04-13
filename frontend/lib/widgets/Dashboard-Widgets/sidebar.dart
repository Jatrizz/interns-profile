import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onTeamTap;

  const Sidebar({super.key, required this.isDarkMode, required this.onTeamTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 65,
      color: isDarkMode ? const Color(0xFF242424) : const Color(0xFFF0F0F0),
      child: Column(
        children: [
          const SizedBox(height: 15),
          Image.asset(
            'assets/images/logo.png',
            width: 36,
            height: 36,
            errorBuilder: (c, e, s) => Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF00BFFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.circle, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(height: 15),
          _buildIcon(Icons.grid_view, true, 'Dashboard', null, isDarkMode),
          const SizedBox(height: 10),
          _buildIcon(Icons.person_outline, false, 'Interns', null, isDarkMode),
          const SizedBox(height: 10),
          _buildIcon(
            Icons.groups_outlined,
            false,
            'Our Team',
            onTeamTap,
            isDarkMode,
          ),
          const Spacer(),
          _buildIcon(Icons.logout, false, 'Logout', null, isDarkMode),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildIcon(
    IconData icon,
    bool isActive,
    String tooltip,
    VoidCallback? onTap,
    bool isDarkMode,
  ) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
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
