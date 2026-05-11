import 'package:flutter/material.dart';
import '../../utils/responsive.dart';

class HerosectionAbout extends StatelessWidget {
  final bool isDarkMode;
  const HerosectionAbout({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    final logo = SizedBox(
      height: isMobile ? 300 : 700,
      width: isMobile ? double.infinity : null,
      child: isDarkMode
          ? Image.asset('assets/images/logo_dark.png', fit: BoxFit.contain)
          : Image.asset('assets/images/logo_light.png', fit: BoxFit.contain),
    );

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'About Us',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: Responsive.value(context,
                  mobile: 28.0, tablet: 34.0, desktop: 40.0),
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Learn more about our intern profile\nmanagement system and the team behind it.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: Responsive.value(context,
                  mobile: 13.0, tablet: 14.0, desktop: 15.0),
            ),
          ),
        ],
      ),
    );

    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              logo,
              const SizedBox(height: 20),
              content,
              const SizedBox(height: 20),
            ],
          )
        : Row(
            children: [
              Expanded(child: logo),
              Expanded(child: content),
            ],
          );
  }
}
