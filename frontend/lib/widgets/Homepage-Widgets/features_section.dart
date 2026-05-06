import 'package:flutter/material.dart';
import '../../utils/responsive.dart';

class FeaturesSection extends StatelessWidget {
  final bool isDarkMode;
  const FeaturesSection({super.key, required this.isDarkMode});

  Widget _feature(IconData icon, String label) {
    return SizedBox(
      height: 150,
      width: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 60,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // shrinks on mobile, stays 350 on desktop
      height: Responsive.isMobile(context) ? null : 350,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 20,
              horizontal: Responsive.value(
                context,
                mobile: 16.0,
                tablet: 32.0,
                desktop: 50.0,
              ),
            ),
            child: Text(
              'Our Features',
              style: TextStyle(
                fontSize: Responsive.value(
                  context,
                  mobile: 22.0,
                  tablet: 26.0,
                  desktop: 30.0,
                ),
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
          // Wrap automatically flows to next line on smaller screens
          Wrap(
            spacing: Responsive.value(
              context,
              mobile: 20.0,
              tablet: 40.0,
              desktop: 60.0,
            ),
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _feature(Icons.manage_accounts, 'Profile Management'),
              _feature(Icons.search, 'Search and Filter'),
              _feature(Icons.dashboard, 'Dashboard Overview'),
              _feature(Icons.sort, 'Sort and Organize'),
              _feature(Icons.contact_page, 'Contact Management'),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
