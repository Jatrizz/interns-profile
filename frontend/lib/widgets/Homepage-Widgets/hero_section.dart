import 'package:flutter/material.dart';
import 'package:interfaces/pages/about_page.dart';
import 'package:interfaces/pages/register_page.dart';
import '../../utils/responsive.dart';

class HeroSection extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  const HeroSection({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    // logo
    final logo = SizedBox(
      height: isMobile ? 300 : 700,
      child: isDarkMode
          ? Image.asset('assets/images/logo_dark.png', fit: BoxFit.contain)
          : Image.asset('assets/images/logo_light.png', fit: BoxFit.contain),
    );

    // text + buttons
    final content = SizedBox(
      height: isMobile ? null : 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'InTurn - Intern Profile\nManagement System',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: Responsive.value(
                context,
                mobile: 24.0,
                tablet: 32.0,
                desktop: 40.0,
              ),
              fontWeight: FontWeight.w800,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              isMobile
                  ? 'Track your daily hours, monitor OJT progress, and keep your profile up to date.'
                  : 'Stay on top of your internship journey by easily tracking your daily\nhours, monitoring your remaining OJT hours, and keeping your\nprofile up to date. All in one simple and organized platform.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontSize: Responsive.value(
                  context,
                  mobile: 13.0,
                  tablet: 14.0,
                  desktop: 15.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: isMobile ? double.infinity : 300,
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 65, 142, 204),
                        Color.fromARGB(255, 0, 4, 250),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, a1, a2) => RegisterPage(
                              isDarkMode: isDarkMode,
                              onToggleTheme: onToggleTheme,
                            ),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        child: Center(
                          child: Text(
                            'Get Started',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w100,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, a1, a2) => AboutPage(
                          isDarkMode: isDarkMode,
                          onToggleTheme: onToggleTheme,
                        ),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        'Learn More',
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey : Colors.black54,
                          fontSize: 15,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        color: isDarkMode ? Colors.grey : Colors.black54,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return isMobile
        ? Column(
            children: [
              logo,
              const SizedBox(height: 20),
              content,
              const SizedBox(height: 40),
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
