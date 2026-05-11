import 'package:flutter/material.dart';
import 'package:interfaces/pages/contact_page.dart';
import 'package:interfaces/pages/home_page.dart';
import 'package:interfaces/pages/login_page.dart';
import '../../pages/about_page.dart';
import '../../pages/register_page.dart';

class NavDrawer extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final String activePage;

  const NavDrawer({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.activePage,
  });

  void _go(BuildContext context, Widget page) {
    Navigator.of(context).pop();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  Widget _item(BuildContext context, String label, Widget page,
      {bool isPrimary = false}) {
    final isActive = activePage == label;
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isPrimary || isActive
              ? const Color(0xFF2563EB)
              : (isDarkMode ? Colors.white : Colors.black),
        ),
      ),
      onTap: () => _go(context, page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      child: ListView(
        padding: const EdgeInsets.only(top: 60),
        children: [
          _item(context, 'Home',
              HomePage(isDarkMode: isDarkMode, onToggleTheme: onToggleTheme)),
          _item(context, 'About',
              AboutPage(isDarkMode: isDarkMode, onToggleTheme: onToggleTheme)),
          _item(
              context,
              'Contact',
              ContactPage(
                  isDarkMode: isDarkMode, onToggleTheme: onToggleTheme)),
          const Divider(),
          _item(context, 'Login',
              LoginPage(isDarkMode: isDarkMode, onToggleTheme: onToggleTheme)),
          _item(
            context,
            'Register',
            RegisterPage(isDarkMode: isDarkMode, onToggleTheme: onToggleTheme),
            isPrimary: true,
          ),
        ],
      ),
    );
  }
}

class NavBar extends StatefulWidget implements PreferredSizeWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final String activePage;
  final GlobalKey<ScaffoldState>? scaffoldKey; // ← add this

  const NavBar({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    this.activePage = 'Home',
    this.scaffoldKey, // ← add this
  });

  @override
  Size get preferredSize => const Size.fromHeight(95);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  String? _hoveredItem;

  void _go(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  Widget _navLink(BuildContext context, String label, Widget page) {
    final isHovered = _hoveredItem == label;
    final isActive = widget.activePage == label;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredItem = label),
      onExit: (_) => setState(() => _hoveredItem = null),
      child: TextButton(
        onPressed: () => _go(context, page),
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

  Widget _authButton(BuildContext context, String label, Widget page,
      {bool isPrimary = false}) {
    final isHovered = _hoveredItem == label;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredItem = label),
      onExit: (_) => setState(() => _hoveredItem = null),
      child: TextButton(
        onPressed: () => _go(context, page),
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
    final isMobile = MediaQuery.of(context).size.width < 1024;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
      toolbarHeight: 95,
      scrolledUnderElevation: 0,
      actions: isMobile
          ? [
              IconButton(
                onPressed: widget.onToggleTheme,
                icon: Icon(
                  widget.isDarkMode
                      ? Icons.nightlight_round
                      : Icons.wb_sunny_outlined,
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                  size: 20,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.menu,
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
                // ← directly open via scaffoldKey, no Builder needed
                onPressed: () =>
                    widget.scaffoldKey?.currentState?.openEndDrawer(),
              ),
            ]
          : const [SizedBox.shrink()],
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: isMobile
            ? Text(
                'InTurn',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
              )
            : Builder(
                builder: (ctx) => Row(
                  children: [
                    _navLink(
                        ctx,
                        'Home',
                        HomePage(
                            isDarkMode: widget.isDarkMode,
                            onToggleTheme: widget.onToggleTheme)),
                    const SizedBox(width: 60),
                    _navLink(
                        ctx,
                        'About',
                        AboutPage(
                            isDarkMode: widget.isDarkMode,
                            onToggleTheme: widget.onToggleTheme)),
                    const SizedBox(width: 60),
                    _navLink(
                        ctx,
                        'Contact',
                        ContactPage(
                            isDarkMode: widget.isDarkMode,
                            onToggleTheme: widget.onToggleTheme)),
                    const Spacer(),
                    _authButton(
                        ctx,
                        'Login',
                        LoginPage(
                            isDarkMode: widget.isDarkMode,
                            onToggleTheme: widget.onToggleTheme)),
                    const SizedBox(width: 40),
                    _authButton(
                        ctx,
                        'Register',
                        RegisterPage(
                            isDarkMode: widget.isDarkMode,
                            onToggleTheme: widget.onToggleTheme),
                        isPrimary: true),
                    const SizedBox(width: 40),
                    IconButton(
                      onPressed: widget.onToggleTheme,
                      icon: Icon(
                        widget.isDarkMode
                            ? Icons.nightlight_round
                            : Icons.wb_sunny_outlined,
                        color: widget.isDarkMode ? Colors.white : Colors.black,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
