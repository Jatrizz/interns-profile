import 'package:flutter/material.dart';
import '../../utils/responsive.dart';

class PreFooter extends StatelessWidget {
  final bool isDarkMode;
  const PreFooter({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    final brand = Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Image.asset(
              isDarkMode
                  ? 'assets/images/logo_dark.png'
                  : 'assets/images/logo_light.png',
              height: 40,
              width: 40,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 6),
            Text(
              'InTurn',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'A simple and efficient management system built for organizations to track and manage their interns.',
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode
                ? const Color.fromRGBO(255, 255, 255, 0.815)
                : Colors.black54,
          ),
        ),
      ],
    );

    final social = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Follow Us',
          style: TextStyle(
            fontSize: 15,
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Icon(Icons.facebook,
                    size: 20, color: isDarkMode ? Colors.grey : Colors.black54),
                const SizedBox(height: 10),
                Image.asset('assets/images/instagram.png',
                    width: 18,
                    height: 18,
                    color: isDarkMode ? Colors.grey : Colors.black54),
                const SizedBox(height: 10),
                Image.asset('assets/images/linkedin.png',
                    width: 18,
                    height: 18,
                    color: isDarkMode ? Colors.grey : Colors.black54),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('InTurn',
                    style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white : Colors.black)),
                const SizedBox(height: 10),
                Text('InTurn',
                    style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white : Colors.black)),
                const SizedBox(height: 10),
                Text('InTurn',
                    style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white : Colors.black)),
              ],
            ),
          ],
        ),
      ],
    );

    final contact = Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.end,
      children: [
        Text(
          'Contact',
          style: TextStyle(
            fontSize: 15,
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Text('Email@company.com',
            style: TextStyle(
                fontSize: 12, color: isDarkMode ? Colors.white : Colors.black)),
        const SizedBox(height: 8),
        Text('09123456789',
            style: TextStyle(
                fontSize: 12, color: isDarkMode ? Colors.white : Colors.black)),
        const SizedBox(height: 8),
        Text('San Pablo City, Laguna',
            style: TextStyle(
                fontSize: 12, color: isDarkMode ? Colors.white : Colors.black)),
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 150,
        vertical: 32,
      ),
      child: isMobile
          // Mobile: stack sections vertically with dividers
          ? Column(
              children: [
                brand,
                const SizedBox(height: 28),
                Divider(color: isDarkMode ? Colors.white12 : Colors.black12),
                const SizedBox(height: 28),
                social,
                const SizedBox(height: 28),
                Divider(color: isDarkMode ? Colors.white12 : Colors.black12),
                const SizedBox(height: 28),
                contact,
              ],
            )
          // Desktop: side by side row
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 220, child: brand),
                SizedBox(width: 180, child: social),
                SizedBox(width: 200, child: contact),
              ],
            ),
    );
  }
}
