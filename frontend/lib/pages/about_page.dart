import 'package:flutter/material.dart';
import '../widgets/Homepage-Widgets/navbar.dart';
import '../widgets/Homepage-Widgets/footer.dart';

class AboutPage extends StatelessWidget{
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: NavBar(),
      body: ListView(
          children: [
            Footer()
          ],
      ),
    );
  }
}