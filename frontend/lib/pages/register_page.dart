import 'package:flutter/material.dart';
import 'package:interfaces/widgets/Homepage-Widgets/navbar.dart';
import 'package:interfaces/widgets/Register-Widgets/hero_section.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavBar(),
      body: ListView(children: [HeroSection()]),
    );
  }
}
