import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:interfaces/widgets/Homepage-Widgets/stats_section.dart';
import '../widgets/Homepage-Widgets/navbar.dart';
import '../widgets/Homepage-Widgets/hero_section.dart';
import '../widgets/Homepage-Widgets/features_section.dart';
import '../widgets/Homepage-Widgets/footer.dart';
import '../widgets/Homepage-Widgets/prefooter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int interns = 0;
  int schools = 0;
  int programs = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/get-stats'),
      );

      print("RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          interns = int.tryParse(data['interns'].toString()) ?? 0;
          schools = int.tryParse(data['schools'].toString()) ?? 0;
          programs = int.tryParse(data['programs'].toString()) ?? 0;
          isLoading = false;
        });
      } else {
        print("Failed to load stats: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching stats: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: NavBar(),
      body: ListView(
        children: [
          HeroSection(),
          FeaturesSection(),

          // 🔥 Dynamic Stats Section
          Center(
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  )
                : StatsSection(
                    interns: interns,
                    schools: schools,
                    programs: programs,
                  ),
          ),

          PreFooter(),
          Footer(),
        ],
      ),
    );
  }
}
