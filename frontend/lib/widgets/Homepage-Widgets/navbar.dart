import 'package:flutter/material.dart';
import 'package:interfaces/pages/contact_page.dart';
import 'package:interfaces/pages/home_page.dart';
import 'package:interfaces/pages/login_page.dart';
import '../../pages/about_page.dart';
import '../../pages/register_page.dart';

class NavBar extends StatefulWidget implements PreferredSizeWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final String activePage;

  const NavBar({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    this.activePage = 'Home',
  });

  @override
  Size get preferredSize => const Size.fromHeight(95);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  String? _hoveredItem;

  Widget _navLink(String label, VoidCallback onTap) {
    final isHovered = _hoveredItem == label;
    final isActive = widget.activePage == label;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredItem = label),
      onExit: (_) => setState(() => _hoveredItem = null),
      child: TextButton(
        onPressed: onTap,
        style: ButtonStyle(
            overlayColor: WidgetStateProperty.all(Colors.transparent)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 150),
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    isActive || isHovered ? FontWeight.bold : FontWeight.normal,
                color: isActive
                    ? const Color(0xFF2563EB)
                    : isHovered
                        ? (widget.isDarkMode ? Colors.white : Colors.black)
                        : (widget.isDarkMode
                            ? Colors.grey[400]!
                            : Colors.grey[600]!),
              ),
              child: Text(label),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 2,
              width: isActive || isHovered ? 20 : 0,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF2563EB)
                    : (widget.isDarkMode ? Colors.white : Colors.black),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _authButton(String label, VoidCallback onTap,
      {bool isPrimary = false}) {
    final isHovered = _hoveredItem == label;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredItem = label),
      onExit: (_) => setState(() => _hoveredItem = null),
      child: TextButton(
        onPressed: onTap,
        style: ButtonStyle(
            overlayColor: WidgetStateProperty.all(Colors.transparent)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: isPrimary
                ? (isHovered
                    ? const Color(0xFF1D4ED8)
                    : const Color(0xFF2563EB))
                : (isHovered
                    ? (widget.isDarkMode ? Colors.white12 : Colors.black12)
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
            border: isPrimary
                ? null
                : Border.all(
                    color: isHovered
                        ? (widget.isDarkMode ? Colors.white54 : Colors.black54)
                        : (widget.isDarkMode ? Colors.white24 : Colors.black26),
                  ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isPrimary
                  ? Colors.white
                  : (widget.isDarkMode ? Colors.white : Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
      toolbarHeight: 95,
      scrolledUnderElevation: 0,
      title: Padding(
        padding: EdgeInsetsGeometry.only(left: 50, right: 50),
        child: Row(
          children: [
            _navLink(
                'Home',
                () => Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, _, __) => HomePage(
                          isDarkMode: widget.isDarkMode,
                          onToggleTheme: widget.onToggleTheme),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ))),
            SizedBox(width: 60),
            _navLink(
                'About',
                () => Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, _, __) => AboutPage(
                          isDarkMode: widget.isDarkMode,
                          onToggleTheme: widget.onToggleTheme),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ))),
            SizedBox(width: 60),
            _navLink(
                'Contact',
                () => Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, _, __) => ContactPage(
                          isDarkMode: widget.isDarkMode,
                          onToggleTheme: widget.onToggleTheme),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ))),
            Spacer(),
            _authButton(
                'Login',
                () => Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, _, __) => LoginPage(
                          isDarkMode: widget.isDarkMode,
                          onToggleTheme: widget.onToggleTheme),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ))),
            SizedBox(width: 40),
            _authButton(
                'Register',
                () => Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, _, __) => RegisterPage(
                          isDarkMode: widget.isDarkMode,
                          onToggleTheme: widget.onToggleTheme),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    )),
                isPrimary: true),
            SizedBox(width: 40),
            IconButton(
              onPressed: widget.onToggleTheme,
              icon: Icon(
                  widget.isDarkMode
                      ? Icons.nightlight_round
                      : Icons.wb_sunny_outlined,
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                  size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
