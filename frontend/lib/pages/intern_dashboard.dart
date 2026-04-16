import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:interfaces/pages/login_page.dart';

import '../widgets/Intern-Dashboard-Widgets/intern_sidebar.dart';
import '../widgets/Intern-Dashboard-Widgets/intern_topbar.dart';
import '../widgets/Intern-Dashboard-Widgets/intern_clock_in_banner.dart';
import '../widgets/Intern-Dashboard-Widgets/intern_stats_cards.dart';
import '../widgets/Intern-Dashboard-Widgets/intern_weekly_chart.dart';
import '../widgets/Intern-Dashboard-Widgets/intern_recent_timelogs.dart';
import '../widgets/Intern-Dashboard-Widgets/intern_right_panel.dart';
import '../widgets/Intern-Dashboard-Widgets/intern_welcome_card.dart';
import '../widgets/Intern-Dashboard-Widgets/intern_ojthours_dialog.dart';

const String _base = 'http://127.0.0.1:8080';

class InternDashboardPage extends StatefulWidget {
  final String firstName;
  final String userId;

  const InternDashboardPage({
    super.key,
    required this.firstName,
    required this.userId,
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

  String todayStatus = 'absent';

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
    _fetchDashboard();
    _fetchWeeklyHours();
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
      final h = now.hour;
      final m = now.minute.toString().padLeft(2, '0');
      final period = h >= 12 ? 'PM' : 'AM';
      final hour12 = h % 12 == 0 ? 12 : h % 12;
      _currentTimeString = '$hour12:$m $period';

      if (isClockedIn && clockInTime != null) {
        final diff = now.difference(clockInTime!);
        elapsedTime = '${diff.inHours} hr ${diff.inMinutes.remainder(60)} min';
      }
    });
  }

  // 1. FETCH DASHBOARD (required hours, total hours, today status, clock-in state)
  Future<void> _fetchDashboard() async {
    try {
      final res = await http.get(Uri.parse(
        '$_base/intern-dashboard?user_id=${widget.userId}&first_name=${widget.firstName}',
      ));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          totalHoursRendered = (data['total_hours_rendered'] as num).toDouble();
          requiredOjtHours =
              totalHoursRendered + (data['remaining_hours'] as num).toDouble();
          todayStatus = data['todays_status'] ?? 'absent';
          isClockedIn = data['is_clocked_in'] ?? false;

          if (isClockedIn &&
              data['clock_in_time'] != null &&
              data['clock_in_time'] != '') {
            // parse "HH:mm:ss" into today's DateTime
            final parts = (data['clock_in_time'] as String).split(':');
            final now = DateTime.now();
            clockInTime = DateTime(
              now.year,
              now.month,
              now.day,
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            );
          }
        });

        // If required hours not set yet, prompt
        if (requiredOjtHours == 0) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _promptOjtHours());
        }
      }
    } catch (e) {
      debugPrint('fetchDashboard error: $e');
    }
  }

  // 2. FETCH WEEKLY HOURS (chart + recent logs)
  Future<void> _fetchWeeklyHours() async {
    try {
      final res = await http.get(Uri.parse(
        '$_base/intern-weekly-hours?user_id=${widget.userId}',
      ));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;

        final dayMap = {
          'Mon': 'Mon',
          'Tue': 'Tue',
          'Wed': 'Wed',
          'Thu': 'Thurs',
          'Fri': 'Fri',
        };

        setState(() {
          for (var e in data) {
            final day = e['day'].toString();
            final hours = (e['hours'] as num).toDouble();
            if (dayMap.containsKey(day)) {
              weeklyData[dayMap[day]!] = hours;
            }
          }

          // Use weekly data as recent logs display
          recentLogs = data.map<Map<String, String>>((e) {
            return {
              'date': e['day'].toString(),
              'timeIn': '',
              'timeOut': '',
              'hours': e['hours'].toString(),
            };
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('fetchWeeklyHours error: $e');
    }
  }

  // 3. FETCH CO-INTERNS LIST
  Future<void> _fetchCoInterns() async {
    try {
      final res = await http.get(Uri.parse('$_base/interns-list'));

      if (res.statusCode == 200) {
        setState(() => interns = jsonDecode(res.body));
      }
    } catch (e) {
      debugPrint('fetchCoInterns error: $e');
    }
  }

  // 4. SET REQUIRED OJT HOURS (saves to backend + prefs)
  Future<void> _promptOjtHours() async {
    final hours = await showOjtHoursDialog(context, isDarkMode: isDarkMode);

    if (hours != null) {
      try {
        await http.post(
          Uri.parse('$_base/intern-required-hours'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'user_id': widget.userId,
            'required_hours': hours,
          }),
        );
      } catch (e) {
        debugPrint('setRequiredHours error: $e');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('requiredOjtHours', hours);
      setState(() => requiredOjtHours = hours);
    }
  }

  // 5. CLOCK IN
  Future<void> _handleClockIn() async {
    try {
      final res = await http.post(
        Uri.parse('$_base/intern-time-in'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': widget.userId}),
      );

      if (res.statusCode == 200) {
        setState(() {
          isClockedIn = true;
          clockInTime = DateTime.now();
          elapsedTime = '0 hr 0 min';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Clocked in successfully!')),
          );
        }
      } else {
        final body = jsonDecode(res.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(body['error'] ?? 'Clock in failed')),
          );
        }
      }
    } catch (e) {
      debugPrint('clockIn error: $e');
    }
  }

  // 6. CLOCK OUT
  Future<void> _handleClockOut() async {
    try {
      final res = await http.post(
        Uri.parse('$_base/intern-time-out'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': widget.userId,
          'remarks': '',
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          isClockedIn = false;
          clockInTime = null;
          elapsedTime = '0 hr 0 min';
          totalHoursRendered = (data['total_rendered'] as num).toDouble();
          todayStatus = data['status'] ?? todayStatus;
        });
        // Refresh weekly chart
        _fetchWeeklyHours();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Clocked out! Hours today: ${data['hours_rendered']}',
              ),
            ),
          );
        }
      } else {
        final body = jsonDecode(res.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(body['error'] ?? 'Clock out failed')),
          );
        }
      }
    } catch (e) {
      debugPrint('clockOut error: $e');
    }
  }

  // CLOCK TOGGLE — decides in or out
  void _handleClockToggle() {
    if (isClockedIn) {
      _handleClockOut();
    } else {
      _handleClockIn();
    }
  }

  // LOGOUT
  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF242424) : Colors.white,
        title: Text('Logout',
            style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to logout?',
            style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.grey))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Logout', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginPage()));
    }
  }

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
                      InternRightPanel(
                        isDarkMode: isDarkMode,
                        interns: interns,
                        currentDate: _currentDate,
                        calendarDate: _calendarDate,
                        onPreviousMonth: () => setState(() {
                          _calendarDate = DateTime(
                              _calendarDate.year, _calendarDate.month - 1);
                        }),
                        onNextMonth: () => setState(() {
                          _calendarDate = DateTime(
                              _calendarDate.year, _calendarDate.month + 1);
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
