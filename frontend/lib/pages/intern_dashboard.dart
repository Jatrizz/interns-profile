import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  final bool isDarkMode;

  const InternDashboardPage({
    super.key,
    required this.firstName,
    required this.userId,
    required this.isDarkMode,
  });

  @override
  State<InternDashboardPage> createState() => _InternDashboardPageState();
}

class _InternDashboardPageState extends State<InternDashboardPage> {
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

  Future<void> _fetchDashboard() async {
    try {
      final res = await http.get(Uri.parse(
        '$_base/intern-dashboard?user_id=${widget.userId}&first_name=${widget.firstName}',
      ));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        final double requiredFromServer =
            (data['required_ojt_hours'] as num? ?? 0).toDouble();
        final double totalFromServer =
            (data['total_hours_rendered'] as num? ?? 0)
                .toDouble(); // ← add this

        setState(() {
          totalHoursRendered = totalFromServer;
          requiredOjtHours = requiredFromServer;
          todayStatus = data['todays_status'] ?? 'absent';
          isClockedIn = data['is_clocked_in'] ?? false;

          if (isClockedIn &&
              data['clock_in_time'] != null &&
              data['clock_in_time'] != '') {
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

        // ← check both conditions using local variables
        if (requiredFromServer == 0 && totalFromServer == 0) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _promptOjtHours());
        }
      }
    } catch (e) {
      debugPrint('fetchDashboard error: $e');
    }
  }

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

  Future<void> _promptOjtHours() async {
    final hours =
        await showOjtHoursDialog(context, isDarkMode: widget.isDarkMode);

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

  Future<void> _handleClockIn() async {
    try {
      final res = await http.post(
        Uri.parse('$_base/intern-time-in'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': widget.userId}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          isClockedIn = true;
          clockInTime = DateTime.now();
          elapsedTime = '0 hr 0 min';
          todayStatus = data['status'] ?? todayStatus;
        });
        _fetchCoInterns();
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
        _fetchWeeklyHours();
        _fetchCoInterns();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Clocked out! Hours today: ${data['hours_rendered']}'),
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

  void _handleClockToggle() {
    if (isClockedIn) {
      _handleClockOut();
    } else {
      _handleClockIn();
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
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ClockInBanner(
                  isDarkMode: widget.isDarkMode,
                  isClockedIn: isClockedIn,
                  clockInTime: _clockInTimeFormatted,
                  elapsedTime: elapsedTime,
                  onClockToggle: _handleClockToggle,
                ),
                const SizedBox(height: 16),
                InternWelcomeCard(
                  isDarkMode: widget.isDarkMode,
                  firstName: widget.firstName,
                  currentTime: _currentTimeString,
                ),
                const SizedBox(height: 16),
                InternStatsCards(
                  isDarkMode: widget.isDarkMode,
                  totalHoursRendered: totalHoursRendered,
                  remainingHours: remainingHours,
                  todayStatus: todayStatus,
                ),
                const SizedBox(height: 16),
                InternWeeklyChart(
                  isDarkMode: widget.isDarkMode,
                  weeklyData: weeklyData,
                ),
                const SizedBox(height: 16),
                RecentTimeLogs(
                  isDarkMode: widget.isDarkMode,
                  logs: recentLogs,
                ),
              ],
            ),
          ),
        ),
        InternRightPanel(
          isDarkMode: widget.isDarkMode,
          interns: interns,
          currentDate: _currentDate,
          calendarDate: _calendarDate,
          onPreviousMonth: () => setState(() {
            _calendarDate =
                DateTime(_calendarDate.year, _calendarDate.month - 1);
          }),
          onNextMonth: () => setState(() {
            _calendarDate =
                DateTime(_calendarDate.year, _calendarDate.month + 1);
          }),
        ),
      ],
    );
  }
}
