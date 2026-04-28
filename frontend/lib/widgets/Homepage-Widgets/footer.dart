import 'package:flutter/material.dart';
import 'package:interfaces/pages/privacy_policy_page.dart';

class Footer extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback? onToggleTheme;
  const Footer({super.key, required this.isDarkMode, this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0A0A0A) : Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 65, right: 65),
        child: Row(
          children: [
            const Icon(Icons.copyright, color: Colors.grey, size: 15),
            const SizedBox(width: 2),
            Text(
              '${DateTime.now().year} Orbis. All Rights Reserved.',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            const Spacer(),
            TextButton(
              style: const ButtonStyle(
                overlayColor: WidgetStatePropertyAll(Colors.transparent),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => PrivacyPolicyPage(
                      isDarkMode: isDarkMode,
                      onToggleTheme: onToggleTheme ?? () {},
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              child: const Text(
                'Privacy Policy',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ),
            const Text(
              '|',
              style: TextStyle(
                color: Color.fromARGB(176, 158, 158, 158),
                fontSize: 20,
              ),
            ),
            TextButton(
              style: const ButtonStyle(
                overlayColor: WidgetStatePropertyAll(Colors.transparent),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => TermsOfServicePage(
                      isDarkMode: isDarkMode,
                      onToggleTheme: onToggleTheme ?? () {},
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              child: const Text(
                'Terms of Service',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}