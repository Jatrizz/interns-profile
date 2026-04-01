import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // NAVBAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Internshit",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          navButton("Home"),
          navButton("About"),
          navButton("Contact"),
          navButton("Login"),
          navButton("Register"),
        ],
      ),

      // BODY
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HERO SECTION
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  const Text(
                    "Welcome to Internship",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                    child: const Text("Get Started"),
                  ),
                ],
              ),
            ),

            const Divider(),

            // FEATURES SECTION
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Our Features",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),

            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: const [
                FeatureCard("Profile Management"),
                FeatureCard("Search & Filter"),
                FeatureCard("Dashboard Overview"),
                FeatureCard("Sort & Organize"),
                FeatureCard("Contact Management"),
                FeatureCard("Statistics"),
              ],
            ),

            const SizedBox(height: 40),

            // STATS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                StatCard("13+", "Interns"),
                StatCard("5+", "Schools"),
                StatCard("10+", "Programs"),
              ],
            ),

            const SizedBox(height: 40),

            // FOOTER
            Container(
              color: Colors.black,
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              child: const Column(
                children: [
                  Text(
                    "Internshit",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "A simple and efficient management system.",
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "© 2026 Internshit. All Rights Reserved.",
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget navButton(String text) {
    return TextButton(
      onPressed: () {},
      child: Text(text, style: const TextStyle(color: Colors.black)),
    );
  }
}

// FEATURE CARD
class FeatureCard extends StatelessWidget {
  final String title;

  const FeatureCard(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(child: Text(title, textAlign: TextAlign.center)),
    );
  }
}

// STAT CARD
class StatCard extends StatelessWidget {
  final String number;
  final String label;

  const StatCard(this.number, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        Text(label),
      ],
    );
  }
}
