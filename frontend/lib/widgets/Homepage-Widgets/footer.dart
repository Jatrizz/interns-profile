import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  final bool isDarkMode;
  const Footer({super.key, required this.isDarkMode});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(color: isDarkMode ? const Color(0xFF0A0A0A) : Colors.white,),
      child: Padding(
        padding: EdgeInsetsGeometry.only(left: 65, right: 65),
        child: Row(
          children: [
            Icon(Icons.copyright, color: Colors.grey, size: 15),
            SizedBox(width: 2),
            Text(
              '${DateTime.now().year} Orbis. All Rights Reserved.',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
            Spacer(),
            TextButton(
              style: ButtonStyle(
                overlayColor: WidgetStatePropertyAll(Colors.transparent),
              ),
              onPressed: () {},
              child: Text(
                'Privacy Policy',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ),
            Text(
              '|',
              style: TextStyle(
                color: const Color.fromARGB(176, 158, 158, 158),
                fontSize: 20,
              ),
            ),
            TextButton(
              style: ButtonStyle(
                overlayColor: WidgetStatePropertyAll(Colors.transparent),
              ),
              onPressed: () {},
              child: Text(
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
