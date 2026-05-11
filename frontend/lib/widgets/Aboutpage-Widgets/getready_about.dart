import 'package:flutter/material.dart';
import '../../utils/responsive.dart';

class GetreadyAbout extends StatelessWidget {
  const GetreadyAbout({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.value(context,
            mobile: 24.0, tablet: 80.0, desktop: 150.0),
        vertical: 20,
      ),
      child: isMobile
          // on mobile: stack text above button
          ? Column(
              children: [
                Text(
                  'Ready to get started?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Responsive.value(context,
                        mobile: 22.0, tablet: 26.0, desktop: 30.0),
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                _button(),
              ],
            )
          // on desktop: keep side by side
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Ready to get started?',
                  style: TextStyle(
                    fontSize: Responsive.value(context,
                        mobile: 22.0, tablet: 26.0, desktop: 30.0),
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _button(),
              ],
            ),
    );
  }

  Widget _button() {
    return Container(
      width: 200,
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
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: const Center(
              child: Text(
                'Get Started',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w100,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
