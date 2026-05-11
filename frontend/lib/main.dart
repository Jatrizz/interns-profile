import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/home_page.dart';
import 'pages/admin_main.dart';
import 'pages/intern_main.dart';
import 'utils/session_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? true;
  runApp(InternsProfile(initialDarkMode: isDarkMode));
}

class InternsProfile extends StatefulWidget {
  final bool initialDarkMode;
  const InternsProfile({super.key, required this.initialDarkMode});

  @override
  State<InternsProfile> createState() => _InternsProfileState();
}

class _InternsProfileState extends State<InternsProfile> {
  late bool isDarkMode;
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.initialDarkMode;

    // Each tab reads its OWN sessionStorage to decide the initial route.
    final role = getSessionRole();
    final String initialLocation;
    if (role == 'admin') {
      initialLocation = '/admin/dashboard';
    } else if (role == 'intern') {
      initialLocation = '/intern/dashboard';
    } else {
      initialLocation = '/';
    }

    _router = GoRouter(
      initialLocation: initialLocation,
      // Synchronous redirect — no async, no white flash.
      redirect: (context, state) {
        final role = getSessionRole();
        final loc = state.uri.toString();

        if (loc == '/') return null; // always allow login page

        if (loc.startsWith('/admin') && role != 'admin') return '/';
        if (loc.startsWith('/intern') && role != 'intern') return '/';

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => HomePage(
            isDarkMode: isDarkMode,
            onToggleTheme: _toggleTheme,
          ),
        ),
        GoRoute(
          path: '/admin/dashboard',
          builder: (context, state) => AdminMainPage(
            firstName: getSessionFirstName(),
            isDarkMode: isDarkMode,
            onToggleTheme: _toggleTheme,
          ),
        ),
        GoRoute(
          path: '/intern/dashboard',
          builder: (context, state) => InternMainPage(
            firstName: getSessionFirstName(),
            userId: getSessionUserId(),
            isDarkMode: isDarkMode,
            onToggleTheme: _toggleTheme,
          ),
        ),
      ],
    );
  }

  void _toggleTheme() async {
    setState(() => isDarkMode = !isDarkMode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(
        scaffoldBackgroundColor:
            isDarkMode ? Colors.black : const Color(0xFFF7F9FC),
      ),
      title: "Intern's Profile",
    );
  }
}