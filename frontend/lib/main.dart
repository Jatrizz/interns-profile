import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/home_page.dart';
import 'pages/about_page.dart';
import 'pages/contact_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/admin_main.dart';
import 'pages/intern_main.dart';
import 'utils/session_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? true;
  runApp(InternsProfile(initialDarkMode: isDarkMode));
}

// Helper to build a route with no transition
Page<void> _noTransition(Widget child) => CustomTransitionPage(
      child: child,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      transitionsBuilder: (_, __, ___, child) => child,
    );

class InternsProfile extends StatefulWidget {
  final bool initialDarkMode;
  const InternsProfile({super.key, required this.initialDarkMode});

  @override
  State<InternsProfile> createState() => _InternsProfileState();
}

class _InternsProfileState extends State<InternsProfile> {
  late final ValueNotifier<bool> _darkMode;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _darkMode = ValueNotifier(widget.initialDarkMode);

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
      redirect: (context, state) {
        final role = getSessionRole();
        final loc = state.uri.toString();
        const publicRoutes = ['/', '/about', '/contact', '/login', '/register'];
        if (publicRoutes.contains(loc)) return null;
        if (loc.startsWith('/admin') && role != 'admin') return '/';
        if (loc.startsWith('/intern') && role != 'intern') return '/';
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => _noTransition(
            ValueListenableBuilder<bool>(
              valueListenable: _darkMode,
              builder: (_, dark, __) => HomePage(
                isDarkMode: dark,
                onToggleTheme: _toggleTheme,
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/about',
          pageBuilder: (context, state) => _noTransition(
            ValueListenableBuilder<bool>(
              valueListenable: _darkMode,
              builder: (_, dark, __) => AboutPage(
                isDarkMode: dark,
                onToggleTheme: _toggleTheme,
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/contact',
          pageBuilder: (context, state) => _noTransition(
            ValueListenableBuilder<bool>(
              valueListenable: _darkMode,
              builder: (_, dark, __) => ContactPage(
                isDarkMode: dark,
                onToggleTheme: _toggleTheme,
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) => _noTransition(
            ValueListenableBuilder<bool>(
              valueListenable: _darkMode,
              builder: (_, dark, __) => LoginPage(
                isDarkMode: dark,
                onToggleTheme: _toggleTheme,
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/register',
          pageBuilder: (context, state) => _noTransition(
            ValueListenableBuilder<bool>(
              valueListenable: _darkMode,
              builder: (_, dark, __) => RegisterPage(
                isDarkMode: dark,
                onToggleTheme: _toggleTheme,
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/admin/dashboard',
          pageBuilder: (context, state) => _noTransition(
            ValueListenableBuilder<bool>(
              valueListenable: _darkMode,
              builder: (_, dark, __) => AdminMainPage(
                firstName: getSessionFirstName(),
                isDarkMode: dark,
                onToggleTheme: _toggleTheme,
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/intern/dashboard',
          pageBuilder: (context, state) => _noTransition(
            ValueListenableBuilder<bool>(
              valueListenable: _darkMode,
              builder: (_, dark, __) => InternMainPage(
                firstName: getSessionFirstName(),
                userId: getSessionUserId(),
                isDarkMode: dark,
                onToggleTheme: _toggleTheme,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _toggleTheme() async {
    _darkMode.value = !_darkMode.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _darkMode.value);
  }

  @override
  void dispose() {
    _darkMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _darkMode,
      builder: (_, dark, __) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
        theme: ThemeData(
          scaffoldBackgroundColor:
              dark ? Colors.black : const Color(0xFFF7F9FC),
        ),
        title: "InTurn",
      ),
    );
  }
}
