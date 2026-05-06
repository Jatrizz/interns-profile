import 'package:flutter/material.dart';

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
          Icon(icon,
              size: 60, color: isDarkMode ? Colors.white : Colors.black87),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 15, color: isDarkMode ? Colors.white : Colors.black),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 350,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Our Features',
                style: TextStyle(
                  fontSize: 30,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _feature(Icons.manage_accounts, 'Profile Management'),
                  const SizedBox(
                      width: 70), // change this value to adjust all gaps
                  _feature(Icons.search, 'Search and Filter'),
                  const SizedBox(width: 70),
                  _feature(Icons.dashboard, 'Dashboard Overview'),
                  const SizedBox(width: 70),
                  _feature(Icons.sort, 'Sort and Organize'),
                  const SizedBox(width: 70),
                  _feature(Icons.contact_page, 'Contact Management'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
