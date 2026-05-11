import 'package:flutter/material.dart';
import '../../utils/responsive.dart';

class AboutIntro extends StatelessWidget {
  final bool isDarkMode;
  const AboutIntro({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    final textContent = Padding(
      padding: EdgeInsets.only(
        right: isMobile ? 20 : 60,
        left: isMobile ? 20 : 40,
        bottom: isMobile ? 20 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What is InTurn?',
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: Responsive.value(context,
                  mobile: 22.0, tablet: 26.0, desktop: 30.0),
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'InTurn is a web-based intern profile management system designed to help companies efficiently track, organize, and manage their interns in one centralized platform. Gone are the days of scattered spreadsheets and disorganized records. InTurn provides a simple, secure, and intuitive solution for managing intern information from registration to completion.',
            style: TextStyle(
              height: 1.7,
              fontSize: Responsive.value(context,
                  mobile: 13.0, tablet: 14.0, desktop: 15.0),
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );

    final images = Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 0),
      child: isMobile
          ? Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset('assets/images/img1_about.jpg',
                      height: 120, fit: BoxFit.cover),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset('assets/images/img3_about.jpg',
                      height: 120, fit: BoxFit.cover),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset('assets/images/img6_about.jpg',
                      height: 120, fit: BoxFit.cover),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset('assets/images/img4_about.jpg',
                      height: 120, fit: BoxFit.cover),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Image.asset('assets/images/img1_about.jpg', height: 145),
                    const SizedBox(height: 10),
                    Image.asset('assets/images/img3_about.jpg', height: 250),
                  ],
                ),
                const SizedBox(width: 10),
                Column(
                  children: [
                    Image.asset('assets/images/img6_about.jpg', height: 250),
                    const SizedBox(height: 10),
                    Image.asset('assets/images/img4_about.jpg', height: 146),
                  ],
                ),
              ],
            ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textContent,
                const SizedBox(height: 20),
                images,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: textContent),
                Expanded(child: images),
              ],
            ),
    );
  }
}
