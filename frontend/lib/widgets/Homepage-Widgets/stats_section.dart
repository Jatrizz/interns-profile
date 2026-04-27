import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StatsSection extends StatefulWidget {
  final bool isDarkMode;
  const StatsSection({super.key, required this.isDarkMode});

  @override
  State<StatsSection> createState() => _StatsSectionState();
}

class _StatsSectionState extends State<StatsSection> {
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

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          interns = data['interns'];
          schools = data['schools'];
          programs = data['programs'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load stats');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0),
      child: SizedBox(
        height: 350,
        width: 1100,
        child: Column(
          children: [
            Text(
              'Statistics',
              style: TextStyle(fontSize: 30, color: widget.isDarkMode ? Colors.white : Colors.black),
            ),
            SizedBox(height: 5),
            Text(
              'Empowering organizations to manage their interns efficiently and effectively.',
              style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87, fontSize: 12),
            ),
            SizedBox(
              width: 1100,
              height: 250,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildStat('$interns', 'Interns'),
                  divider(),
                  buildStat('$schools', 'Schools'),
                  divider(),
                  buildStat('$programs', 'Programs'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStat(String value, String label) {
    return SizedBox(
      width: 100,
      height: 150,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: TextStyle(fontSize: 40, color: widget.isDarkMode ? Colors.white : Colors.black)),
          Text(label, style: TextStyle(fontSize: 20, color: widget.isDarkMode ? Colors.white : Colors.black)),
        ],
      ),
    );
  }

  Widget divider() {
    return Container(height: 160, width: 1.5, color: widget.isDarkMode ? Colors.white : Colors.black26);
  }
}
