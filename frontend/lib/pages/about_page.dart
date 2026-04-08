import 'package:flutter/material.dart';
import 'package:interfaces/widgets/Homepage-Widgets/Aboutpage-Widgets/about_intro.dart';
import 'package:interfaces/widgets/Homepage-Widgets/Aboutpage-Widgets/herosection_about.dart';
import 'package:interfaces/widgets/Homepage-Widgets/Aboutpage-Widgets/team_section.dart';
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
            HerosectionAbout(),
            AboutIntro(),
            TeamSection(),
            SizedBox(height: 80,),
            Footer()
          ],
      ),
    );
  }
}