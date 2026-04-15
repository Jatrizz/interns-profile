import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:interfaces/pages/login_page.dart';

// Widgets
import '../widgets/Intern-Dashboard-Widgets/intern_sidebar.dart';
import '../widgets/Intern-Dashboard-Widgets/intern_topbar.dart';
import '../widgets/Intern-Dashboard-Widgets/intern_clock_in_banner.dart';
import '../widgets/Intern-Dashboard-Widgets/intern_stats_cards.dart';
import '../widgets/Intern-Dashboard-Widgets/intern_weekly_chart.dart';
import '../widgets/Intern-Dashboard-Widgets/intern_recent_timelogs.dart';
import '../widgets/Intern-Dashboard-Widgets/intern_right_panel.dart';
import '../widgets/Intern-Dashboard-Widgets/intern_welcome_card.dart';
import '../widgets/Intern-Dashboard-Widgets/intern_ojthours_dialog.dart';

class InternDashboardPage extends StatefulWidget {
  final String firstName;

  const InternDashboardPage({
    super.key,
    required this.firstName,
  });

  @override
  State<InternDashboardPage> createState() => _InternDashboardPageState();
}

class _InternDashboardPageState extends State<InternDashboardPage> {
  bool isDarkMode = true;
  int selectedSidebarIndex = 0;

  late Timer _timer;
  DateTime _currentDate = DateTime.now();
  DateTime _calendarDate = DateTime.now();

  String _currentTimeString = '';

  bool isClockedIn = false;
  DateTime? clockInTime;
  String elapsedTime = '0 hr 0 min';

  double requiredOjtHours = 0;
  double totalHoursRendered = 0;

  double get remainingHours =>
      (requiredOjtHours - totalHoursRendered).clamp(0, double.infinity);

  String todayStatus = 'On-time';

  Map<String, double> weeklyData = {
    'Mon': 0,
    'Tue': 0,
    'Wed': 0,
    'Thurs': 0,
    'Fri': 0,
  };

  List<Map<String, String>> recentLogs = [];
  List<dynamic> interns = [];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());

    _initOjtFlow();
    _fetchTimeLogs();
    _fetchCoInterns();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // CLOCK TICK
  void _tick() {
    final now = DateTime.now();

    setState(() {
      _currentDate = now;

      // TIME for welcome card
      final h = now.hour;
      final m = now.minute.toString().padLeft(2, '0');
      final period = h >= 12 ? 'PM' : 'AM';
      final hour12 = h % 12 == 0 ? 12 : h % 12;

      _currentTimeString = '$hour12:$m $period';

      // clock-in timer stays separate
      if (isClockedIn && clockInTime != null) {
        final diff = now.difference(clockInTime!);
        elapsedTime = '${diff.inHours} hr ${diff.inMinutes.remainder(60)} min';
      }
    });
  }

  // OJT FLOW
  Future<void> _initOjtFlow() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble('requiredOjtHours');

    if (saved == null || saved == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _promptOjtHours());
    } else {
      setState(() => requiredOjtHours = saved);
    }
  }

  Future<void> _promptOjtHours() async {
    final hours = await showOjtHoursDialog(
      context,
      isDarkMode: isDarkMode,
    );

    if (hours != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('requiredOjtHours', hours);
      setState(() => requiredOjtHours = hours);
    }
  }

  // CLOCK IN / OUT
  void _handleClockToggle() {
    setState(() {
      if (isClockedIn) {
        if (clockInTime != null) {
          final worked =
              DateTime.now().difference(clockInTime!).inMinutes / 60.0;
          totalHoursRendered += worked;
        }
        isClockedIn = false;
        clockInTime = null;
        elapsedTime = '0 hr 0 min';
      } else {
        isClockedIn = true;
        clockInTime = DateTime.now();
      }
    });
  }

  // TIME LOGS
  Future<void> _fetchTimeLogs() async {
    try {
      final res = await http.get(
        Uri.parse('http://127.0.0.1:8080/intern/time-logs'),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        setState(() {
          recentLogs = (data as List).take(10).map<Map<String, String>>((e) {
            return {
              'date': e['date'].toString(),
              'timeIn': e['time_in'].toString(),
              'timeOut': e['time_out'].toString(),
              'hours': e['hours'].toString(),
            };
          }).toList();

          totalHoursRendered = data.fold(
            0.0,
            (sum, e) => sum + (double.tryParse(e['hours'].toString()) ?? 0),
          );
        });
      }
    } catch (_) {}
  }

  // INTERN LIST
  Future<void> _fetchCoInterns() async {
    try {
      final res = await http.get(
        Uri.parse('http://127.0.0.1:8080/interns'),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        setState(() {
          interns = data;
        });
      }
    } catch (_) {}
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF242424) : Colors.white,
        title: Text(
          'Logout',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  // CLOCK FORMATTER
  String get _clockInTimeFormatted {
    if (clockInTime == null) return '';
    final h = clockInTime!.hour;
    final m = clockInTime!.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'pm' : 'am';
    final hour12 = h % 12 == 0 ? 12 : h % 12;
    return '$hour12:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      body: Row(
        children: [
          InternSidebar(
            isDarkMode: isDarkMode,
            selectedIndex: selectedSidebarIndex,
            onLogout: _handleLogout,
            onItemSelected: (i) => setState(() => selectedSidebarIndex = i),
          ),
          Expanded(
            child: Column(
              children: [
                InternTopBar(
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
                            children: [
                              ClockInBanner(
                                isDarkMode: isDarkMode,
                                isClockedIn: isClockedIn,
                                clockInTime: _clockInTimeFormatted,
                                elapsedTime: elapsedTime,
                                onClockToggle: _handleClockToggle,
                              ),

                              const SizedBox(height: 16),

                              // WELCOME CARD FOR INTERNS
                              InternWelcomeCard(
                                isDarkMode: isDarkMode,
                                firstName: widget.firstName,
                                currentTime: _currentTimeString,
                              ),

                              const SizedBox(height: 16),

                              InternStatsCards(
                                isDarkMode: isDarkMode,
                                totalHoursRendered: totalHoursRendered,
                                remainingHours: remainingHours,
                                todayStatus: todayStatus,
                              ),

                              const SizedBox(height: 16),

                              InternWeeklyChart(
                                isDarkMode: isDarkMode,
                                weeklyData: weeklyData,
                              ),

                              const SizedBox(height: 16),

                              RecentTimeLogs(
                                isDarkMode: isDarkMode,
                                logs: recentLogs,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // RIGHT PANEL (NEW STRUCTURE)
                      InternRightPanel(
                        isDarkMode: isDarkMode,
                        interns: interns,
                        currentDate: _currentDate,
                        calendarDate: _calendarDate,
                        onPreviousMonth: () => setState(() {
                          _calendarDate = DateTime(
                            _calendarDate.year,
                            _calendarDate.month - 1,
                          );
                        }),
                        onNextMonth: () => setState(() {
                          _calendarDate = DateTime(
                            _calendarDate.year,
                            _calendarDate.month + 1,
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
