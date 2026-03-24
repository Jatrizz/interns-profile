import 'package:flutter/material.dart';

void main() {
  runApp(InternsList());
}

class InternsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      title: 'FDSAP Intern`s Profile',
      debugShowCheckedModeBanner: false,
    );
  }
}
