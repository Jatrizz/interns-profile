import 'package:flutter/material.dart';
import 'pages/homepage.dart';

void main() {
  runApp(InternsList());
}

class InternsList extends StatelessWidget {
  const InternsList({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      title: 'Interns` Profile',
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
