import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/about_page.dart';

void main(){
  runApp(InternsProfile());
}

class InternsProfile extends StatelessWidget{
  const InternsProfile({super.key});
  @override

  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
      ),
      title: 'Intern`s Profile',
      initialRoute: '/',

      routes: {
        '/' : (context) => HomePage(),
        '/about' : (context) => AboutPage(),
      },
    );
  }
}