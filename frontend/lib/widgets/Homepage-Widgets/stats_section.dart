import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/responsive.dart';

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

  Widget _buildStat(String value, String label) {
    return SizedBox(
      width: 100,
      height: 150,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: Responsive.value(
                context,
                mobile: 28.0,
                tablet: 34.0,
                desktop: 40.0,
              ),
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: Responsive.value(
                context,
                mobile: 14.0,
                tablet: 17.0,
                desktop: 20.0,
              ),
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    // on mobile show a horizontal divider, desktop keeps vertical
    return Responsive.isMobile(context)
        ? Container(
            width: 60,
            height: 1.5,
            color: widget.isDarkMode ? Colors.white : Colors.black26,
          )
        : Container(
            height: 160,
            width: 1.5,
            color: widget.isDarkMode ? Colors.white : Colors.black26,
          );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final isMobile = Responsive.isMobile(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.value(
          context,
          mobile: 16.0,
          tablet: 32.0,
          desktop: 0.0,
        ),
        vertical: 20,
      ),
      child: Column(
        children: [
          // title
          Text(
            'Statistics',
            style: TextStyle(
              fontSize: Responsive.value(
                context,
                mobile: 22.0,
                tablet: 26.0,
                desktop: 30.0,
              ),
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 5),

          // subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Empowering organizations to manage their interns efficiently and effectively.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white : Colors.black87,
                fontSize: Responsive.value(
                  context,
                  mobile: 12.0,
                  tablet: 13.0,
                  desktop: 15.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // stats — Column on mobile, Row on tablet/desktop
          isMobile
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStat('$interns', 'Interns'),
                    const SizedBox(height: 10),
                    _divider(),
                    const SizedBox(height: 10),
                    _buildStat('$schools', 'Schools'),
                    const SizedBox(height: 10),
                    _divider(),
                    const SizedBox(height: 10),
                    _buildStat('$programs', 'Programs'),
                  ],
                )
              : SizedBox(
                  width: Responsive.value(
                    context,
                    mobile: double.infinity,
                    tablet: 700.0,
                    desktop: 1100.0,
                  ),
                  height: 250,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStat('$interns', 'Interns'),
                      _divider(),
                      _buildStat('$schools', 'Schools'),
                      _divider(),
                      _buildStat('$programs', 'Programs'),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
