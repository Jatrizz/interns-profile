import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/responsive.dart';
import '../widgets/Dashboard-Widgets/welcome_card.dart';
import '../widgets/Dashboard-Widgets/stats_cards.dart';
import '../widgets/Dashboard-Widgets/bar_chart.dart';
import '../widgets/Dashboard-Widgets/recent_activity.dart';
import '../widgets/Dashboard-Widgets/right_panel.dart';
import '../widgets/Dashboard-Widgets/calendar.dart';
import '../widgets/Dashboard-Widgets/dahsboard_intern_list.dart';

class DashboardOverviewPage extends StatefulWidget {
  final String firstName;
  final bool isDarkMode;

  const DashboardOverviewPage({
    super.key,
    required this.firstName,
    required this.isDarkMode,
  });

  @override
  State<DashboardOverviewPage> createState() => _DashboardOverviewPageState();
}

class _DashboardOverviewPageState extends State<DashboardOverviewPage> {
  int totalInterns = 0;
  int newInterns = 0;
  int totalSchools = 0;
  List<dynamic> interns = [];
  List<Map<String, dynamic>> chartYearlyStats = [];
  List<Map<String, dynamic>> recentActivities = [];
  late Timer _timer;
  late Timer _internRefreshTimer;
  String _currentTimeString = "";
  DateTime _currentDate = DateTime.now();
  DateTime _calendarDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    fetchDashboardData();
    fetchNewInternsToday();
    fetchInterns();
    fetchChartStats();
    fetchRecentActivity();
    _internRefreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      fetchInterns();
      fetchRecentActivity();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _internRefreshTimer.cancel();
    super.dispose();
  }

  void _tick() {
    final now = DateTime.now();
    setState(() {
      _currentDate = now;
      final h = now.hour;
      final m = now.minute.toString().padLeft(2, '0');
      final period = h >= 12 ? 'PM' : 'AM';
      final hour12 = h % 12 == 0 ? 12 : h % 12;
      _currentTimeString = '$hour12:$m $period';
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
          totalSchools = data['total_schools'];
        });
      }
    } catch (e) {
      debugPrint('Error fetching dashboard: $e');
    }
  }

  Future<void> fetchNewInternsToday() async {
    try {
      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8080/new-interns-today?date=$dateStr'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          newInterns = data['count'];
        });
      }
    } catch (e) {
      debugPrint('Error fetching new interns today: $e');
    }
  }

  Future<void> fetchInterns() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8080/interns-list'),
      );
      if (response.statusCode == 200) {
        setState(() {
          interns = jsonDecode(response.body);
        });
      }
    } catch (e) {
      debugPrint('Error fetching interns: $e');
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
      debugPrint('Error fetching chart stats: $e');
    }
  }

  Future<void> fetchRecentActivity() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8080/recent-activity'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          recentActivities =
              data.map((e) => Map<String, dynamic>.from(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching recent activity: $e');
    }
  }

  // ── calendar callbacks ──
  void _previousMonth() => setState(() {
        _calendarDate = DateTime(
          _calendarDate.year,
          _calendarDate.month - 1,
          1,
        );
      });

  void _nextMonth() => setState(() {
        _calendarDate = DateTime(
          _calendarDate.year,
          _calendarDate.month + 1,
          1,
        );
      });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    // ── main scrollable content ──
    final mainContent = SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WelcomeCard(
            isDarkMode: widget.isDarkMode,
            firstName: widget.firstName,
            currentTime: _currentTimeString,
          ),
          const SizedBox(height: 20),
          StatsCards(
            isDarkMode: widget.isDarkMode,
            newInterns: newInterns,
            totalInterns: totalInterns,
            totalSchools: totalSchools,
          ),
          const SizedBox(height: 20),
          BarChart(
            isDarkMode: widget.isDarkMode,
            yearlyStats: chartYearlyStats,
          ),
          const SizedBox(height: 20),
          RecentActivity(
            isDarkMode: widget.isDarkMode,
            activities: recentActivities,
          ),

          // on mobile: show calendar + intern list below
          if (isMobile) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color(0xFF242424)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CalendarWidget(
                isDarkMode: widget.isDarkMode,
                currentDate: _currentDate,
                calendarDate: _calendarDate,
                onPreviousMonth: _previousMonth,
                onNextMonth: _nextMonth,
              ),
            ),
            const SizedBox(height: 20),
            DahsboardInternList(
              isDarkMode: widget.isDarkMode,
              interns: interns,
            ),
          ],
        ],
      ),
    );

    // ── desktop: Row with RightPanel on the side ──
    // ── mobile: just the main content, RightPanel hidden ──
    return isMobile
        ? mainContent
        : Row(
            children: [
              Expanded(child: mainContent),
              RightPanel(
                isDarkMode: widget.isDarkMode,
                interns: interns,
                currentDate: _currentDate,
                calendarDate: _calendarDate,
                onPreviousMonth: _previousMonth,
                onNextMonth: _nextMonth,
              ),
            ],
          );
  }

  bool get isDarkMode => widget.isDarkMode;
}
