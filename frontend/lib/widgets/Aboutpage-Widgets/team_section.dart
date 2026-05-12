import 'package:flutter/material.dart';
import '../../utils/responsive.dart';

class TeamSection extends StatelessWidget {
  final bool isDarkMode;
  const TeamSection({super.key, required this.isDarkMode});

  Widget _member(String image, String name, String role) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(image, height: 200),
        ),
        const SizedBox(height: 10),
        Text(
          name,
          style: TextStyle(
            fontSize: 15,
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          role,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.value(context,
            mobile: 24.0, tablet: 80.0, desktop: 200.0),
      ),
      child: Column(
        children: [
          const SizedBox(height: 80),
          Text(
            'Meet the Team',
            style: TextStyle(
              fontSize: Responsive.value(context,
                  mobile: 22.0, tablet: 26.0, desktop: 30.0),
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'The people behind InTurn.',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: isMobile ? 20 : 60,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: [
              _member('assets/images/Lester.jpg', 'Lester John Manzanero',
                  'Frontend Developer'),
              _member('assets/images/janna.webp', 'Janna Tricia Pujeda',
                  'Full-stack Developer'),
              _member('assets/images/nathaniel.webp', 'Nathaniel Velasco',
                  'Backend Developer'),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
