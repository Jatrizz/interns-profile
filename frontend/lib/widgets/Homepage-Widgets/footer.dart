import 'package:flutter/material.dart';
import 'package:interfaces/pages/privacy_policy_page.dart';
import '../../utils/responsive.dart';

class Footer extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback? onToggleTheme;
  const Footer({super.key, required this.isDarkMode, this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0A0A0A) : Colors.white,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 65,
        vertical: isMobile ? 16 : 0,
      ),
      height: isMobile ? null : 50,
      child: isMobile
          // Mobile: stack copyright on top, links below
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.copyright, color: Colors.grey, size: 13),
                    const SizedBox(width: 2),
                    Text(
                      '${DateTime.now().year} InTurn. All Rights Reserved.',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _linkButton(context, 'Privacy Policy'),
                    const Text('|',
                        style: TextStyle(
                            color: Color.fromARGB(176, 158, 158, 158),
                            fontSize: 18)),
                    _linkButton(context, 'Terms of Service'),
                  ],
                ),
              ],
            )
          // Desktop: single row
          : Row(
              children: [
                const Icon(Icons.copyright, color: Colors.grey, size: 15),
                const SizedBox(width: 2),
                Text(
                  '${DateTime.now().year} InTurn. All Rights Reserved.',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const Spacer(),
                _linkButton(context, 'Privacy Policy'),
                const Text('|',
                    style: TextStyle(
                        color: Color.fromARGB(176, 158, 158, 158),
                        fontSize: 20)),
                _linkButton(context, 'Terms of Service'),
              ],
            ),
    );
  }

  Widget _linkButton(BuildContext context, String label) {
    return TextButton(
      style: const ButtonStyle(
        overlayColor: WidgetStatePropertyAll(Colors.transparent),
      ),
      onPressed: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => label == 'Privacy Policy'
                ? PrivacyPolicyPage(
                    isDarkMode: isDarkMode,
                    onToggleTheme: onToggleTheme ?? () {},
                  )
                : TermsOfServicePage(
                    isDarkMode: isDarkMode,
                    onToggleTheme: onToggleTheme ?? () {},
                  ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
      child: Text(
        label,
        style: const TextStyle(color: Colors.grey, fontSize: 10),
      ),
    );
  }
}
