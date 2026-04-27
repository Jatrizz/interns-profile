import 'package:flutter/material.dart';

class AboutIntro extends StatelessWidget {
  final bool isDarkMode;
  const AboutIntro({super.key, required this.isDarkMode});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
            child: Column(
          children: [
            Padding(
              padding: EdgeInsetsGeometry.only(right: 140),
              child: Text(
                'What is Orbis?',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 30,
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight(600),
                ),
              ),
            ),
            Text(
              'Orbis is a web-based intern profile management\nsystem designed to help companies efficiently track,\norganize, and manage their interns in one centralized\nplatform. Gone are the days of scattered spreadsheets\nand disorganized records. Orbis provides a simple,\nsecure, and intuitive solution for managing intern\ninformation from registration to completion.',
              style: TextStyle(
                height: 1.7,
                fontSize: 15,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            )
          ],
        )),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Image.asset(
                    '../../../assets/images/img1_about.jpg',
                    height: 145,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Image.asset(
                    '../../../assets/images/img3_about.jpg',
                    height: 250,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
              SizedBox(
                width: 10,
              ),
              Column(children: [
                Image.asset(
                  '../../../assets/images/img6_about.jpg',
                  height: 250,
                ),
                SizedBox(
                  height: 10,
                ),
                Image.asset(
                  '../../../assets/images/img4_about.jpg',
                  height: 146,
                ),
                SizedBox(
                  height: 65,
                ),
              ]),
              SizedBox(
                width: 50,
              )
            ],
          ),
        ),
      ],
    );
  }
}
