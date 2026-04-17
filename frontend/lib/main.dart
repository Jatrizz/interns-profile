import 'package:flutter/material.dart';
import 'package:interfaces/pages/contact_page.dart';
import 'package:interfaces/pages/interns_list.dart';
import 'package:interfaces/pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/about_page.dart';
import 'pages/register_page.dart';

void main() {
  runApp(InternsProfile());
}

class InternsProfile extends StatelessWidget {
  const InternsProfile({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Colors.black),
      title: 'Intern`s Profile',
      initialRoute: '/',

      routes: {
        '/': (context) => HomePage(),
        '/about': (context) => AboutPage(),
        '/contacts': (context) => ContactPage(),
        'register': (context) => RegisterPage(),
        '/login': (context) => LoginPage(),
        '/interns_list': (context) => InternsList()
      },
    );
  }
}
