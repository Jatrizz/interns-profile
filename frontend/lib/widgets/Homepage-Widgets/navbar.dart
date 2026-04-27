import 'package:flutter/material.dart';
import 'package:interfaces/pages/contact_page.dart';
import 'package:interfaces/pages/home_page.dart';
import 'package:interfaces/pages/login_page.dart';
import '../../pages/about_page.dart';
import '../../pages/register_page.dart';

class NavBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  const NavBar({super.key, required this.isDarkMode, required this.onToggleTheme});

  @override
  Size get preferredSize => const Size.fromHeight(95);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      toolbarHeight: 95,
      scrolledUnderElevation: 0,
      title: Padding(
        padding: EdgeInsetsGeometry.only(left: 50, right: 50),
        child: Row(
          children: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => HomePage(isDarkMode: isDarkMode, onToggleTheme: onToggleTheme),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              child: Text(
                'Home',
                style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.white : Colors.black),
              ),
            ),
            SizedBox(width: 20),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => AboutPage(isDarkMode: isDarkMode, onToggleTheme: onToggleTheme),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              child: Text(
                'About',
                style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.white : Colors.black),
              ),
            ),
            SizedBox(width: 20),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => ContactPage(isDarkMode: isDarkMode, onToggleTheme: onToggleTheme),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              child: Text(
                'Contact',
                style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.white : Colors.black),
              ),
            ),
            Spacer(),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => LoginPage(isDarkMode: isDarkMode, onToggleTheme: onToggleTheme),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              child: Text(
                'Login',
                style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.white : Colors.black),
              ),
            ),
            SizedBox(width: 20),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => RegisterPage(isDarkMode: isDarkMode, onToggleTheme: onToggleTheme),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              child: Text(
                'Register',
                style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.white : Colors.black),
              ),
            ),
            SizedBox(width: 20),
            IconButton(
              onPressed: onToggleTheme,
              icon: Icon(
                isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_outlined,
                color: isDarkMode ? Colors.white : Colors.black, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
