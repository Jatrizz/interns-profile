import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../widgets/Dashboard-Widgets/sidebar.dart';
import '../widgets/Dashboard-Widgets/top_bar.dart';
import '../widgets/Dashboard-Widgets/welcome_card.dart';
import '../widgets/Dashboard-Widgets/stats_cards.dart';
import '../widgets/Dashboard-Widgets/bar_chart.dart';
import '../widgets/Dashboard-Widgets/search_bar.dart';
import '../widgets/Dashboard-Widgets/recent_activity.dart';
import '../widgets/Dashboard-Widgets/right_panel.dart';

class DashboardOverviewPage extends StatefulWidget {
  final String firstName;
  const DashboardOverviewPage({super.key, required this.firstName});

  @override
  State<DashboardOverviewPage> createState() => _DashboardOverviewPageState();
}

class _DashboardOverviewPageState extends State<DashboardOverviewPage> {
  bool isDarkMode = true;
  int totalInterns = 0;
  int newInterns = 0;
  int totalSchools = 0;
  List<dynamic> admins = [];
  List<Map<String, dynamic>> chartYearlyStats = [];
  String recentActivity = "";
  late Timer _timer;
  String _currentTime = "";
  DateTime _currentDate = DateTime.now();
  DateTime _calendarDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
    fetchDashboardData();
    fetchAdmins();
    fetchChartStats();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
      _currentDate = now;
    });
  }

  Future<void> fetchDashboardData() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://127.0.0.1:8080/dashboard?firstName=${widget.firstName}'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          totalInterns = data['total_interns'];
          newInterns = data['new_interns'];
          totalSchools = data['total_schools'];
        });
      }
    } catch (e) {
      print('Error fetching dashboard: $e');
    }
  }

  Future<void> fetchAdmins() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8080/admins'),
      );
      if (response.statusCode == 200) {
        setState(() {
          admins = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print('Error fetching admins: $e');
    }
  }

  Future<void> fetchChartStats() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8080/school-stats'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        final mockData = [
          {'year': '2022', 'PLSP': 5, 'CMDI': 3, 'LSPU': 2, 'OTHERS': 1},
          {'year': '2023', 'PLSP': 7, 'CMDI': 4, 'LSPU': 3, 'OTHERS': 2},
          {'year': '2024', 'PLSP': 9, 'CMDI': 5, 'LSPU': 4, 'OTHERS': 3},
          {'year': '2025', 'PLSP': 7, 'CMDI': 3, 'LSPU': 2, 'OTHERS': 1},
        ];

        final Map<String, Map<String, dynamic>> realData = {};
        for (var stat in data) {
          final year = stat['year'].toString();
          final school = stat['school'].toString().toUpperCase();
          final count = stat['count'] as int;

          if (!realData.containsKey(year)) {
            realData[year] = {
              'year': year,
              'PLSP': 0,
              'CMDI': 0,
              'LSPU': 0,
              'OTHERS': 0,
            };
          }

          if (['PLSP', 'CMDI', 'LSPU'].contains(school)) {
            realData[year]![school] = count;
          } else {
            realData[year]!['OTHERS'] =
                (realData[year]!['OTHERS'] as int) + count;
          }
        }

        setState(() {
          chartYearlyStats = [
            ...mockData,
            ...realData.values.toList(),
          ];
        });
      }
    } catch (e) {
      print('Error fetching chart stats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      body: Row(
        children: [
          Sidebar(isDarkMode: isDarkMode),
          Expanded(
            child: Column(
              children: [
                TopBar(
                  isDarkMode: isDarkMode,
                  firstName: widget.firstName,
                  onToggleDarkMode: () =>
                      setState(() => isDarkMode = !isDarkMode),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DashboardSearchBar(isDarkMode: isDarkMode),
                              const SizedBox(height: 20),
                              WelcomeCard(
                                isDarkMode: isDarkMode,
                                firstName: widget.firstName,
                                currentTime: _currentTime,
                              ),
                              const SizedBox(height: 20),
                              StatsCards(
                                isDarkMode: isDarkMode,
                                newInterns: newInterns,
                                totalInterns: totalInterns,
                                totalSchools: totalSchools,
                              ),
                              const SizedBox(height: 20),
                              BarChart(
                                isDarkMode: isDarkMode,
                                yearlyStats: chartYearlyStats,
                              ),
                              const SizedBox(height: 20),
                              RecentActivity(
                                isDarkMode: isDarkMode,
                                recentActivity: recentActivity,
                              ),
                            ],
                          ),
                        ),
                      ),
                      RightPanel(
                        isDarkMode: isDarkMode,
                        admins: admins,
                        currentDate: _currentDate,
                        calendarDate: _calendarDate,
                        onPreviousMonth: () => setState(() {
                          _calendarDate = DateTime(
                            _calendarDate.year,
                            _calendarDate.month - 1,
                            1,
                          );
                        }),
                        onNextMonth: () => setState(() {
                          _calendarDate = DateTime(
                            _calendarDate.year,
                            _calendarDate.month + 1,
                            1,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
